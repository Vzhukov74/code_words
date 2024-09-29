//
//  UserConfiuratorView.swift
//
//
//  Created by Владислав Жуков on 29.08.2024.
//

import SwiftUI

struct UserConfiuratorView: View {
    let navigation: Navigation
    
    @AppStorage("app.vz.code.word.user.name.key") var userNameCache: String = ""
    @AppStorage("app.vz.code.word.user.icon.key") var userIconCache: Int = 0
    @AppStorage("app.vz.code.word.user.id.key") var userIdCache: String = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
    
    var body: some View {
        VStack {
            TextField("Имя", text: $userNameCache)
            Button(action: readyHandler) {
                Text("Готово")
            }
            .disabled(userNameCache.isEmpty)
            Spacer()
        }
            .padding(Edge.Set.vertical, CGFloat(24))
            .padding(Edge.Set.horizontal, CGFloat(16))
    }
    
    private func readyHandler() {
        let user = User(id: userIdCache, name: userNameCache)
        DI.shared.user = user
        
        navigation.userDidConfigure()
    }
}
