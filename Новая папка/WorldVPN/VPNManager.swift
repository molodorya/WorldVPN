//
//  VPN.swift
//  molodorya.vpn
//
//  Created by Nikita Molodorya on 01.09.2024.
//

import Foundation
import NetworkExtension
import UIKit
import Security



 
class VPNManager {
    
    private var vpnManager = NEVPNManager.shared()
    private var startTime: Date?
    private var timeStatusTimer: Timer?
    
    
    static var currentStatus: NEVPNStatus = .invalid {
        didSet {
            NotificationCenter.default.post(name: .vpnStatusDidChange, object: nil)
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(vpnStatusChanged), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        VPNManager.currentStatus = vpnManager.connection.status
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    func setupVPN(completion: @escaping (Bool) -> Void) {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Ошибка загрузки предпочтений VPN: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            let vpnProtocol = NEVPNProtocolIPSec()
            vpnProtocol.username = "vpnuser"
            vpnProtocol.serverAddress = "185.103.255.104"
            vpnProtocol.authenticationMethod = .sharedSecret
            
            let sharedSecretReference = KeychainHelper.saveToKeychain(data: "RJzDxhdsBZzSxK53UTCR", forKey: "VPNSharedSecret")
            let passwordReference = KeychainHelper.saveToKeychain(data: "Tfgv8rzBdFzCzbn2", forKey: "VPNPassword")
            
            if sharedSecretReference == nil || passwordReference == nil {
                print("Ошибка: Не удалось сохранить данные в Keychain")
                completion(false)
                return
            }
            
            vpnProtocol.sharedSecretReference = sharedSecretReference
            vpnProtocol.passwordReference = passwordReference
            vpnProtocol.useExtendedAuthentication = true
            vpnProtocol.disconnectOnSleep = false
            
            self.vpnManager.protocolConfiguration = vpnProtocol
            self.vpnManager.localizedDescription = "World VPN"
            self.vpnManager.isEnabled = true
            
            self.vpnManager.saveToPreferences { error in
                if let error = error {
                    print("Ошибка сохранения предпочтений VPN: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("VPN успешно настроен!")
                    completion(true)
                }
            }
        }
    }
    
    func startVPN(completion: @escaping (Bool) -> Void) {
        setupVPN { success in
            guard success else {
                print("Не удалось настроить VPN перед запуском")
                completion(false)
                return
            }
            
            do {
                try self.vpnManager.connection.startVPNTunnel()
                VPNManager.currentStatus = self.vpnManager.connection.status
                self.startTime = Date()  // Засекаем время подключения
                self.startTimeTimer()
                print("VPN подключен!")
                completion(true)
            } catch let error {
                print("Ошибка запуска VPN: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func stopVPN() {
        vpnManager.connection.stopVPNTunnel()
        self.stopTimeStatusTimer()
        self.startTime = nil
        print("VPN отключен!")
    }
    
    // Переключение VPN
    func toggleVPN() {
        if vpnManager.connection.status == .connected || vpnManager.connection.status == .connecting {
            stopVPN()
        } else {
            startVPN { success in
                if success {
                    print("VPN включен")
                    
                } else {
                    print("Не удалось включить VPN")
                }
            }
        }
    }
    
    // Обработка изменений статуса VPN
    @objc private func vpnStatusChanged() {
        VPNManager.currentStatus = vpnManager.connection.status
        print("Статус VPN изменился: \(VPNManager.currentStatus.rawValue)")
        
        // Когда VPN подключается, стартуем таймер
        if vpnManager.connection.status == .connected {
            self.startTime = Date()
            self.startTimeTimer()
        } else if vpnManager.connection.status == .disconnected {
            self.stopTimeStatusTimer()
        }
    }
    
    // Таймер для обновления времени подключения
    private func startTimeTimer() {
        timeStatusTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeStatus), userInfo: nil, repeats: true)
    }
    
    private func stopTimeStatusTimer() {
        timeStatusTimer?.invalidate()
        timeStatusTimer = nil
    }
    
    @objc private func updateTimeStatus() {
        guard let startTime = self.startTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime)
        let elapsedMinutes = Int(elapsedTime) / 60
        let elapsedSeconds = Int(elapsedTime) % 60
        
        // Отправляем уведомление с текущим временем
        NotificationCenter.default.post(name: .vpnTimeStatusDidChange, object: nil, userInfo: ["elapsedTime": (elapsedMinutes, elapsedSeconds)])
    }
    
    
    // Сохранение статуса VPN в App Group
        static func saveStatusToAppGroup(status: Int) {
            if let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.WorldVPN") {
                userDefaults.set(status, forKey: "vpnStatus")
                userDefaults.synchronize()
            }
        }
        
        // Загрузка статуса VPN из App Group
        static func loadStatusFromAppGroup() -> NEVPNStatus {
            if let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.WorldVPN"),
               let status = userDefaults.value(forKey: "vpnStatus") as? Int {
                return NEVPNStatus(rawValue: status) ?? .invalid
            }
            return .invalid
        }
    
}




class KeychainHelper {
    static func saveToKeychain(data: String, forKey key: String) -> Data? {
        guard let data = data.data(using: .utf8) else { return nil }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Удаляем старое значение, если оно существует
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            // Возвращаем данные, которые будут использоваться для `sharedSecretReference`
            let copyQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnPersistentRef as String: true
            ]
            
            var item: CFTypeRef?
            let copyStatus = SecItemCopyMatching(copyQuery as CFDictionary, &item)
            if copyStatus == errSecSuccess, let persistentRef = item as? Data {
                return persistentRef
            }
        }
        
        print("Keychain save error: \(status)")
        return nil
    }
}






extension Notification.Name {
    static let vpnStatusDidChange = Notification.Name("vpnStatusDidChange")
}

extension Notification.Name {
    static let vpnTimeStatusDidChange = Notification.Name("vpnTimeStatusDidChange")
}


extension Notification.Name {
    static let vpnTrafficDidChange = Notification.Name("vpnTrafficDidChange")
}
