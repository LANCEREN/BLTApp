//
//  FirstViewController.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/3/23.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit
import CoreBluetooth


class FirstViewController: UIViewController , UITableViewDataSource , UITableViewDelegate ,CBCentralManagerDelegate {
    

    @IBOutlet weak var myButtonScan: UIButton!
    
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
        self.tableview.delegate = self
        self.tableview.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        
        //添加提示框
        let cancelAction = UIAlertAction(title: "取消连接", style: .default, handler: {
            action in
            self.myCentralManager.cancelPeripheralConnection(self.myPeripheralToMainView)
        })
        let okAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
        alertConnect.addAction(cancelAction)
        alertError.addAction(okAction)
        alertTIMEOUT.addAction(okAction)
        
        //添加CBPeripheral管理器的委托
        self.myCentralManager = CBCentralManager(delegate: self , queue: nil)
    }
    
    //**************** 绑定tableView数据 **************
    @IBOutlet weak var tableview: UITableView!   //tableview控件属性
    
    ///tableview的行数 = 设备名称个数
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return myPeripherals.count
        }

    
    //数据列数
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1 //1列
        }

    //设置CELL
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            
          
            // tableView.rowHeight = 40 可调单元格高度
            //使用自定义cell   //启用复用单元格方法，以减少内存占用
            let cell = self.tableview.dequeueReusableCell(withIdentifier: "Device")! as UITableViewCell
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
    
            //NSLog("设备名\(String(describing: p.name!)),状态\(p.state),UUID\(p.identifier),信号\(rssi)")
            //NSLog("广播内容\(d.allValues)")
            return cell
        }
    
       //******************* 响应tableview动作**************
    //选中单元格时的响应
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        
        NSLog("停止搜索")
        self.myCentralManager.stopScan()
        myButtonScan.setTitle("搜索", for: UIControlState.normal)
        flagScan = false
        //关闭TableView的选择动画
        tableview.deselectRow(at: indexPath, animated: true)
        //提取设备库中当前所选的设备传递到全局变量
        let myPeriDict:NSDictionary = myPeripherals[indexPath.row] as! NSDictionary
        myPeripheralToMainView = myPeriDict.value(forKey:"peripheral") as! CBPeripheral
        connectPeripheral(peripheral: myPeripheralToMainView)
        
        
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

    }
    

    //***************控件响应函数**************
    
    @IBAction func acScan(_ sender: Any) {
        if flagScan == true {
            NSLog("停止搜索")
            self.myCentralManager.stopScan()
            myButtonScan.setTitle("搜索", for: UIControlState.normal)
            flagScan = false
            
        }else{
            NSLog("开始搜索")
            myButtonScan.setTitle("停止", for: UIControlState.normal)
            self.myCentralManager = CBCentralManager(delegate: self , queue: nil)//?
            self.myCentralManager.scanForPeripherals(withServices: nil, options: nil)
            flagScan = true
        }
        
    }
    
    //清除屏幕
    @IBAction func acClear(_ sender: Any) {
        myPeripherals.removeAllObjects()
        tableview.reloadData()
        
    }
    
    /********************** 蓝牙响应函数 **********************/
    
    //检查外设管理器状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case CBManagerState.poweredOn:  //蓝牙已打开正常
            NSLog("Shopping Scene页面蓝牙启动成功，开始搜索")
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
        if(!nsPeripheral.contains(peripheral)){//判断数组内的peripheral与当前读取到的是否相同，若重复则不添加
            if(peripheral.name?.isEmpty == false){
                //新建字典
                let r : NSMutableDictionary = NSMutableDictionary()
                r.setValue(peripheral, forKey: "peripheral")
                r.setValue(RSSI, forKey: "RSSI")
                r.setValue(advertisementData, forKey: "advertisementData")
                myPeripherals.add(r)

                NSLog("搜索到设备，设备名是\(String(describing: peripheral.name!)),状态\(peripheral.state),UUID=\(peripheral.identifier),信号\(RSSI)")
                NSLog("广播内容\(r.allValues)")
                NSLog("刷新屏幕")
            }
            //print("搜索到无名设备")
        }
        tableview.reloadData()
    }
    
    //链接成功，相应函数
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //alertConnect.dismiss(animated: false)
        NSLog("已连接\(peripheral.name!)")
        self.myPeripheralToMainView! = peripheral
        self.performSegue(withIdentifier: "SearchViewtoServiceView", sender: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("This viewcontroller was disappeared.")
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
        //self.present(alertConnect, animated: true, completion: nil)  //由于AlertController的dismiss太慢导致页面跳转崩溃，故暂时选择不出现提示
    }
    //链接失败响应函数
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        NSLog("连接失败，设备名\(peripheral.name!),原因\(String(describing: error))")
        //alertConnect.dismiss(animated: false, completion:  nil)
        self.present(alertError, animated: false, completion:  nil)  //弹出失败提示框
        alertError.dismiss(animated: false, completion: nil)
    }
    
    

        //******************* 页面数据传递 **************
    //页面数据传递
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SearchViewtoServiceView"
        {
            let vc = segue.destination as! SelectView   //传递器
            vc.PeripheralToConncet = myPeripheralToMainView
            vc.trCBCentralManager = myCentralManager
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

