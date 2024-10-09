//
//  MainViewModel.swift
//  project-name
//
//  Created by Владислав Жуков on 08.10.2024.
//

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
    
    func configureUser() {
        navigation.onUserConfiguration()
    }
}
