//
//  SegmentedControl + Extension.swift
//  IChat
//
//  Created by Andrii Malyk on 09.09.2022.
//

import UIKit

extension UISegmentedControl {
    
    convenience init(firs: String, second: String) {
        self.init()
        self.insertSegment(withTitle: firs, at: 0, animated: true)
        self.insertSegment(withTitle: second, at: 1, animated: true)
        self.selectedSegmentIndex = 0
    }
}
