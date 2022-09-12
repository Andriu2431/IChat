//
//  SectionHeader.swift
//  IChat
//
//  Created by Andrii Malyk on 12.09.2022.
//

import UIKit

// реалізуємо наш хедер над секціями
class SectionHeader: UICollectionReusableView {
    
    static let reuseId = "SectionHeader"
    let title = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configurate(text: String, font: UIFont?, textColor: UIColor) {
        title.text = text
        title.textColor = textColor
        title.font = font
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
