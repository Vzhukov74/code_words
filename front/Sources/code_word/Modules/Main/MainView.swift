import SwiftUI
import Combine

struct MainView: View {
    
    @StateObject var vm: MainViewModel
    
    // Android can work with AppStorage only in view context (yeap, android it is shit)
    @AppStorage("app.vz.code.word.user.name.key") private var userNameCache: String = ""
    @AppStorage("app.vz.code.word.user.icon.key") private var userIconCache: Int = 0
    @AppStorage("app.vz.code.word.user.id.key") private var userIdCache: String = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
    
    @State var isLoading: Bool = false
    @State var error: String = ""
    
    var body: some View {
        VStack {
            headerView
            
            btnsView
                .padding(.bottom, 36)
        }
        .onAppear { userModel() }
    }
    
    private var headerView: some View {
        VStack {
            Spacer()
            Button(action: vm.configureUser) {
                VStack {
                    AvatarView(vm: PlayerAvatars.avt16.model(), space: 4, size: 25, radius: 4)
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
            if !error.isEmpty {
                Text(error)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            AppMainButton(
                title: "Создать игру",
                action: { createRoom() },
                color: AppColor.main
            )
            .overlay {
                if isLoading {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.4))
                        .overlay {
                            ProgressView()
                        }
                }
            }
            
            AppMainButton(
                title: "Присоедениться",
                action: { vm.joinToRoom(id: "newgame") },
                color: AppColor.blue
            )
        }
        .padding(.horizontal, 16)
    }
    
    private func createRoom() {
        Task { @MainActor in
            isLoading = true
            do {
                try await vm.createAndJoinRoom(with: DI.shared.user!)
                isLoading = false
            } catch {
                isLoading = false
                print(error.localizedDescription)
                showError()
            }
        }
    }
    
    private func userModel() {
        let user = User(id: userIdCache, name: userNameCache/*, icon: userIconCache*/)
        DI.shared.user = user
    }
    
    private func showError() {
        error = "Не получилось создать новую комнату"
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            error = ""
        }
    }
}
