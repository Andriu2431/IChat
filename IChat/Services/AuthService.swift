//
//  AuthService.swift
//  IChat
//
//  Created by Andrii Malyk on 13.09.2022.
//

import UIKit
import Firebase
import FirebaseAnalytics
import GoogleSignIn

// рейстрація та вхід користувача
class AuthService {
    
    static let shared = AuthService()
    
    private let auth = Auth.auth()
    
    // вхід
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void) {
        
        // перевіримо чи не пусті емал та пароль
        guard let email = email, let password = password else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        // метод логінить користувача
        auth.signIn(withEmail: email, password: password) { result, error in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    // кнопка рейстрації через гугл
    func googleLogin(user: GIDGoogleUser!, completion: @escaping (Result<User, Error>) -> Void) {

            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            // рейструємо юзера в Firebase
            Auth.auth().signIn(with: credential) { result, error in
                guard let result = result else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(result.user))
            }
        }
    
    // рейстрація
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping (Result<User, Error>) -> Void) {
        
        // перевіримо чи поля емейл та пароль заповнені - також метод isFilled перевірить на nil тому після нього можемо ставити !
        guard Validators.isFilled(email: email, password: password, confirmPassword: confirmPassword) else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        // перевіримо чи password == confirmPassword
        guard password!.lowercased() == confirmPassword!.lowercased() else {
            completion(.failure(AuthError.passwordNotMatched))
            return
        }
        
        // перевіряємо email на валідність
        guard Validators.isSimpleEmail(email!) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        // метод створює користувача
        auth.createUser(withEmail: email!, password: password!) { result, error in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
}
