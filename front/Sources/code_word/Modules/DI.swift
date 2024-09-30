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
    lazy var userService: IUserService = UserService()
    lazy var socketService = SocketService()
    
    var user: User?
    var roomId: String?
    
    private init() {}
    
    func mainViewModel() -> MainViewModel {
        MainViewModel(
            navigation: navigation,
            userService: userService
        )
    }
    
    func newRoomConfiuratorViewModel() -> NewRoomConfiuratorViewModel {
        NewRoomConfiuratorViewModel(
            navigation: navigation,
            network: network,
            user: user!
        )
    }
}

final class MainState {
    var user: User?
    var roomId: String?
}

/*
 final class DI {
     
     static let shared: DI = DI()
     
     private lazy var navigation = Navigation()
     private lazy var network = Network()
     private lazy var mainState = MainState()
     
     private init() {}
     
     func service() -> Navigation {
         navigation
     }
     
     func service() -> Network {
         network
     }
     
     func service() -> MainState {
         mainState
     }
     
     func vm() -> NewRoomConfiuratorViewModel {
         NewRoomConfiuratorViewModel(
             navigation: service(), //Skip is unable to disambiguate this function call. Consider differentiating your functions with unique parameter labels
             network: service(),
             user: mainState.user!
         )
     }
     
     func vm() -> UserConfiuratorViewModel {
         UserConfiuratorViewModel(
             navigation: service(),
             mainState: service()
         )
     }
 }

 final class MainState {
     var user: User?
     var roomId: String?
 }
 */
