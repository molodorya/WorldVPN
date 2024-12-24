//
//  ModelMap.swift
//  molodorya.vpn
//
//  Created by Nikita Molodorya on 21.09.2024.
//

import UIKit

class MessageView: UIView {
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Настройка фона
        backgroundColor = UIColor.secondarySystemBackground
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        clipsToBounds = true
        
        // Настройка текста
        messageLabel.textColor = .label
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Menlo", size: 14) // Установка шрифта Menlo
        messageLabel.numberOfLines = 0
        
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}
