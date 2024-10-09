//
//  UserConfiuratorView.swift
//
//
//  Created by Владислав Жуков on 29.08.2024.
//

import SwiftUI

struct UserConfiuratorView: View {
    let navigation: Navigation
    
    let avatarVM: AvatarViewModel = AvatarViewModel(
        type: PlayerAvatars.avt1,
        color: AppColor.blue,
        cells: PlayerAvatars.avt1.viewModel()
    )
    @AppStorage("app.vz.code.word.user.name.key") var userNameCache: String = ""
    @AppStorage("app.vz.code.word.user.icon.key") var userIconCache: Int = 0
    @AppStorage("app.vz.code.word.user.id.key") var userIdCache: String = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                HStack {
                    Button(action: {navigation.back()}) {
                        Text("Назад")
                            .font(.title2)
                            .frame(height: 44)
                            .foregroundStyle(AppColor.main)
                    }
                    Spacer()
                }
                Text("Играть как")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title2)
                    .foregroundStyle(Color.black)
            }
            
            avatarView
            
            TextField("Имя", text: $userNameCache)
                .font(.title2)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 52)
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(AppColor.blue)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(Color.black)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundStyle(Color.black)
                                .offset(x: 2, y: 2)
                        }
                }

            AppMainButton(
                title: "Готово",
                action: readyHandler,
                color: AppColor.main
            )
            .disabled(userNameCache.isEmpty)
            Spacer()
        }
            .padding(Edge.Set.vertical, CGFloat(16))
            .padding(Edge.Set.horizontal, CGFloat(16))
    }
    
    private var avatarView: some View {
        HStack(spacing: 16) {
            AvatarView(vm: avatarVM, size: 16)
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<PlayerAvatars.allCases.count, id: \.self) { index in
                        Button(action: {}) {
                            AvatarView(vm: AvatarViewModel(type:  PlayerAvatars.allCases[index], color: AppColor.red, cells:  PlayerAvatars.allCases[index].viewModel()), size: 4)
                        }
                    }
                }
            }
        }
    }
    
    private func readyHandler() {
        let user = User(id: userIdCache, name: userNameCache)
        DI.shared.user = user
        
        navigation.userDidConfigure()
    }
}
