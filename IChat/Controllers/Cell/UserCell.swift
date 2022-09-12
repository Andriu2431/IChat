//
//  UserCell.swift
//  IChat
//
//  Created by Andrii Malyk on 12.09.2022.
//

import UIKit

// контейнер юзерів поблизу
class UserCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "UserCell"
    let userImageView = UIImageView()
    let username = UILabel(text: "text", font: .laoSangamMN20())
    let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupConstarints()
        
        self.layer.cornerRadius = 6
        self.layer.shadowColor = #colorLiteral(red: 0.787740171, green: 0.787740171, blue: 0.787740171, alpha: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // для того щоб округлити ми і зробили containerView
        self.containerView.layer.cornerRadius = 6
        self.containerView.clipsToBounds = true
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let user: MUser = value as? MUser else { return }
        userImageView.image = UIImage(named: user.avatarStringURL)
        username.text = user.username
    }
    
    private func setupConstarints() {
        // translatesAutoresizingMaskIntoConstraints
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        username.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // add view
        addSubview(containerView)
        // додаємо на контейннер для того щоб округлити його потім
        containerView.addSubview(userImageView)
        containerView.addSubview(username)
        
        // constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            userImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            username.topAnchor.constraint(equalTo: userImageView.bottomAnchor),
            username.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            username.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            username.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: SwiftUI

import SwiftUI

struct UserChatProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = MainTabBarController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
