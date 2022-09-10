//
//  ActiveChatCell.swift
//  IChat
//
//  Created by Andrii Malyk on 10.09.2022.
//

import UIKit

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure(with value: MChat)
}

// контейнер активних чатів
class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseId: String = "ActiveChatCell"
    
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User name", font: .laoSangamMN20())
    let lastMassege = UILabel(text: "How are you?", font: .laoSangamMN18())
    let gradientView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupConstraints()
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    // метод заповнює реальними данними контенер
    func configure(with value: MChat) {
        friendImageView.image = UIImage(named: value.userImageString)
        friendName.text = value.username
        lastMassege.text = value.lastMessage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Setup constraints
extension ActiveChatCell {
    // констрейни
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        lastMassege.translatesAutoresizingMaskIntoConstraints = false
        
        friendImageView.backgroundColor = .systemYellow
        gradientView.backgroundColor = .orange
        
        addSubview(friendImageView)
        addSubview(gradientView)
        addSubview(friendName)
        addSubview(lastMassege)
    
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 78),
            friendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            lastMassege.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            lastMassege.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMassege.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 78),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
}


// MARK: SwiftUI

import SwiftUI

struct ActiveChatProvider: PreviewProvider {
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
