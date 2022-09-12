//
//  MUser.swift
//  IChat
//
//  Created by Andrii Malyk on 12.09.2022.
//

import UIKit

// це дані які будуть в одному item - це дані про юзера в вкладці people
struct MUser: Hashable, Decodable {
    var username: String
    var avatarStringURL: String
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
}
