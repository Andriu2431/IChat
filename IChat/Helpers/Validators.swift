//
//  Validators.swift
//  IChat
//
//  Created by Andrii Malyk on 13.09.2022.
//

import Foundation

// клас для перевірки введення імейлу та всякого різного
class Validators {
    
    // перевіряємо чи заповнені всі поля рейстрації нового юзера
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let password = password,
              let confirmPassword = confirmPassword,
              let email = email,
              password != "",
              confirmPassword != "",
              email != "" else {
            return false
        }
        return true
    }
    
    // перевіримо email на валідність - це стандартний метод з нету
    static func isSimpleEmail(_ email: String) -> Bool {
        let emailRegEx = "^.+@.+\\..{2,}$"
        return check(text: email, regEx: emailRegEx)
    }
    
    private static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
    }
}
