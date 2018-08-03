//
//  register.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/4/3.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit
import CoreData

class register: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var RegisterAccount: UITextField!
    @IBOutlet weak var RegisterPassword: UITextField!
    @IBOutlet weak var RegisterAllergy: UITextField!
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    var StaticManagedObjectContext : NSManagedObjectContext? = nil   //数据库信息实体化区域
    
    var AccountHasExistedFlag = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // 取得托管对象内容总管
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        StaticManagedObjectContext = managedObjectContext
        
        RegisterAccount.delegate = self
        RegisterPassword.delegate = self
        RegisterAllergy.delegate = self
        
        // Do any additional setup after loading the view.
    }


    //点击注册按钮响应
    @IBAction func RegisterEvent(_ sender: Any) {
        //首先检查用户名
        RegisterCheck(FuncmanagedObjectContext: StaticManagedObjectContext!)
        
        if(AccountHasExistedFlag == false)
        {
            
            RegisterSheet(FuncmanagedObjectContext: StaticManagedObjectContext!)
            //self.performSegue(withIdentifier: "RegisterDown", sender: nil)
            
        }
            
        else{
            print("账号已经存在，无法注册")
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "账号已经存在", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
        
    }
    
    
    
    //进行用户注册操作
    func RegisterSheet(FuncmanagedObjectContext : NSManagedObjectContext){
        
        let user = NSEntityDescription.insertNewObject(forEntityName: "User",into: FuncmanagedObjectContext) as! User
        user.userAccount = RegisterAccount.text!
        user.userPassword = RegisterPassword.text!
        user.userallergy = RegisterAllergy.text!
        user.userAdmin = false
        
                //保存
                do {
                    try FuncmanagedObjectContext.save()
                    print("账号密码保存成功！")

                } catch {
                    fatalError("不能保存：\(error)")
                }
       
        let alertController = UIAlertController(title: "系统提示",
                                                message: "账号密码注册成功",                 preferredStyle: .alert)
        //显示提示框
        self.present(alertController, animated: true, completion: nil)
        //两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        
    }
    
    
    //查询用户名是否已经存在
    func RegisterCheck(FuncmanagedObjectContext : NSManagedObjectContext){
        //声明数据的请求
        let fetchRequest = NSFetchRequest<User>(entityName:"User")
        fetchRequest.fetchLimit = 10 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //设置查询条件
        let predicate = NSPredicate(format: "userAccount= '\(RegisterAccount.text!)' ", "")  //查询输入框的用户ID
        fetchRequest.predicate = predicate
        
        //查询操作
        do {
            let fetchedObjects = try FuncmanagedObjectContext.fetch(fetchRequest)
            
            //遍历查询的结果
            for info in fetchedObjects{
               
                if(fetchedObjects.count>0){
                //打印用户信息
                print("该用户名称已经存在")
                print("useraccount=\(String(describing: info.userAccount!))")
                print("userpassword=\(String(describing: info.userPassword!))")
                print("userallergy=\(String(describing: (info.userallergy)!))")
                //用户名已经存在
                AccountHasExistedFlag = true
                
                }
                
                
            }
            
        }
        catch {
            fatalError("不能保存：\(error)")
        }
        
    }
    
    
    
    
    
    //view弹起跟随键盘，高可根据自己定义
    func textFieldDidBeginEditing(_ textView:UITextField) {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.view.frame.origin.y = -70
            
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
