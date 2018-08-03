//
//  SelectView.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/3/25.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit
import CoreBluetooth

class SelectView: UIViewController ,UICollectionViewDelegate , UICollectionViewDataSource ,CBCentralManagerDelegate, CBPeripheralDelegate{
    
    
    /*********************** 工程使用说明 ******************/
    //在使用前请先修改 SelectView.swift文件
    // [UUID_Characteristic] 常量，里面对应的值是蓝牙设备对应服务的UUID。
    let UUID_Characteristic:[String] = ["FFE1","FFE0"]
    //let UUID_Characteristic:[String] = ["D2AE0001","D2AE0002","D2AE0003","D2AE0004"]
    /***********************   说明END   ******************/
    
    //连接旗帜
    var trFlagLastConnectState : Bool! = false
    static var ShoppingFlag = false//是否是指定设备
    
    @IBOutlet weak var SelectBackBtn: UIButton!
    
    //页面的选择信息的容器
    var PeripheralToConncet : CBPeripheral!
    var trCBCentralManager : CBCentralManager!
    var myTimer: Timer!
    
    var trIOService : CBService!               //用于储存读写操作对应的CBService uuid  = "FFE0"
    var trWriteCharacteristic : CBCharacteristic! //用于储存待写入的Characteristic   uuid = "FFE1"
    var trReadCharacteristic : CBCharacteristic! //用于储存待读取的Characteristic   uuid = "FFE1"
    var trNotifyCharacteristic : CBCharacteristic! //用处储存通知的Characteristic uuid = "FFE1"
    
    
    
    //managerdelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch central.state{
        case CBManagerState.poweredOn:  //蓝牙已打开正常
            NSLog("Select Goods页面蓝牙设备启动成功，开始搜索")
        case CBManagerState.unauthorized: //无BLE权限
            NSLog("无BLE权限")
        case CBManagerState.poweredOff: //蓝牙未打开
            NSLog("蓝牙未开启")
        default:
            NSLog("状态无变化")
        }
    }
    
    //链接成功，响应函数
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //停止搜索并发现服务
        NSLog("正在连接")
        self.PeripheralToConncet! = peripheral
        self.PeripheralToConncet.delegate = self //绑定外设
        // self.PeripheralToConncet.discoverServices(nil)//搜索服务
        NSLog("重新连接上设备\(String(describing: peripheral.name))")
    }
    
    //链接失败，响应函数
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("连接\(String(describing:peripheral.name))失败 ， 错误原因: \(String(describing: error))")
        trFlagLastConnectState = false
    }
    
    
    func peripheralStateDetect(currentPeripheral: CBPeripheral){
        //外部设备状态判断
        switch currentPeripheral.state {
        case CBPeripheralState.connected:
            NSLog("已连接")
            
            if currentPeripheral.name != nil {
                
            }
            
            currentPeripheral.discoverServices(nil)//搜索服务
            
            
            trFlagLastConnectState = true
            
        case CBPeripheralState.disconnected:
            NSLog("未连接")
            
            if !trFlagLastConnectState {
                NSLog("设备\(currentPeripheral.name!)已断开连接")
                trFlagLastConnectState = false
            }
            
        default:
            NSLog("状态错误")
            
        }
    }
    
    //搜索到服务，开始搜索Characteristic
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        NSLog("搜索到\(String(describing: peripheral.services!.count))个服务")
        //数据显示
        if peripheral.services?.count != 0{
            for service in peripheral.services! {

                if (service.uuid.uuidString == "FFE0") {
                    NSLog("获取到指定服务 \(service.uuid.uuidString)")
                    trIOService = service as CBService  //获取到指定读写的服务"FFE0"
                    peripheral.discoverCharacteristics(nil, for: service)
                    SelectView.ShoppingFlag = true
                }
                
            }
            
        }else{
            NSLog("无有效服务")
        }
    }
    
    
    //搜索到Characteristic   查找指定读写的属性
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        NSLog("从服务\(String(describing:service.uuid.uuidString)) 搜索到\(String(describing: service.characteristics?.count))个属性")

        if service.characteristics!.count != 0 {
            for Characteristic in service.characteristics!{
                //此处有未知bug for in 循环无法给变量正确定义属性，所需要我们自己找个中介变量定义一下
                let aC :CBCharacteristic = Characteristic as CBCharacteristic
                if trIOService != nil {
                    if  trIOService == service {
                        for uuid in UUID_Characteristic {
                            if aC.uuid.uuidString.contains(uuid) {
                                NSLog("获取到指定属性\(aC.uuid.uuidString)")

                                trReadCharacteristic = aC as CBCharacteristic
                                trWriteCharacteristic = aC as CBCharacteristic
                                trNotifyCharacteristic = aC as CBCharacteristic
                                
                            }
                        }
                    }
                    NSLog("从现在开始，发送服务是\(String(describing:service.uuid.uuidString)),特征是\(String(describing: aC.uuid.uuidString)) ")
                    //打开接收广播
                    PeripheralToConncet.setNotifyValue(true, for: trNotifyCharacteristic)
                    NSLog("打开notify,uuid=\(trNotifyCharacteristic.uuid.uuidString)")
                }
            }
        }
    }
    
    
    
    

    //发送数据函数
    func SendShopInfo (tag : Int){
        let goodtag : [String] = ["1","2","3","4","5","6"]
        let data1 = goodtag[tag].data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        
        NSLog("开始写入")
        print(data1)
        
        PeripheralToConncet.writeValue(data1, for:   trWriteCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        
        NSLog("写入完成")
        
        

    }
    
 
    //写入响应
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        NSLog("写入数据状态 \(error.debugDescription)")
        if error == nil {

            NSLog("写入成功响应结束，清空数据成功")
            
        }else{
            
            NSLog("写入错误 \(error.debugDescription)")

        }
    }
    
    
    
    //Notify状态更新响应
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil{
            
            NSLog("Notify设置失败，当前状态为\(characteristic.isNotifying),uuid=\(characteristic.uuid.uuidString),错误提示\(error.debugDescription)")
            
        }else{
            
            NSLog("Notify设置成功,当前状态为\(characteristic.isNotifying),uuid=\(characteristic.uuid.uuidString)")
            
        }
    }
    //读取响应  不断读取广播的新数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if error == nil {
            //显示数据
            
            var readValue : [UInt8] = [UInt8]()
            for readData in characteristic.value! {
                readValue += [readData]
            }
            
            //characteristic.value?.copyBytes(to: UnsafeMutableBufferPointer<UInt8>)
            
            NSLog("data:<\(readValue)>")
        }else{
            NSLog("读取错误 \(error.debugDescription)")
            
        }
    }
    
//    //Notify开关提醒接收信息
//    @IBAction func TurnOnNotify(_ sender: Any) {
//        if trNotifyCharacteristic != nil {
//            if trSwitchNotifyPro.isOn {
//                PeripheralToConncet.setNotifyValue(true, for: trNotifyCharacteristic)
//                NSLog("打开notify,uuid=\(trNotifyCharacteristic.uuid.uuidString)")
//            }else{
//                PeripheralToConncet.setNotifyValue(false, for: trNotifyCharacteristic)
//                NSLog("关闭notify,uuid=\(trNotifyCharacteristic.uuid.uuidString)")
//            }
//        }else{
//            NSLog("没有Notify特征")
//        }
//    }
    
    
    
    
    
    
    var good = ["pairs","water","NFC","Mojito","coke","bingfeng"]    //商品图片容器
    
    //定义单元格的个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return good.count
    }
    
    //初始化单元格的响应
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellidentifier = "Goods"  //设置单元格标识
        
        //启用复用单元格方法，以减少内存占用
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellidentifier, for: indexPath)
        
        let imageView = cell.viewWithTag(1)as! UIImageView
        imageView.layer.opacity = 0.5   //透明度为0.5
        let imageName = good[(indexPath as NSIndexPath).row]
        imageView.image = UIImage(named:imageName)  //加载图片
        
        return cell
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //选中图片后的响应函数
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //加载选中图片
        let cell = collectionView.cellForItem(at: indexPath)
        let view = cell?.viewWithTag(1)
        let num = indexPath.row
        
        view?.layer.opacity=1.0    //透明度设置为1.0
        
        
    if SelectView.ShoppingFlag {
        
        
        /**************提示购物窗口************************/
        
        //建立提示窗口
        let alertController = UIAlertController(title: "系统提示",
                                                message: "您确定要购买这件商品吗？", preferredStyle: .alert)
        //取消动作
        let cancelAction = UIAlertAction(title: "取消", style:.destructive, handler: {
            action in
            print("clicked cancel")  //系统调试日志
            cell?.viewWithTag(1)?.layer.opacity = 0.5

        }
        )
        
        //确认动作
        let okAction = UIAlertAction(title: "好的", style: .default, handler: {
        
            
            action in
            
            //购买信息发送
            self.SendShopInfo(tag: num)
            
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "购买成功", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
            }
            
            //两秒钟后图片透明度恢复为 0.5
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
               
                cell?.viewWithTag(1)?.layer.opacity = 0.5

            }
            
        })
    
        //将取消动作和确认动作加载到提示框中
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    else {
        let alertController = UIAlertController(title: "系统提示",
                                                message: "此蓝牙并非指定售货机蓝牙！无法进行购买！", preferredStyle: .alert)
        //显示提示框
        self.present(alertController, animated: true, completion: nil)
        //两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        //两秒钟后图片透明度恢复为 0.5
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            
            cell?.viewWithTag(1)?.layer.opacity = 0.5
            
        }
    }
}
    
    
    //页面数据传递
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ServiceToSearchView" {
            NSLog("断开连接")
            trCBCentralManager.cancelPeripheralConnection(PeripheralToConncet) //页面关闭时断开连接
        }
    }
    

    @IBAction func BackToShoppingMechine(_ sender: Any) {
        self.performSegue(withIdentifier: "ServiceToSearchView", sender: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //绑定CBPeripheral委托
        self.PeripheralToConncet.delegate = self
        peripheralStateDetect(currentPeripheral: PeripheralToConncet)   //获取当前设备状态
        
        
//        //初始化定时器
//        myTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.trWriteIntervalHandler), userInfo: nil, repeats: true)
//        myTimer.fireDate = Date.distantFuture
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
