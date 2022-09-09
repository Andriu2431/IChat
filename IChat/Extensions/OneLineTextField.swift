//
//  OneLineTextField.swift
//  IChat
//
//  Created by Andrii Malyk on 09.09.2022.
//

import UIKit

// кастомний текс філд для рейстрації - просто з нижньою полоскою
class OneLineTextField: UITextField {
    
    convenience init(font: UIFont? = .avenir20()) {
        self.init()
        
        self.font = font
        self.borderStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // лінія під текст філд
        var bottomView = UIView()
        bottomView = UIView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = .textFieldLight()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        bottomView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
