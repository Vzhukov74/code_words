//
//  UserConfiuratorView.swift
//
//
//  Created by Владислав Жуков on 29.08.2024.
//

import SwiftUI

final class UserConfiuratorViewModel: ObservableObject {
    
    @Published var avatarVM: AvatarViewModel = AvatarViewModel(
        type: PlayerAvatars.avt1,
        color: AppColor.blue,
        cells: PlayerAvatars.avt1.viewModel()
    )
    @Published var selectedAvatarIndex: Int = 1
    
    let avatars: [AvatarViewModel] = PlayerAvatars.allCases.compactMap { playerAvatar in
        AvatarViewModel(type: playerAvatar, color: AppColor.blue, cells: playerAvatar.viewModel())
    }
    
    func onSelectAvatar(index: Int) {
        avatarVM.type = avatars[index].type
        avatarVM.cells = avatars[index].cells
    }
}

struct UserConfiuratorView: View {
    let navigation: Navigation
    
    @StateObject var vm: UserConfiuratorViewModel = UserConfiuratorViewModel()
    
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
        VStack(spacing: 16) {
            AvatarView(vm: vm.avatarVM, space: 4, size: 16, radius: 4)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<vm.avatars.count, id: \.self) { index in
                        Button(action: { safe(index: index) }) {
                            avatarCell(avatarVM: vm.avatars[index])
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 64)
        }
    }
    
    @ViewBuilder
    func avatarCell(avatarVM: AvatarViewModel) -> some View {
        #if SKIP
        avatarVM.type.image()
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.red)
            .frame(width: 64, height: 64)
        #else
        AvatarView(vm: avatarVM, space: 1, size: 6, radius: 2)
        #endif
    }
    
    func readyHandler() {
        let user = User(id: userIdCache, name: userNameCache)
        DI.shared.user = user
        
        navigation.back()
    }
    
    func safe(index: Int) {
        #if !SKIP
        let renderer = ImageRenderer(content: AvatarView(vm: vm.avatars[index], space: 1, size: 6, radius: 2))

        if let uiImage = renderer.uiImage {
            if let data = uiImage.pngData() {
                    let filename = getDocumentsDirectory().appendingPathComponent("\(index).png")
                    try? data.write(to: filename)
                }
        }
        
        
        #endif
    }
}

#if !SKIP
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
#endif
