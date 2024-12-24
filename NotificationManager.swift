//
//  NotificationManager.swift
//  WorldVPN
//
//  Created by Nikita Molodorya on 25.12.2024.
//

import UIKit
import UserNotifications

class NotificationManager {
    
    static func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        
        // Запрос разрешения
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка при запросе разрешений: \(error)")
            } else {
                print(granted ? "Разрешение предоставлено" : "Разрешение отклонено")
            }
        }
        
        // Настройка делегата (опционально)
        center.delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
    }
}
