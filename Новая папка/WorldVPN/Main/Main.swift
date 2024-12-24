//
//  ViewController.swift
//  molodorya.vpn
//
//  Created by Nikita Molodorya on 01.09.2024.
//

import UIKit
import NetworkExtension
import Foundation
import CoreGraphics

class Main: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryCity: UILabel!
    @IBOutlet weak var countryPing: UILabel!
    @IBOutlet weak var countrySelect: UIButton!
    @IBOutlet weak var timeStatus: UILabel!
    @IBOutlet weak var connect: UIButton!
    
    @IBOutlet weak var serverLocationView: UIView!
    
    
    // MARK: - Properties
    let controlVPN = VPNManager()
    private var messageView: MessageView?
    private var status = false
 
    
    
    // Устанавливаем размеры карты
    let mapWidth: CGFloat = 1400
    let mapHeight: CGFloat = 1100
    
    // Задаем ограничения для движения
    let maxX: CGFloat = 1600 // максимально допустимая позиция по X
    let minX: CGFloat = -200 // минимально допустимая позиция по X
    let maxY: CGFloat = 900  // максимально допустимая позиция по Y
    let minY: CGFloat = -200 // минимально допустимая позиция по Y
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesturesBackground()
        setupNotifications()
        fetchMessage()
        setupAnimationUI()
         
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        print("Координаты нажатия: x = \(location.x), y = \(location.y)")
    }

    // MARK: - UI Setup
    private func setupUI() {
        updateVPNButton()
        
        countryFlag.layer.cornerRadius = 5
        [countryView, connect].forEach { view in
            view.layer.cornerRadius = 20
        }
        
        updateImageForCurrentTheme()
        timeStatus.alpha = 0
    }
    
    private func setupGesturesBackground() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        backgroundImage.isUserInteractionEnabled = true
        backgroundImage.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        backgroundImage.addGestureRecognizer(pinchGesture)
    }
    
    
   
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateVPNButton), name: .vpnStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimeStatus(_:)), name: .vpnTimeStatusDidChange, object: nil)
    }

    // MARK: - Actions
    @IBAction func countrySelect(_ sender: UIButton) {}
    
    @IBAction func connect(_ sender: UIButton) {
        controlVPN.toggleVPN()
        status.toggle()
        
        UIView.animate(withDuration: 1) {
            self.timeStatus.alpha = self.status ? 1 : 0
        }
    }

    // MARK: - Helper Methods
    private func updateImageForCurrentTheme() {
        backgroundImage.image = UIImage(named: "WorldDark")
    }
    
    @objc private func updateVPNButton() {
        let status = VPNManager.currentStatus
        let statusInfo = getVPNButtonStatus(for: status)
        configureVPNButton(with: statusInfo)
        
        checkPingToServer { ping in
            self.countryPing.text = "\(ping) мс"
        }
    }
    
    private func getVPNButtonStatus(for status: NEVPNStatus) -> (title: String, color: UIColor, font: UIFont) {
        switch status {
        case .connected:
            return ("Отключить VPN", .systemRed, .boldSystemFont(ofSize: 16))
        case .connecting, .reasserting:
            return ("Подключение...", .systemYellow, .boldSystemFont(ofSize: 16))
        case .disconnected, .invalid:
            return ("Включить VPN", .systemGreen, .boldSystemFont(ofSize: 16))
        case .disconnecting:
            return ("Отключение...", .systemOrange, .boldSystemFont(ofSize: 16))
        @unknown default:
            return ("Неизвестный статус", .systemGray, .boldSystemFont(ofSize: 16))
        }
    }
    
    private func configureVPNButton(with statusInfo: (title: String, color: UIColor, font: UIFont)) {
        connect.setTitle(statusInfo.title, for: .normal)
        connect.backgroundColor = statusInfo.color
        connect.titleLabel?.font = statusInfo.font
    }

    // MARK: - Time Status
    @objc func updateTimeStatus(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let elapsedTime = userInfo["elapsedTime"] as? (Int, Int) {
            let minutes = elapsedTime.0
            let seconds = elapsedTime.1
            timeStatus.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // MARK: - Gestures
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
             
             if let draggedView = sender.view {
                 draggedView.center = CGPoint(x: draggedView.center.x + translation.x,
                                              y: draggedView.center.y + translation.y)
             }
             
             sender.setTranslation(.zero, in: view)
             
             // Когда панорамирование завершено, добавим эффект баунс
             if sender.state == .ended || sender.state == .cancelled {
                 addBounceEffectForPosition()
             }
    }
    
    private func addBounceEffectForPosition() {
           if let view = backgroundImage {
               let bounds = view.bounds
               
               var newCenterX = view.center.x
               var newCenterY = view.center.y
               
               // Ограничиваем перемещение по оси X (по ширине)
               if view.center.x < minX {
                   newCenterX = minX
               } else if view.center.x > maxX {
                   newCenterX = maxX
               }
               
               // Ограничиваем перемещение по оси Y (по высоте)
               if view.center.y < minY {
                   newCenterY = minY
               } else if view.center.y > maxY {
                   newCenterY = maxY
               }
               
               // Анимация баунса для осей X и Y
               UIView.animate(withDuration: 0.3, animations: {
                   view.center = CGPoint(x: newCenterX, y: newCenterY)
               })
           }
       }
    
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        // Получаем текущий масштаб
              let scale = sender.scale
              
              // Масштабируем изображение
              if let view = sender.view {
                  view.transform = view.transform.scaledBy(x: scale, y: scale)
                  sender.scale = 1.0 // Сбросим масштаб после применения
              }
              
              // Когда жест завершен, проверим и добавим эффект "баунс"
              if sender.state == .ended || sender.state == .cancelled {
                  addBounceEffectForScale()
              }
    }
    
    
    private func addBounceEffectForScale() {
        if let view = backgroundImage {
                  let currentScale = view.transform.a // Получаем текущий масштаб (так как это CGAffineTransform)
                  
                  var newScale: CGFloat = currentScale
                  
                  // Устанавливаем минимальный и максимальный масштаб
                  if currentScale < 0.5 {
                      newScale = 0.5
                  } else if currentScale > 3.0 {
                      newScale = 3.0
                  }
                  
                  if newScale != currentScale {
                      UIView.animate(withDuration: 0.3, animations: {
                          self.backgroundImage.transform = CGAffineTransform(scaleX: newScale, y: newScale)
                      })
                  }
              }
    }

    // MARK: - Fetch Message
    private func fetchMessage() {
        guard let url = URL(string: "http://www.molodorya.ru/worldVPN.js") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Ошибка загрузки: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                return
            }
            
            self.handleMessageResponse(data)
        }
        task.resume()
    }
    
    private func handleMessageResponse(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
               let message = json["Message"] {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showMessageView(with: message)
                }
            }
        } catch {
            print("Ошибка парсинга JSON: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Background Animation
    private func setupAnimationUI() {
        updateVPNButton()
        
        serverLocationView.layer.cornerRadius = 5
        serverLocationView.backgroundColor = .green
        serverLocationView.layer.masksToBounds = true
        
     
        countryFlag.layer.cornerRadius = 5
        [countryView, connect].forEach { view in
            view.layer.cornerRadius = 20
        }
        
        updateImageForCurrentTheme()
        timeStatus.alpha = 0
    }
    
    
   
    
    // MARK: - Message View
    private func showMessageView(with message: String) {
        let messageView = MessageView()
        messageView.configure(with: message)
        self.messageView = messageView
        
        let dynamicIslandHeight = getDynamicIslandHeight()
        messageView.frame = CGRect(
            x: (view.frame.width - 120) / 2,
            y: view.safeAreaInsets.top - 85,
            width: 120,
            height: dynamicIslandHeight
        )
        messageView.layer.cornerRadius = dynamicIslandHeight / 2
        messageView.clipsToBounds = true
        view.addSubview(messageView)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissMessageView))
        swipeGesture.direction = .up
        messageView.addGestureRecognizer(swipeGesture)
        
        UIView.animate(withDuration: 0.5) {
            messageView.frame = CGRect(
                x: 16,
                y: self.view.safeAreaInsets.top,
                width: self.view.frame.width - 32,
                height: 80
            )
            messageView.layer.cornerRadius = 20
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.dismissMessageView()
            }
        }
    }
    
    @objc private func dismissMessageView() {
        guard let messageView = self.messageView else { return }
        
        UIView.animate(withDuration: 0.5) {
            messageView.frame = CGRect(
                x: (self.view.frame.width - 120) / 2,
                y: self.view.safeAreaInsets.top - 85,
                width: 120,
                height: 35
            )
            messageView.layer.cornerRadius = 35 / 2
        } completion: { _ in
            messageView.removeFromSuperview()
            self.messageView = nil
        }
    }

    // MARK: - Network
    func checkPingToServer(completion: @escaping (String) -> Void) {
        let url = URL(string: "http://www.molodorya.ru")!
        let startTime = Date()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка при пинге: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Ошибка при пинге: \(error.localizedDescription)")
                }
                return
            }
            
            let timeInterval = Date().timeIntervalSince(startTime)
            DispatchQueue.main.async {
                completion(String(format: "%.0f", timeInterval * 1000 + 15))
            }
        }
        task.resume()
    }
    
    func measurePingToServer(serverAddress: String, completion: @escaping (Double) -> Void) {
        guard let url = URL(string: "http://\(serverAddress)") else {
            print("Неверный URL")
            return
        }
        
        let startTime = Date()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка при запросе: \(error.localizedDescription)")
                completion(-1)
                return
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            DispatchQueue.main.async {
                completion(elapsedTime * 1000)
            }
        }
        
        task.resume()
    }
    
    private func getDynamicIslandHeight() -> CGFloat {
        if #available(iOS 16.0, *) {
            return 50
        } else {
            return 0
        }
    }
}
