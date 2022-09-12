//
//  MChat.swift
//  IChat
//
//  Created by Andrii Malyk on 12.09.2022.
//

import UIKit

// це дані які будуть в одному item - це дані про чат в вкладці conversation
struct MChat: Hashable, Decodable {
    var username: String
    var userImageString: String
    var lastMessage: String
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.id == rhs.id
    }
}
