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
    
    // метод шукає по тому що ми ввели в search bar
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        let lowercasedFilter = filter.lowercased()
        return username.lowercased().contains(lowercasedFilter)
    }
}
