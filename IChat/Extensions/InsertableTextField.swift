//
//  InsertableTextField.swift
//  IChat
//
//  Created by Andrii Malyk on 12.09.2022.
//

import UIKit

// кастомний textField
class InsertableTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTextField()
    }
    
    private func setupTextField() {
        
        backgroundColor = .white
        placeholder = "Write something hare..."
        font = UIFont.systemFont(ofSize: 14)
        borderStyle = .none
        clearButtonMode = .whileEditing
        layer.cornerRadius = 18
        layer.masksToBounds = true
        
        // left
        let image = UIImage(systemName: "smiley")
        let imageView = UIImageView(image: image)
        imageView.setupColor(color: .lightGray)
        leftView = imageView
        leftView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        leftViewMode = .always
        
        // right
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Sent"), for: .normal)
        button.applyGradients(cornerRadius: 10)
        rightView = button
        rightView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        rightViewMode = .always
    }
    
    // відступ звідки буде початок тексту
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    // відступ плейсхолдера
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    // відступи з ліва від фото
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
    
    // відступи з права від фото
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x += -12
        return rect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: SwiftUI

import SwiftUI

struct TextFieldProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = ProfileViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
