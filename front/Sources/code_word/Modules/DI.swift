//
//  DI.swift
//  
//
//  Created by Владислав Жуков on 29.08.2024.
//

import Foundation

final class DI {
    
    static let shared: DI = DI()
    
    lazy var navigation = Navigation()
    lazy var network = Network()
    lazy var mainState = MainState()
    //lazy var userService: IUserService = UserService()
    lazy var socketService = SocketService()
    
    var user: User?
    var roomId: String?
    
    private init() {}
    
    func mainViewModel() -> MainViewModel {
        MainViewModel(
            navigation: navigation,
            network: network
        )
    }
    
    func roomViewModel() -> RoomViewModel {
        RoomViewModel(
            navigation: navigation,
            network: network,
            cmdService: CmdService(socketService: socketService),
            roomId: roomId!,
            user: user!
        )
    }
}

final class MainState {
    var user: User?
    var roomId: String?
}
