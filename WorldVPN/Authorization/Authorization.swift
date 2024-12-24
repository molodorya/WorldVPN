//
//  Authorization.swift
//  WorldVPN
//
//  Created by Nikita Molodorya on 25.12.2024.
//

import UIKit

class Authorization: UIViewController {
    
 

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    
    @IBOutlet weak var button: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textFieldView.layer.cornerRadius = 30
        textFieldView.layer.borderWidth = 1
        textFieldView.layer.borderColor = UIColor.systemBlue.cgColor
        
        
        button.layer.cornerRadius = 30

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка запроса разрешения: \(error)")
            } else if granted {
                print("Разрешение на уведомления получено.")
            } else {
                print("Разрешение на уведомления отклонено.")
            }
        }
        
        
        hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func button(_ sender: UIButton) {
//        let authorizationCode = AuthorizationCode()
//        navigationController?.pushViewController(authorizationCode, animated: true)
    }
}
