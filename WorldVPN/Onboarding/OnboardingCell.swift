//
//  OnboardingCell.swift
//  WorldVPN
//
//  Created by Nikita Molodorya on 25.12.2024.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    
    static let identifier = "OnboardingCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
         
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFit
        labelView.textAlignment = .center
        descriptionView.textColor = .gray
    }
}




/*
  Custom UIPageControl
 
 class CustomPageControl: UIView {
     
     var dots: [UIView] = []
     var currentIndex: Int = 0 {
         didSet {
             updateDots()
         }
     }
     
     var numberOfPages: Int = 0 {
         didSet {
             setupDots()
         }
     }
     
     private func setupDots() {
         dots.forEach { $0.removeFromSuperview() }
         dots = []
         
         let stackView = UIStackView()
         stackView.axis = .horizontal
         stackView.spacing = 8
         stackView.translatesAutoresizingMaskIntoConstraints = false
         addSubview(stackView)
         
         NSLayoutConstraint.activate([
             stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
             stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
         ])
         
         for _ in 0..<numberOfPages {
             let dot = UIView()
             dot.layer.cornerRadius = 4
             dot.backgroundColor = .gray
             dot.translatesAutoresizingMaskIntoConstraints = false
             dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
             dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
             stackView.addArrangedSubview(dot)
             dots.append(dot)
         }
         updateDots()
     }
     
     private func updateDots() {
         for (index, dot) in dots.enumerated() {
             UIView.animate(withDuration: 0.3) {
                 if index == self.currentIndex {
                     dot.backgroundColor = .blue
                     dot.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                 } else {
                     dot.backgroundColor = .gray
                     dot.transform = .identity
                 }
             }
         }
     }
 }
 
 
 */
