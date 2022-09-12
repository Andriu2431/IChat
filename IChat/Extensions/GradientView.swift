//
//  GradientView.swift
//  IChat
//
//  Created by Andrii Malyk on 11.09.2022.
//

import UIKit
// визнечення точок звідки куди
enum Point {
    case topLeading
    case leading
    case bottomLeading
    case top
    case center
    case bottom
    case topTrailing
    case trailing
    case bottomTrailing

    var point: CGPoint {
        switch self {
        case .topLeading:
            return CGPoint(x: 0, y: 0)
        case .leading:
            return CGPoint(x: 0, y: 0.5)
        case .bottomLeading:
            return CGPoint(x: 0, y: 1.0)
        case .top:
            return CGPoint(x: 0.5, y: 0)
        case .center:
            return CGPoint(x: 0.5, y: 0.5)
        case .bottom:
            return CGPoint(x: 0.5, y: 1.0)
        case .topTrailing:
            return CGPoint(x: 1.0, y: 0.0)
        case .trailing:
            return CGPoint(x: 1.0, y: 0.5)
        case .bottomTrailing:
            return CGPoint(x: 1.0, y: 1.0)
        }
    }
}

// це універсальний клас для настройки градіетну
class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    // для того щоб міняти можна було кольора з інтерфейст білдера
    @IBInspectable private var startColor: UIColor? {
        didSet {
        setupGradientColor(startColor: startColor, endColor: endColor)
        }
    }
    
    @IBInspectable private var endColor: UIColor? {
        didSet {
        setupGradientColor(startColor: startColor, endColor: endColor)
        }
    }
    
    // якщо кодом будемо створювати
    init(from: Point, to: Point, startColor: UIColor?, endColor: UIColor?) {
        self.init()
        setupGradient(from: from, to: to, startColor: startColor, endColor: endColor)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // метод буде реалізовувати градіент
    private func setupGradient(from: Point, to: Point, startColor: UIColor?, endColor: UIColor?) {
        self.layer.addSublayer(gradientLayer)
        setupGradientColor(startColor: startColor, endColor: endColor)
        // задаємо позиції
        gradientLayer.startPoint = from.point
        gradientLayer.endPoint = to.point
    }
    
    // метод настроює кольора
    private func setupGradientColor(startColor: UIColor?, endColor: UIColor?) {
        if let startColor = startColor, let endColor = endColor {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
    
    // це для інтерфейс білдера
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient(from: .leading, to: .trailing, startColor: startColor, endColor: endColor)
    }
}
