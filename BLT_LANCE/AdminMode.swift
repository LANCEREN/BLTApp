//
//  AdminMode.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/4/2.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class AdminMode: UIViewController , UITextFieldDelegate , UITableViewDataSource , UITableViewDelegate ,CBCentralManagerDelegate {

    @IBOutlet weak var FreshButton: UIButton!
    @IBOutlet weak var ClearButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    
    @IBOutlet weak var DeleteAccount: UITextField!
    
    @IBOutlet weak var SelectMechine: UITableView!
    
    var StaticManagedObjectContext : NSManagedObjectContext? = nil   //数据库信息实体化区域
    var AccountHasExistedFlag = false
    var TargetMachineFlag = false
    
    
    let alertConnect = UIAlertController(title: "系统提示",
                                         message: "正在连接:...", preferredStyle: .alert)
    let alertError = UIAlertController(title: "系统提示",
                                       message: "连接失败", preferredStyle: .alert)
    let alertTIMEOUT = UIAlertController(title: "系统提示",
                                         message: "连接超时", preferredStyle: .alert)
    //属性
    var flagScan : Bool! = false
    var myCentralManager: CBCentralManager!//中心设备管理器
    var myPeripheral: CBPeripheral!//外围设备
    var myCBError : CBError!
    //容器，保存搜索到的蓝牙设备
    var myPeripheralToMainView :CBPeripheral! //初始化外设，用以传递给主页面
    var myPeripherals: NSMutableArray = NSMutableArray() //初始化动态数组 用以储存字典
    //服务和UUID  可用于过滤器限定（限定条件：1.设备UUID 2.服务UUID）
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //添加Tableview代理的绑定
        self.SelectMechine.delegate = self
        self.SelectMechine.dataSource = self
        DeleteAccount.delegate = self
        
        /****************/
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        StaticManagedObjectContext = managedObjectContext
        /****************/
        
        
        //添加提示框
        let cancelAction = UIAlertAction(title: "取消连接", style: .default, handler: {
            action in
            self.myCentralManager.cancelPeripheralConnection(self.myPeripheralToMainView)
        })
        alertConnect.addAction(cancelAction)
        let okAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
        alertError.addAction(okAction)
        alertTIMEOUT.addAction(okAction)
        
        //添加CBPeripheral管理器的委托
        self.myCentralManager = CBCentralManager(delegate: self , queue: nil)
        
        
        
        BackButton.addTarget(self, action:#selector(BackToTabbar), for: UIControlEvents.touchUpInside)
        // Do any additional setup after loading the view.
    }

    
    
    //查询用户名是否已经存在
    func RegisterCheck(FuncmanagedObjectContext : NSManagedObjectContext){
        //声明数据的请求
        let fetchRequest = NSFetchRequest<User>(entityName:"User")
        fetchRequest.fetchLimit = 10 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //设置查询条件
        let predicate = NSPredicate(format: "userAccount= '\(DeleteAccount.text!)' ", "")  //查询输入框的用户ID
        fetchRequest.predicate = predicate
        
        //查询操作
        do {
            let fetchedObjects = try FuncmanagedObjectContext.fetch(fetchRequest)
            
            //遍历查询的结果
            for info in fetchedObjects{
                
                if(fetchedObjects.count>0){
                    //打印用户信息
                    print("该账户确实存在，可以准备删除")
                    print("useraccount=\(String(describing: info.userAccount!))")
                    print("userpassword=\(String(describing: info.userPassword!))")
                    print("userallergy=\(String(describing: (info.userallergy)!))")
                    //用户名已经存在
                    AccountHasExistedFlag = true
                }
                else
                {
                    AccountHasExistedFlag = false
                }
                
                
            }
            
        }
        catch {
            fatalError("不能保存：\(error)")
        }
        
    }
    
    func deleteAccountAction(FuncmanagedObjectContext : NSManagedObjectContext){
        
        //声明数据的请求
        let fetchRequest = NSFetchRequest<User>(entityName:"User")
        fetchRequest.fetchLimit = 10 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //设置查询条件
        let predicate = NSPredicate(format: "userAccount= '\(DeleteAccount.text!)' ", "")
        fetchRequest.predicate = predicate
        
        //查询操作
        do {
            let fetchedObjects = try FuncmanagedObjectContext.fetch(fetchRequest)
          
            //遍历查询的结果
                        for info in fetchedObjects{
                            print("准备删除的用户信息\n")
                            print("useraccount=\(String(describing: info.userAccount!))")
                            print("userpassword=\(String(describing: info.userPassword!))")
                            print("userallergy=\(String(describing: (info.userallergy)!))")
                        }
            
            //删除操作
            
                        for info in fetchedObjects{
                            //删除对象
                            FuncmanagedObjectContext.delete(info)
                        }
            
                        //重新保存-更新到数据库
                        try! FuncmanagedObjectContext.save()
            
        }
        catch {
            fatalError("不能保存：\(error)")
        }
        
        
        
    }
    
    @IBAction func DeleteEvent(_ sender: Any) {
        RegisterCheck(FuncmanagedObjectContext: StaticManagedObjectContext!)
        if(AccountHasExistedFlag == true)
        {
            deleteAccountAction(FuncmanagedObjectContext: StaticManagedObjectContext!)
            print("该账户已经删除")
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "账号已删除", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
            
        }
        else{
            print("账号并不存在，无法删除该账户")
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "账号不存在，无法删除该账户", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    
    @objc func BackToTabbar() {
        
        print("跳转至Tabbar")
        self.performSegue(withIdentifier: "backtotabbar", sender: nil)
        
    }
    
    
    //******************* 页面数据传递 **************
    //页面数据传递
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "backtotabbar"
        {
            
            //let vc = segue.destination as! TabBar   //传递器
            //vc.adminflag = true   //管理员传值！！
            
        }
        
        if segue.identifier == "goods"
        {
            let vc = segue.destination as! GoodsStates   //传递器
            vc.PeripheralToConncet = myPeripheralToMainView
            vc.trCBCentralManager = myCentralManager
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return myPeripherals.count
    }
    
    
    //数据列数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //1列
    }
    
    
    //设置CELL
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        
        //使用自定义cell   //启用复用单元格方法，以减少内存占用
        let cell = self.SelectMechine.dequeueReusableCell(withIdentifier: "Device")! as UITableViewCell
        //获取自定义cell控件
        let labelName = cell.viewWithTag(1) as! UILabel
        let labelRSSI = cell.viewWithTag(2) as! UILabel
        let labelUUID = cell.viewWithTag(3) as! UILabel
        
        //获取数据
        let s:NSDictionary = myPeripherals[indexPath.row] as! NSDictionary
        let p:CBPeripheral = s.value(forKey: "peripheral") as! CBPeripheral
        let d:NSDictionary = s.value(forKey: "advertisementData") as! NSDictionary
        let rssi:NSNumber  = s.value(forKey: "RSSI") as! NSNumber
        
        //传递数据到控件
        labelName.text? = "\(p.name!)  "
        labelRSSI.text? = "信号强度：\(rssi) dB"
        labelUUID.text? = "\(p.identifier)"
        
//        NSLog("设备名\(String(describing: p.name)),状态\(p.state),UUID\(p.identifier),信号\(rssi)")
//        NSLog("广播内容\(d.allValues)")
        return cell
    }
    
    //******************* 响应tableview动作**************
    //选中单元格时的响应
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        
        NSLog("停止搜索")
        self.myCentralManager.stopScan()
        flagScan = false
        //关闭TableView的选择动画
        SelectMechine.deselectRow(at: indexPath, animated: true)
        //提取设备库中当前所选的设备传递到全局变量
        let myPeriDict:NSDictionary = myPeripherals[indexPath.row] as! NSDictionary
        myPeripheralToMainView = myPeriDict.value(forKey:"peripheral") as! CBPeripheral
        
        if(myPeripheralToMainView!.name == "q"){
            TargetMachineFlag = true
            connectPeripheral(peripheral: myPeripheralToMainView)
        }
        else{
            TargetMachineFlag = false
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "此蓝牙并非指定售货机蓝牙！无法进行货物查看！", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
        
        
        
        //取消动画
        //self.tableview.deselectRow(at: indexPath, animated: true)
        
        /*连接成功提示窗
         let alertController = UIAlertController(title: "系统提示",
         message: "正在连接...", preferredStyle: .alert)
         //显示提示框
         self.present(alertController, animated: true, completion: nil)
         //两秒钟后自动消失
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
         self.presentedViewController?.dismiss(animated: false, completion: nil)
         
         
         
         }
         
         */
        
        
        
        //let itemString = self.ctrlnames[indexPath.row]
        //        self.performSegue(withIdentifier: "SearchViewtoServiceView", sender: nil)
        //
        
    }
    
    
    
    /********************** 蓝牙响应函数 **********************/
    
    //检查外设管理器状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case CBManagerState.poweredOn:  //蓝牙已打开正常
            NSLog("AdminMode页面蓝牙启动成功，开始搜索")
            self.myCentralManager.scanForPeripherals(withServices: nil, options: nil) //不限制
        case CBManagerState.unauthorized: //无BLE权限
            NSLog("无BLE权限")
        case CBManagerState.poweredOff: //蓝牙未打开
            NSLog("蓝牙未开启")
        default:
            NSLog("状态无变化")
        }
    }
    
    //检查到设备，响应函数
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var nsPeripheral : NSArray
        nsPeripheral = myPeripherals.value(forKey: "peripheral") as! NSArray   //读取全部的外设值
        if(!nsPeripheral.contains(peripheral)){                                //判断数组内的peripheral与当前读取到的是否相同，若重复则不添加
            
            if(peripheral.name?.isEmpty == false){
                //新建字典
                let r : NSMutableDictionary = NSMutableDictionary()
                r.setValue(peripheral, forKey: "peripheral")
                r.setValue(RSSI, forKey: "RSSI")
                r.setValue(advertisementData, forKey: "advertisementData")
                myPeripherals.add(r)
                
                //NSLog("搜索到设备，Name=\(peripheral.name!) UUID=\(peripheral.identifier)")
                NSLog("设备名\(String(describing: peripheral.name)),状态\(peripheral.state),UUID\(peripheral.identifier),信号\(RSSI)")
                NSLog("广播内容\(r.allValues)")
            }
        }
        SelectMechine.reloadData()
    }
    
    
    //链接成功，相应函数
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("已连接\(peripheral.name!)")
        self.myPeripheralToMainView! = peripheral
        //self.alertConnect.dismiss(animated: false)
        self.performSegue(withIdentifier: "goods", sender: nil)
    }
    
    
    //自定义的连接函数，会弹出提示框
    func connectPeripheral(peripheral:CBPeripheral){
        
        myCentralManager.connect(peripheral, options: nil)
        var nameToConnect : String!
        if peripheral.name == nil {
            nameToConnect = "无名设备"
        }
        else{
            nameToConnect = peripheral.name!
            
        }
        alertConnect.message = "正在连接:\(nameToConnect!)..."
        //self.present(alertConnect, animated: true, completion: nil)
        
    }
    //链接失败响应函数
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        NSLog("连接失败，设备名\(peripheral.name!),原因\(String(describing: error))")
        //alertConnect.dismiss(animated: false, completion:  nil)
        self.present(alertError, animated: false, completion:  nil)  //弹出失败提示框
        alertError.dismiss(animated: false, completion: nil)
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //view弹起跟随键盘，高可根据自己定义
    func textFieldDidBeginEditing(_ textView:UITextField) {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.view.frame.origin.y = -150
            
        })
        
    }
    
    //键盘收回，view放下
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.view.frame.origin.y = 0
            
        })
        
        return true
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
