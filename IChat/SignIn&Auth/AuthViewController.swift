//
//  ViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 08.09.2022.
//

import UIKit
import Firebase
import GoogleSignIn

class AuthViewController: UIViewController {
    
    // MARK: UI element
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    
    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sing up with")
    let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    let emailButton = UIButton(title: "Email", titleColor: .white, backgroundColor: .buttonDark())
    let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgroundColor: .white, isShadow: true)
    
    // контролер рейстрації
    let signUpVC = SignUpViewController()
    // контроллер входу в апп
    let loginVC = LoginViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // додаємо логотип гугл
        googleButton.customizeGoogleButton()
        
        view.backgroundColor = .white
        setupConstraints()
        
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        
        signUpVC.delegate = self
        loginVC.delegate = self
    }
    
    // рейстрація через email
    @objc private func emailButtonTapped() {
        // переходимо на контроллер рейстрації
        present(signUpVC, animated: true, completion: nil)
    }
    
    // авторизація
    @objc private func loginButtonTapped() {
        // переходимо на контроллер входу
        present(loginVC, animated: true, completion: nil)
    }
    
    // рейстрація через гугл
    @objc private func googleSignInButtonTapped() {
        // пробуємо зарейтсрувати користувача, обробляємо відповіді від сервера
        AuthService.shared.googleLogin() { result in
            switch result {
            case .success(let user):
                // перевіримо чи користувач заповнив всі дані
                FirestoreService.shared.getUserData(user: user) { result in
                    switch result {
                    case .success(let muser):
                        self.showAlert(with: "Success!", and: "Good communication!") {
                            let mainTabBar = MainTabBarController(currentUser: muser)
                            // робимо його на повний екран
                            mainTabBar.modalPresentationStyle = .fullScreen
                            self.present(mainTabBar, animated: true, completion: nil)
                        }
                    case .failure(_):
                        self.showAlert(with: "Success!", and: "You are registered!") {
                            // після того як користувач натисне в алерті ок то спрацьовує present
                            self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error!", and: error.localizedDescription)
            }
        }
    }
}

// MARK: Setup constraints
extension AuthViewController {
    
    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        // castom view
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnboardLabel, button: loginButton)
        
        // stack view
        let stackView = UIStackView(arrangedSubviews: [googleView, emailView, loginView], axis: .vertical, spacing: 40)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // add view
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        // constraints
        logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 160).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
    }
}

// MARK: AuthNavigationDelegate

extension AuthViewController: AuthNavigationDelegate {
    
    func toLoginVC() {
        // коли хтось дьоргає цей метод то відкриється loginVC
        present(loginVC, animated: true, completion: nil)
    }
    
    func toSignUpVC() {
        // коли хтось дьоргає цей метод то відкриється signUpVC
        present(signUpVC, animated: true, completion: nil)
    }
}

// MARK: SwiftUI

// для того щоб можна було переглядати зміни як в swiftui
import SwiftUI

struct AuthVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = AuthViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
