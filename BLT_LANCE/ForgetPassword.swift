//
//  ForgetPassword.swift
//  BLT_LANCE
//
//  Created by lance ren on 2018/4/4.
//  Copyright © 2018年 lance ren. All rights reserved.
//

import UIKit
import CoreData

class ForgetPassword: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var SearchAccount: UITextField!
    @IBOutlet weak var PasswordLabel: UILabel!
    
    var StaticManagedObjectContext : NSManagedObjectContext? = nil   //数据库信息实体化区域
    
    var AccountHasExistedFlag = false
    
    var SearchPassword : String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchAccount.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        /// 取得托管对象内容总管
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        StaticManagedObjectContext = managedObjectContext
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //查询用户名是否已经存在
    func RegisterCheck(FuncmanagedObjectContext : NSManagedObjectContext){
        //声明数据的请求
        let fetchRequest = NSFetchRequest<User>(entityName:"User")
        fetchRequest.fetchLimit = 10 //限定查询结果的数量
        fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //设置查询条件
        let predicate = NSPredicate(format: "userAccount= '\(SearchAccount.text!)' ", "")  //查询输入框的用户ID
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
                    SearchPassword = info.userPassword!
                }
                
                
            }
            
        }
        catch {
            fatalError("不能保存：\(error)")
        }
        
    }
    
    
    
    @IBAction func SearchPassword(_ sender: Any) {
        RegisterCheck(FuncmanagedObjectContext: StaticManagedObjectContext!)
        if (AccountHasExistedFlag == true){
            PasswordLabel.text = SearchPassword!
        }
        else{
            print("该账户并不存在，无法查询密码")
            let alertController = UIAlertController(title: "系统提示",
                                                    message: "该账户并不存在，无法查询密码", preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
