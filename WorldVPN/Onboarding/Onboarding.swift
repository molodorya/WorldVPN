//
//  Onboarding.swift
//  WorldVPN
//
//  Created by Nikita Molodorya on 25.12.2024.
//


import UIKit

class Onboarding: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    private let items = [
        
        ("onboard_1", "100% Безопасный и надежный", "Соединение абсолютно безопасное, поскольку трафик идет через зашифрованный канал"),
        
        ("noImage", "Высокоскоростные сервера", "У нас одни из лучших серверовов с высокой скоростью соединения"),
        
        ("onboard_3", "Без рекламы", "Абсолютно. Не тратьте драгоценное время на просмотр рекламы")
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка CollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true // Включаем постраничное пролистывание
        
        // Настройка PageControl
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        
        // Настройка кнопки "Next"
//        nextButton.setTitle("Next", for: .normal)
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        nextButton.layer.cornerRadius = 30
    }
    
    // MARK: - CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        let item = items[indexPath.item]
        cell.imageView.image = UIImage(named: item.0)
        cell.labelView.text = item.1
        cell.descriptionView.text = item.2
        return cell
    }
    
    // MARK: - CollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Устанавливаем размер ячейки равным размеру CollectionView
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Убираем отступы между ячейками
        return 0
    }
    
    // MARK: - ScrollView Delegate (Для управления PageControl)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = currentIndex
    }
    
    // MARK: - Button Actions
    
    @objc func nextButtonTapped() {
        let currentIndex = pageControl.currentPage
        let nextIndex = currentIndex + 1
        
        if nextIndex < items.count {
            let indexPath = IndexPath(item: nextIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = nextIndex
        } else {
            print("Onboarding завершен")
            // Действие после завершения
        }
    }
}
