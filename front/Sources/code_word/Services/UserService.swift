//
//  File.swift
//  
//
//  Created by Владислав Жуков on 01.09.2024.
//

import SwiftUI

struct User: Codable {
    let id: String
    let name: String
    let icon: Int
}

protocol IUserService {
    var user: User? { get }
    
    func createUser(with name: String)
    func updateUser(name: String)
}

//final class UserService: IUserService {
//    
//    @AppStorage("app.vz.code.word.user.name.key") var userCache: String?
//    
//    private(set) var user: User?
//    
//    init() {
//        restore()
//    }
//    
//    func createUser(with name: String) {
//        user = User(
//            id: UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""),
//            name: name,
//            icon: 0
//        )
//        save()
//    }
//    
//    func updateUser(name: String) {
//        guard let id = user?.id else { return }
//        user = User(id: id, name: name, icon: user?.icon)
//        save()
//    }
//    
//    private func save() {
//        guard let user else { return }
//        //userCache = try? JSONEncoder().encode(user)
//        userCache = user.name
//    }
//    
//    private func restore() {
//        if let userCache {
//            self.user = User(
//                id: UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""),
//                name: userCache
//            )
//            //self.user = try? JSONDecoder().decode(User.self, from: userCache)
//        }
//    }
//}
