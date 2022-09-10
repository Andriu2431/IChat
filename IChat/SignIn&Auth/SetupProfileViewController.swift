//
//  SetupProfileViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 09.09.2022.
//

import UIKit

class SetupProfileViewController: UIViewController {
    
    // Label
    let welcomeLabel = UILabel(text: "Set up profile!", font: .avenir26())
    let fullNameLabel = UILabel(text: "Full name")
    let aboutMeLabel = UILabel(text: "About me")
    let sexLabel = UILabel(text: "Sex")
    
    // TextFild
    let fullNameTextFild = OneLineTextField(font: .avenir20())
    let aboutMeTextFild = OneLineTextField(font: .avenir20())
    
    // Button
    let goToChatsButton = UIButton(title: "Go to chats!", titleColor: .white, backgroundColor: .buttonDark(), cornerRadius: 4)
    
    let fullImageView = AddPhotoView()
    let sexSegmentedControl = UISegmentedControl(firs: "Mail", second: "Femail")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
    }
}

// MARK: Setup constraints
extension SetupProfileViewController {
    private func setupConstraints() {
        
        // stack view
        let fillNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextFild], axis: .vertical, spacing: 0)
        let aboutMeStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextFild], axis: .vertical, spacing: 0)
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControl], axis: .vertical, spacing: 12)
        
        goToChatsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [
            fillNameStackView, aboutMeStackView, sexStackView, goToChatsButton],
                                    axis: .vertical, spacing: 40)
        
        // translatesAutoresizingMaskIntoConstraints
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // add view
        view.addSubview(welcomeLabel)
        view.addSubview(fullImageView)
        view.addSubview(fullImageView)
        view.addSubview(stackView)
        
        // constraints
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            fullImageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            fullImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: fullImageView.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

// MARK: SwiftUI

import SwiftUI

struct SetupProfileVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = SetupProfileViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
