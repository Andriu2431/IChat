//
//  LoginViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 09.09.2022.
//

import UIKit

// екран входу в програму
class LoginViewController: UIViewController {
    
    // Label
    let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir26())
    let loginWithLabel = UILabel(text: "Login with")
    let orLabel = UILabel(text: "or")
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let needAnAccountLabel = UILabel(text: "Need an account?")
    
    // Button
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    let loginButton = UIButton(title: "Login", titleColor: .white, backgroundColor: .buttonDark())
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SignUp", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    // delegate
    weak var delegate: AuthNavigationDelegate?
    
    // TextFild
    let emailTextFild = OneLineTextField(font: .avenir20())
    let passwordTextFild = OneLineTextField(font: .avenir20())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // додаємо логотип гугл
        googleButton.customizeGoogleButton()
        
        view.backgroundColor = .white
        setupConstraints()
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    // авторизація користувача
    @objc private func loginButtonTapped() {
        // викликємо метод який перевіряє чи користувач зарейстрований
        AuthService.shared.login(email: emailTextFild.text!, password: passwordTextFild.text!) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Success!", and: "You are authorized!") {
                    // перевіримо чи користувач заповнив всі дані
                    FirestoreService.shared.getUserData(user: user) { result in
                        switch result {
                        case .success(let muser):
                            let mainTabBar = MainTabBarController(currentUser: muser)
                            // роббимо його на повний екран
                            mainTabBar.modalPresentationStyle = .fullScreen
                            // якщо користувач заповнив всі дані то відкриємо йому MainTabBarController
                            self.present(mainTabBar, animated: true, completion: nil)
                        case .failure(_):
                            self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error!", and: error.localizedDescription)
            }
        }
    }
    
    // перехід на singUpVC
    @objc private func signUpButtonTapped() {
        // закриваємо контроллер на якому ми находимось
        self.dismiss(animated: true) {
            // як тільки закриється контроллер login відкриваємо signUp
            self.delegate?.toSignUpVC()
        }
    }
}

// MARK: Setup constraints
extension LoginViewController {
    
    private func setupConstraints() {
        let loginWithView = ButtonFormView(label: loginWithLabel, button: googleButton)
        
        // stack view
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextFild],
                                         axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextFild],
                                            axis: .vertical, spacing: 0)
        
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [
            loginWithView, orLabel, emailStackView, passwordStackView, loginButton
        ],
                                    axis: .vertical, spacing: 40)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton],
                                          axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        // translatesAutoresizingMaskIntoConstraints
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // add view
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        // constraints
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}


// MARK: SwiftUI

import SwiftUI

struct LoginVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = LoginViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
