//
//  UIImageView + Extension.swift
//  IChat
//
//  Created by Andrii Malyk on 08.09.2022.
//

import UIKit

extension UIImageView {
    
    convenience init(image: UIImage?, contentMode: UIView.ContentMode) {
        self.init()
        
        self.image = image
        self.contentMode = contentMode
    }
}
