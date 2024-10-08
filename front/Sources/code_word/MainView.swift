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
            AvatarView(vm: PlayerAvatars.avt5.model())
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

struct AppMainButton: View {
    
    let title: String
    let action: () -> Void
    let color: Color
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(color)
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
        }
    }
}

enum AppColor {
    static let main = Color(red: 0.929, green: 0.690, blue: 0.290)
    static let blue = Color(red: 0.463, green: 0.514, blue: 0.733)
    static let red = Color(red: 0.871, green: 0.475, blue: 0.400)
}

enum PlayerAvatars: CaseIterable {
    case avt1
    case avt2
    case avt3
    case avt4
    case avt5
    case avt6
    case avt7
    case avt8
    case avt9
    case avt10
    case avt11
    case avt12
    case avt13
    case avt14
    case avt15
    case avt16
    case avt17
    case avt18
    case avt19
    case avt20
    
    func model() -> AvatarViewModel {
        AvatarViewModel(
            type: .avt1,
            color: AppColor.red,
            cells: viewModel()
        )
    }
    
    func viewModel() -> [[AvatarCellViewModel]] {
        var result: [[AvatarCellViewModel]] = [[]]
        
        let matrix = matrix()
        
        for row in matrix {
            var resultRow: [AvatarCellViewModel] = []
            for item in row {
                resultRow.append(AvatarCellViewModel(hasColor: item))
            }
            result.append(resultRow)
        }
        
        return result
    }
    
    private func matrix() -> [[Bool]] {
        switch self {
        case .avt1:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, true, true, false, false, true, true, false, false, false],
                [true, false, false, true, true, true, true, false, false, true, false],
                [true, false, true, true, true, true, true, true, false, true, false],
                [true, true, true, false, true, true, false, true, true, true, false],
                [false, true, true, true, true, true, true, true, true, false, false],
                [false, false, true, true, true, true, true, true, false, false, false],
                [false, false, true, false, false, false, false, true, false, false, false],
                [false, true, true, false, false, false, false, true, true, false, false],
            ]
        case .avt2:
            return [
                [false, false, false, false, false, false, false, false, false],
                [false, true, false, false, false, false, false, true, false],
                [false, false, true, false, false, false, true, false, false],
                [false, false, false, true, true, true, false, false, false],
                [false, true, true, true, true, true, true, true, false],
                [true, true, false, false, true, false, false, true, true],
                [true, true, true, true, true, true, true, true, true],
                [false, true, false, true, false, true, false, true, false],
                [true, false, true, false, false, false, true, false, true],
            ]
        case .avt3:
            return [
                [false, false, true, false, false, false, true, false, false],
                [false, false, true, true, true, true, true, false, false],
                [false, true, true, false, true, false, true, true, false],
                [true, true, true, true, true, true, true, true, true],
                [true, false, true, true, true, true, true, false, true],
                [true, false, true, true, true, true, true, false, true],
                [false, false, false, true, false, true, false, false, false],
                [false, false, true, true, false, true, true, false, false],
            ]
        case .avt4:
            return [
                [false, false, true, false, false, false, true, false, false],
                [false, false, false, true, false, true, false, false, false],
                [true, false, true, true, true, true, true, false, true],
                [true, true, true, false, true, false, true, true, true],
                [false, true, true, true, true, true, true, true, false],
                [false, true, false, true, false, true, false, true, false],
                [true, true, false, false, false, false, false, true, true],
            ]
        case .avt5:
            return [
                [false, true, false, false, false, false, true, false],
                [false, false, true, false, false, true, false, false],
                [false, false, false, true, true, false, false, false],
                [true, false, true, true, true, true, false, true],
                [true, true, true, true, true, true, true, true],
                [false, true, false, true, true, false, true, false],
                [false, false, true, true, true, true, false, false],
                [false, true, true, false, false, true, true, false],
            ]
        case .avt6:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt7:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt8:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt9:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt10:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt11:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt12:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt13:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt14:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt15:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt16:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt17:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt18:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt19:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        case .avt20:
            return [
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
                [false, false, false, false, false, false, false, false, false, false, false],
            ]
        }
    }
}

struct AvatarViewModel {
    let type: PlayerAvatars
    var color: Color
    var cells: [[AvatarCellViewModel]]
}

struct AvatarCellViewModel: Identifiable, Hashable {
    let id = UUID()
    let hasColor: Bool
}

struct AvatarView: View {
    
    let vm: AvatarViewModel
    
    private let columns = [
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4),
        GridItem(.fixed(25), spacing: 4)
    ]
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(vm.cells, id: \.self) { cell in
                HStack(spacing: 4) {
                    ForEach(cell, id: \.self) { cellVM in
                        cellView(cellVM: cellVM)
                    }
                }
            }
        }
//        LazyVGrid(columns: columns, spacing: 4) {
//            ForEach(vm.cells, id: \.self) { cell in
//                ForEach(cell, id: \.self) { cellVM in
//                    cellView(cellVM: cellVM)
//                }
//            }
//        }
    }
    
    private func cellView(cellVM: AvatarCellViewModel) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(cellVM.hasColor ? vm.color : Color.clear)
            .frame(width: 25, height: 25)
    }
}
