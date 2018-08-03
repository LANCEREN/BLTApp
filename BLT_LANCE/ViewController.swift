//
//  ViewController.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/3/24.
//  Copyright © 2018年 lance ren. All rights reserved.
//
//

import UIKit
import CoreData

class ViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var AccountText: UITextField!  //账户输入栏控件
    @IBOutlet weak var PasswordText: UITextField!   //密码输入栏控件
    
    @IBOutlet weak var Login: UIButton! //登录按钮控件

//    user.userAccount = "testregister"  //模拟管理员账号密码
//    user.userPassword = "1234"
    
    var AdminFlagLogin : Bool = false  //管理员标志
    var AccountRegisterFlag : Bool = false  //用户注册标志
    var AcPwFlag : Bool = false   //账号密码一致标志
    
    var StaticManagedObjectContext : NSManagedObjectContext? = nil   //数据库信息实体化区域
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化注册用户信息
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // 取得托管对象内容总管
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        StaticManagedObjectContext = managedObjectContext
        
        /************************先检查有没有注册*********************/
        
        CheckHasRegistedUserInfo(FuncmanagedObjectContext: StaticManagedObjectContext!)
        
        RegisterUserInfo(FuncmanagedObjectContext: StaticManagedObjectContext!)
        
        
        
        //初始化开始，控件代理自己
        AccountText.delegate = self
        PasswordText.delegate = self
        
        AccountText.placeholder = "Your Account"   //未输入时默认字符
        PasswordText.placeholder = "Your Password"
        AccountText.adjustsFontSizeToFitWidth = true   //输入字符自动适应长宽高
        PasswordText.adjustsFontSizeToFitWidth = true
        AccountText.clearButtonMode = UITextFieldViewMode.whileEditing  //打开可一键清理按钮
        PasswordText.clearButtonMode = UITextFieldViewMode.whileEditing
        PasswordText.isSecureTextEntry = true   //打开密码隐私保护设置
        
        //添加登录按钮监控事件
        Login.addTarget(self, action:#selector(LoginCheck), for: UIControlEvents.touchUpInside)
        
        
        // Do any additional setup after loading the view.
    }

    

    //登录检查账号密码函数
  @objc   func LoginCheck()  {
    
    
        CheckSearch( FuncmanagedObjectContext : StaticManagedObjectContext! )
    
        if (
                AcPwFlag == true
            )
            
        {
            
            print("账号密码正确\n")

            self.performSegue(withIdentifier: "loginsegue", sender: nil)
        }
            
        else{
            print("账号或者密码错误，请重试")
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "账号或密码错误", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
            }
        }
    }
    
    //检查是否注册过用户信息
    func CheckHasRegistedUserInfo(FuncmanagedObjectContext :NSManagedObjectContext){
        
        //声明数据的请求
        let fetchRequest = NSFetchRequest<User>(entityName:"User")
        fetchRequest.fetchLimit = 10 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //设置查询条件
        let predicate = NSPredicate(format: "userAccount= 'testregister' ", "")
        fetchRequest.predicate = predicate
        
        //查询操作
        do {
            let fetchedObjects = try FuncmanagedObjectContext.fetch(fetchRequest)
            if(fetchedObjects.count > 0)
            {
                print("已经注册过用户信息\n")
                AccountRegisterFlag = true
            }
           //遍历查询的结果
            for info in fetchedObjects{
                print("useraccount=\(String(describing: info.userAccount!))")
                print("userpassword=\(String(describing: info.userPassword!))")
                print("userallergy=\(String(describing: (info.userallergy)!))")
                        }
            
        }
        catch {
            fatalError("不能保存：\(error)")
        }
        
        
    }
    
    ///注册用户信息响应
    func RegisterUserInfo( FuncmanagedObjectContext :NSManagedObjectContext ){
        //如果未注册，那么注册用户基本信息
        if (AccountRegisterFlag == false)
        {
            
            let user = NSEntityDescription.insertNewObject(forEntityName: "User",into: FuncmanagedObjectContext) as! User
            
            user.userAccount = "testregister"
            user.userPassword = "1234"
            user.userallergy = "none"
            user.userAdmin = true
            
            //保存
            do {
                try FuncmanagedObjectContext.save()
                
                print("基本用户账号密码注册成功！")
                
                AccountRegisterFlag = true  //防止多次注册
                
                
                
            } catch {
                fatalError("不能保存：\(error)")
            }
            
            
        }
    }
    
    
    ///检查账号密码是否一致
    func CheckSearch( FuncmanagedObjectContext :NSManagedObjectContext ) {
        
        ///声明数据的请求
        let fetchRequest = NSFetchRequest<User>(entityName:"User")
        fetchRequest.fetchLimit = 10 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //设置查询条件
        let predicate = NSPredicate(format: "userAccount= '\(AccountText.text!)' ", "")  //查询输入框的用户ID
        fetchRequest.predicate = predicate
        
        //查询操作
        do {
            let fetchedObjects = try FuncmanagedObjectContext.fetch(fetchRequest)
            
            //遍历查询的结果
                for info in fetchedObjects{
                
                //打印用户信息
                print("检查账号密码是否一致")
                print("useraccount=\(String(describing: info.userAccount!))")
                print("userpassword=\(String(describing: info.userPassword!))")
                print("userallergy=\(String(describing: (info.userallergy)!))")
                
                    
                //进行账号密码比对
                if(AccountText.text! == info.userAccount &&
                    PasswordText.text! == info.userPassword
                    )
                {
                   AcPwFlag = true  //一致则可以登录
                    
                }
                else
                {
                    AcPwFlag = false
                }
                    
                if(info.userAdmin == true)
                {
                    AdminFlagLogin = true
                }
                else
                {
                    AdminFlagLogin = false
                }
                    
                    
            }
            
        }
        catch {
            fatalError("不能保存：\(error)")
        }
        
    }
    

    //******************* 页面数据传递 **************
    ///页面数据传递
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginsegue"
        {
            
            //let vc = segue.destination as! TabBar   //传递器 原先不用全局变量的传值
            //vc.adminflag = AdminFlagLogin
            
            TabBar.adminflag = AdminFlagLogin   //传值！！
            
        }
        
    }
   
    //view弹起跟随键盘，高可根据自己定义
    func textFieldDidBeginEditing(_ textView:UITextField) {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.view.frame.origin.y = -160
            
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

