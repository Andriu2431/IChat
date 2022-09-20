//
//  UIViewController + Extension.swift
//  IChat
//
//  Created by Andrii Malyk on 12.09.2022.
//

import UIKit

extension UIViewController {
    //метод конфігує контейнер
    func configure<T: SelfConfiguringCell, U: Hashable>(collectionView: UICollectionView,cellType: T.Type, with value: U, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else { fatalError("Unable to dequeue \(cellType)") }
        
        // настроюємо контейнер
        cell.configure(with: value)
        return cell
    }
}

extension UIViewController {
    // метод скриває клавіатурур по тапу
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
