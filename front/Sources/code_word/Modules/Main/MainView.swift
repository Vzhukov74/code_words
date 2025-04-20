import SwiftUI
import Combine

struct MainView: View {
    
    @StateObject var vm: MainViewModel
    
    // Android can work with AppStorage only in view context (yeap, android it is shit)
    @AppStorage("app.vz.code.word.user.name.key") private var userNameCache: String = ""
    @AppStorage("app.vz.code.word.last.game.id.key") private var lastGameIdCache: String = ""
    @AppStorage("app.vz.code.word.user.icon.key") private var userIconCache: Int = 0
    
    @State var isLoading: Bool = false
    @State var error: String = ""
    @State var roomId: String = ""
    
    var body: some View {
        VStack {
            headerView
            
            btnsView
                .padding(.bottom, 36)
        }
        .onAppear { onAppear() }
        .onOpenURL { url in
            handleURL(url: url)
        }
    }
    
    private var headerView: some View {
        VStack {
            Spacer()
            Button(action: vm.configureUser) {
                VStack {
                    AvatarView(vm: PlayerAvatars.vm(by: userIconCache), space: 4, size: 25, radius: 4)
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
            
            if !roomId.isEmpty {
                AppMainButton(
                    title: "Вернуться",
                    action: { joinToRoom(id: roomId) },
                    color: AppColor.blue
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func onAppear() {
        userModel()
        if !lastGameIdCache.isEmpty {
            Task { @MainActor in
                if await vm.hasGame(id: lastGameIdCache) {
                    roomId = lastGameIdCache
                } else {
                    roomId = ""
                }
            }
        }
    }
    
    private func createRoom() {
        Task { @MainActor in
            isLoading = true
            userModel()
            do {
                let gameId = try await vm.createRoom(with: DI.shared.user!)
                isLoading = false
                joinToRoom(id: gameId)
            } catch {
                isLoading = false
                print(error.localizedDescription)
                showError()
            }
        }
    }
    
    private func userModel() {
        let id: String
        if UserDefaults.standard.string(forKey: "app.vz.code.word.user.id.key") != nil {
            id = UserDefaults.standard.string(forKey: "app.vz.code.word.user.id.key")!
        } else {
            id = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
            UserDefaults.standard.set(
                id,
                forKey: "app.vz.code.word.user.id.key"
            )
        }
 
        let user = User(id: id, name: userNameCache, icon: userIconCache)
        DI.shared.user = user
    }
    
    private func joinToRoom(id: String) {
        userModel()
        lastGameIdCache = id
        vm.joinToRoom(id: id, with: DI.shared.user!)
    }
    
    private func showError() {
        error = "Не получилось создать новую комнату"
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            error = ""
        }
    }
    
    private func handleURL(url: URL) {
        guard let gameId = url.pathComponents.last else { return }
        joinToRoom(id: gameId)
    }
}
