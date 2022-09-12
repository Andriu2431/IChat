//
//  SelfConfiguringCell.swift
//  IChat
//
//  Created by Andrii Malyk on 12.09.2022.
//

import Foundation

// протокол буде налаштовувати контейнер
protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}
