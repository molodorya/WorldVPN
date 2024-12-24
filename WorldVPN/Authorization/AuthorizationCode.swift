//
//  AuthorizationCode.swift
//  WorldVPN
//
//  Created by Nikita Molodorya on 25.12.2024.
//

import UIKit

class AuthorizationCode: UIViewController {
    
    
    @IBOutlet weak var button: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.cornerRadius = 30
        scheduleLocalNotification()
        
        hideKeyboardWhenTappedAround()
    }
    
    
    func scheduleLocalNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Контент уведомления
        let content = UNMutableNotificationContent()
        content.title = "Ваш код авторизации"
        content.body = "Код для авторизации: \(Int.random(in: 0000...9999))"
        content.sound = .default
        
        // Триггер уведомления (например, через 5 секунд)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Создание запроса
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)
        
        // Добавление запроса
        center.add(request) { error in
            if let error = error {
                print("Ошибка добавления уведомления: \(error)")
            } else {
                print("Уведомление успешно добавлено.")
            }
        }
    }
    
}
