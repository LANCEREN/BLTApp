//
//  GoodsStates.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/4/14.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit
import CoreBluetooth

class GoodsStates: UIViewController ,CBCentralManagerDelegate, CBPeripheralDelegate{

    /*********************** 工程使用说明 ******************/
    //在使用前请先修改 SelectView.swift文件
    // [UUID_Characteristic] 常量，里面对应的值是蓝牙设备对应服务的UUID。
    let UUID_Characteristic:[String] = ["FFE1","FFE0"]
    //let UUID_Characteristic:[String] = ["D2AE0001","D2AE0002","D2AE0003","D2AE0004"]
    /***********************   说明END   ******************/
    //连接旗帜
    var trFlagLastConnectState : Bool! = false
    //产品一的数量状态
    @IBOutlet weak var goodnum1: UILabel!
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
            NSLog("启动成功，开始搜索")
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
        NSLog("搜索到\(String(describing: peripheral.services?.count))个服务")
        //数据显示
        if peripheral.services?.count != 0{
            for service in peripheral.services! {
                
                if (service.uuid.uuidString == "FFE0") {
                    NSLog("获取到指定服务 \(service.uuid.uuidString)")
                    trIOService = service as CBService  //获取到指定读写的服务"FFE0"
                    peripheral.discoverCharacteristics(nil, for: service)
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
                    PeripheralToConncet.setNotifyValue(true, for: trNotifyCharacteristic)
                    NSLog("打开notify,uuid=\(trNotifyCharacteristic.uuid.uuidString)")
                }
            }
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
            
            //接收数据处理
            goodnum1.text! = "当前数量为\(readValue)"
            
            if(readValue == [0])
            {
                 goodnum1.textColor = UIColor.red
            }
            else
            {
                goodnum1.textColor = UIColor.black
            }
        }
        else{
            NSLog("读取错误 \(error.debugDescription)")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //绑定CBPeripheral委托
        self.PeripheralToConncet.delegate = self
        peripheralStateDetect(currentPeripheral: PeripheralToConncet)   //获取当前设备状态
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //页面数据传递
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ServiceToSearchView" {
            NSLog("断开连接")
            trCBCentralManager.cancelPeripheralConnection(PeripheralToConncet) //页面关闭时断开连接
            
        }
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
