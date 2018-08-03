//
//  SecondViewController.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/3/23.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController   {

    static var adminflagFinal = false  //最终管理员权限的标志

    
    @IBOutlet weak var IDLabel: UILabel!  //账户标签控件
    @IBOutlet weak var AdminMode: UIButton! //进入管路员界面的按钮
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //首先打印当前管理员权限性质
        print("当前admin为\(SecondViewController.adminflagFinal)")
        
        
        //进入管理员界面的监控
        AdminMode.addTarget(self, action:#selector(LoginAdminModeCheck), for: UIControlEvents.touchUpInside)

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    
    //管理员页面跳转函数 传参数+警告
    @objc func LoginAdminModeCheck() {
        if (SecondViewController.adminflagFinal == true) {
            //拥有管理员权限
            self.performSegue(withIdentifier: "adminmode", sender: nil)

        }
        else {
            //没有管理员权限
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "您不是管理员！", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

