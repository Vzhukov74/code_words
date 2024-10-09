import SwiftUI
import Combine

struct MainView: View {
    
    @StateObject var vm: MainViewModel

    // Android can work with AppStorage only in view context (yeap, android it is shit)
    @AppStorage("app.vz.code.word.user.name.key") var userNameCache: String = ""
    @AppStorage("app.vz.code.word.user.icon.key") var userIconCache: Int = 0
    @AppStorage("app.vz.code.word.user.id.key") var userIdCache: String = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
    
    var body: some View {
        VStack {
            headerView
            
            btnsView
                .padding(.bottom, 36)
        }
    }
    
    private var headerView: some View {
        VStack {
            Spacer()
            Button(action: vm.configureUser) {
                VStack {
                    AvatarView(vm: PlayerAvatars.avt16.model(), size: 25)
                    Text(userNameCache)
                        .font(Font.title)
                        .foregroundStyle(AppColor.red)
                }
                    .padding(16)
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(24)))
            }
            Spacer()
        }
    }
    
    private var btnsView: some View {
        VStack(spacing: 20) {
            AppMainButton(
                title: "Создать игру",
                action: {vm.createRoom(userName: userNameCache, userId: userIdCache, userIcon: userIconCache)},
                color: AppColor.main
            )
            AppMainButton(
                title: "Присоедениться",
                action: {vm.joinToRoom(userName: userNameCache, userId: userIdCache, userIcon: userIconCache)},
                color: AppColor.blue
            )
        }
        .padding(.horizontal, 16)
    }
}
