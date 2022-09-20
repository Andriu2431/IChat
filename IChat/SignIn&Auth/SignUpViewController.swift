//
//  SignUpViewController.swift
//  IChat
//
//  Created by Andrii Malyk on 09.09.2022.
//

import UIKit

// контроллер рейстрації
class SignUpViewController: UIViewController {
    
    // Label
    let welcomeLabel = UILabel(text: "Good to see you!", font: .avenir26())
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let confirmPasswordLabel = UILabel(text: "Confirm password")
    let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    // TextFild
    let emailTextFild = OneLineTextField(font: .avenir20())
    let passwordTextFild = OneLineTextField(font: .avenir20())
    let confirmPasswordTextFild = OneLineTextField(font: .avenir20())
    
    //Button
    let signUpButton = UIButton(title: "Sign up", titleColor: .white, backgroundColor: .buttonDark(), cornerRadius: 4)
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    // delegate
    weak var delegate: AuthNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.hideKeyboardWhenTappedAround()
        
        setupConstraints()
        
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    
    // рейстрація користувача
    @objc private func signUpButtonTapped() {
        // метод рейструє користувача
        AuthService.shared.register(email: emailTextFild.text,
                                    password: passwordTextFild.text,
                                    confirmPassword: confirmPasswordTextFild.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Success!", and: "You are registered!") {
                    // після того як користувач натисне в алерті ок то спрацьовує present
                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAlert(with: "Error!", and: error.localizedDescription)
            }
        }
    }
    
    // перехід на loginVC
    @objc private func loginButtonTapped() {
        // закриваємо контроллер на якому ми находимось
        self.dismiss(animated: true) {
            // як тільки закриється контроллер signUp відкриваємо login
            self.delegate?.toLoginVC()
        }
    }
}

// MARK: Setup constraints
extension SignUpViewController {
    
    private func setupConstraints() {
        // stack view
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextFild], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextFild], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmPasswordTextFild], axis: .vertical, spacing: 0)
        
        signUpButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [
            emailStackView, passwordStackView, confirmPasswordStackView, signUpButton
        ], axis: .vertical, spacing: 40)
        
        loginButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnboardLabel, loginButton], axis: .horizontal, spacing: 10)
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
        if view.frame.height < 700 {
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        } else {
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130).isActive = true
        }

        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 40),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}



// MARK: SwiftUI

import SwiftUI

struct SignUpVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = SignUpViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}


extension UIViewController {
    
    func showAlert(with title: String, and massage: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
