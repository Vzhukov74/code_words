import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
    
    @Published var isShowUserConfiurator: Bool = false
    @Published var user: User?
    
    private let navigation: Navigation
    private let userService: IUserService
    private var cancellable = Set<AnyCancellable>()
    
    init(navigation: Navigation, userService: IUserService) {
        self.navigation = navigation
        self.userService = userService
        
        self.user = userService.user
    }
    
    func createRoom(userName: String, userId: String, userIcon: Int) {
        if userName.isEmpty || userId.isEmpty /*|| userIcon == 0*/ {
            navigation.onUserConfiguration()
        } else {
            let user = User(id: userId, name: userName)
            DI.shared.user = user
            navigation.createNewRoom()
        }
    }
    
    func joinToRoom(userName: String, userId: String, userIcon: Int) {
        if userName.isEmpty || userId.isEmpty /*|| userIcon == 0*/ {
            navigation.onUserConfiguration()
        } else {
            let user = User(id: userId, name: userName)
            DI.shared.user = user
            DI.shared.roomId = "d681c905377245ce8d6898e6c2b6e3bc"
            navigation.joinToRoom()
        }
    }
}

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
            Text(userNameCache)
            Spacer()
        }
    }
    
    private var btnsView: some View {
        VStack(spacing: 20) {
            Button(action: {vm.createRoom(userName: userNameCache, userId: userIdCache, userIcon: userIconCache)}) {
                Text("Создать игру")
            }
            Button(action: {vm.joinToRoom(userName: userNameCache, userId: userIdCache, userIcon: userIconCache)}) {
                Text("Присоедениться")
            }
        }
    }
}
