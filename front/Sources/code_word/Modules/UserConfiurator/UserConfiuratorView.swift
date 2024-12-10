//
//  UserConfiuratorView.swift
//
//
//  Created by Владислав Жуков on 29.08.2024.
//

import SwiftUI

struct UserConfiuratorView: View {
    let navigation: Navigation
    
    @State var avatarVM: AvatarViewModel = AvatarViewModel(
        type: PlayerAvatars.avt1,
        color: AppColor.blue,
        cells: PlayerAvatars.avt1.viewModel()
    )
    @State var selectedAvatarIndex: Int = 0
    
    let avatars: [AvatarViewModel] = PlayerAvatars.allCases.compactMap { playerAvatar in
        AvatarViewModel(type: playerAvatar, color: AppColor.blue, cells: playerAvatar.viewModel())
    }

    @AppStorage("app.vz.code.word.user.name.key") var userNameCache: String = ""
    @AppStorage("app.vz.code.word.user.icon.key") var userIconCache: Int = 0
    
    init(navigation: Navigation) {
        self.navigation = navigation
        self.selectedAvatarIndex = userIconCache
        self.avatarVM.type = avatars[userIconCache].type
        self.avatarVM.cells = avatars[userIconCache].cells
    }
    
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
            AvatarView(vm: avatarVM, space: 4, size: 16, radius: 4)
                .frame(height: 180)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<avatars.count, id: \.self) { index in
                        Button(action: { safe(index: index) }) {
                            avatarCell(avatarVM: avatars[index])
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
        userIconCache = selectedAvatarIndex
//        let user = User(id: userIdCache, name: userNameCache, icon: selectedAvatarIndex)
//        DI.shared.user = user
        
        navigation.back()
    }
        
    func safe(index: Int) {
        userIconCache = index
        
        avatarVM.type = avatars[index].type
        avatarVM.cells = avatars[index].cells
        
//        let renderer = ImageRenderer(content: AvatarView(vm: avatars[index], space: 1, size: 6, radius: 2))
//        if let uiImage = renderer.uiImage {
//            if let data = uiImage.pngData() {
//                let filename = getDocumentsDirectory().appendingPathComponent("\(index).png")
//                try? data.write(to: filename)
//            }
//        }
    }
}

//func getDocumentsDirectory() -> URL {
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    return paths[0]
//}
