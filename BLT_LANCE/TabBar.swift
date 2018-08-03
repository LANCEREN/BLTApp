//
//  TabBar.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/4/1.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit
import CoreBluetooth

var qqq = 1
class TabBar: UITabBarController ,CBCentralManagerDelegate {
    
    var myCentralManager: CBCentralManager!//中心设备管理器
    var myPeripheral: CBPeripheral!//外围设备
    
    //检查外设管理器状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:  //蓝牙已打开正常
            NSLog("TabBar Scene页面蓝牙启动成功，开始搜索")
            self.myCentralManager.scanForPeripherals(withServices: nil, options: nil) //不限制
        case CBManagerState.unauthorized: //无BLE权限
            NSLog("无BLE权限")
        case CBManagerState.poweredOff: //蓝牙未打开
            NSLog("蓝牙未开启")
        default:
            NSLog("状态无变化")
        }
    }
    

    @IBOutlet weak var mytabbar: UITabBar!  //tabbar实体化方便构建监控函数
    static var adminflag = false   //tabbar页面下的管理员权限
    var ad:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加CBPeripheral管理器的委托
        self.myCentralManager = CBCentralManager(delegate: self , queue: nil)
        
        // Do any additional setup after loading the view.
    }

    
    //点击tabbar Item有不同的触发事件
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if (item.tag == 1)  //tag1 表示 secondviewcontroller
        {
            print("跳转至 SecondViewController")
            SecondViewController.adminflagFinal = TabBar.adminflag  //管理员权限传参
            //停止画面一一搜索设备和刷新
            self.myCentralManager.stopScan()

        }
        
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
