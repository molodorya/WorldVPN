//
//  ViewController.swift
//  molodorya.vpn
//
//  Created by Nikita Molodorya on 01.09.2024.
//


import UIKit
import NetworkExtension
import Foundation
 

class Main: UIViewController, UIScrollViewDelegate {
    
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
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundScroll: UIScrollView!
    
 
    
    // MARK: - Properties
    let controlVPN = VPNManager()
    private var messageView: MessageView?
    private var status = false
    private var vpnIndicatorView: UIView?
 
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotifications()
        fetchMessage()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture)

        // Настройка UIScrollView
        backgroundScroll.delegate = self
        backgroundScroll.minimumZoomScale = 0.5
        backgroundScroll.maximumZoomScale = 5.0
        backgroundScroll.showsHorizontalScrollIndicator = false
        backgroundScroll.showsVerticalScrollIndicator = false

        // Настройка карты
        guard let mapImage = UIImage(named: "WorldDark") else {
            fatalError("Изображение WorldDark не найдено")
        }
        backgroundView.image = mapImage
        backgroundView.isUserInteractionEnabled = true
        backgroundView.frame = CGRect(x: 0, y: 0, width: 3000, height: 2000)
        backgroundScroll.addSubview(backgroundView)
        backgroundScroll.contentSize = backgroundView.frame.size

        // Устанавливаем начальный масштаб и центрируем изображение
        let initialZoomScale: CGFloat = 0.7
        backgroundScroll.zoomScale = initialZoomScale

        let offsetX = max((backgroundScroll.contentSize.width * initialZoomScale - backgroundScroll.bounds.width) / 2, 0)
        let offsetY = max((backgroundScroll.contentSize.height * initialZoomScale - backgroundScroll.bounds.height) / 2, 0)
        backgroundScroll.contentOffset = CGPoint(x: offsetX, y: offsetY)

        // Добавляем точки на карту
        addPointsToMap()
        
        
    }
    
   
  
    func addPointsToMap() {
        // Координаты точек на карте
        let africaPoint = CGPoint(x: 1500, y: 1200)    // Пример координат точки в Африке
        let americaPoint = CGPoint(x: 500, y: 800)     // Пример координат точки в Америке
        let dubaiPoint = CGPoint(x: 1600, y: 1400)     // Координаты для Дубая
        let netherlandsPoint = CGPoint(x: 1200, y: 500) // Координаты для Нидерландов
        let moscowPoint = CGPoint(x: 1400, y: 600)     // Координаты для Москвы
        let istanbulPoint = CGPoint(x: 1350, y: 900)   // Координаты для Стамбула

        // Функция для добавления кнопки на карту
        func addButton(at point: CGPoint, color: UIColor, label: String) {
            let button = UIButton(frame: CGRect(x: point.x, y: point.y, width: 30, height: 30))
            button.backgroundColor = color
            button.layer.cornerRadius = 15
            button.setTitle("", for: .normal)
            button.addTarget(self, action: #selector(pointTapped(_:)), for: .touchUpInside)
            backgroundView.addSubview(button)
            button.accessibilityLabel = label
        }

        // Добавляем точки
        addButton(at: africaPoint, color: .blue, label: "Африка")
        addButton(at: americaPoint, color: .red, label: "Америка")
        addButton(at: dubaiPoint, color: .orange, label: "Дубай")
        addButton(at: netherlandsPoint, color: .purple, label: "Нидерланды")
        addButton(at: moscowPoint, color: .green, label: "Москва")
        addButton(at: istanbulPoint, color: .yellow, label: "Стамбул")
    }

    @objc func pointTapped(_ sender: UIButton) {
        if let label = sender.accessibilityLabel {
            print("\(label) выбрана")
        }
    }

        // Поддержка масштабирования
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return backgroundView
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
        timeStatus.alpha = 0
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground() // Прозрачный фон
            appearance.backgroundColor = UIColor.clear // Без цвета
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Белый текст заголовка

            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.isTranslucent = true // Делаем Navigation Bar прозрачным
        }
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
    
    // MARK: - Fetch Message / Message View
    private func fetchMessage() {
        guard let url = URL(string: "http://www.molodorya.ru/worldVPN.js") else { return }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    private func showMessageView(with message: String) {
        let lastMessage = UserDefaults.standard.string(forKey: "lastMessageKey")
        
        if message == lastMessage {
            print("Сообщение уже было показано: \(message)")
            return
        } else {
            print("Новое сообщение: \(message)")
            UserDefaults.standard.set(message, forKey: "lastMessageKey")
        }
        
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

    
    // MARK: - VPN Connection Animation
       // Функция для вычисления позиции точки на изображении карты по координатам
    func mapPointForCoordinates(latitude: Double, longitude: Double) -> CGPoint {
         // Размеры изображения карты
         let mapWidth = backgroundView.frame.size.width
         let mapHeight = backgroundView.frame.size.height
         
         // Минимальные и максимальные координаты (для карты мира)
         let minLatitude = -90.0
         let maxLatitude = 90.0
         let minLongitude = -180.0
         let maxLongitude = 180.0
         
         let x = (longitude - minLongitude) / (maxLongitude - minLongitude) * mapWidth
         let y = (1 - (latitude - minLatitude) / (maxLatitude - minLatitude)) * mapHeight
         
         return CGPoint(x: x, y: y)
     }
    
   
 
    
    
    
}

    
    
    
    
    
    
    
    // MARK: - Network Ping
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
    
    private func getDynamicIslandHeight() -> CGFloat {
        if #available(iOS 16.0, *) {
            return 50
        } else {
            return 0
        }
    }

