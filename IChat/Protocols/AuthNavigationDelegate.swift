//
//  AuthNavigationDelegate.swift
//  IChat
//
//  Created by Andrii Malyk on 13.09.2022.
//

import Foundation

// делегат який буде тримати в собі контролери
protocol AuthNavigationDelegate: AnyObject {
    func toLoginVC()
    func toSignUpVC()
}
