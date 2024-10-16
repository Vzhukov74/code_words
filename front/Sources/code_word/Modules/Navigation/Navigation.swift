//
//  File.swift
//  
//
//  Created by Владислав Жуков on 29.08.2024.
//

import SwiftUI

final class Navigation: ObservableObject {
    enum Destination {
        case joinToRoom
        case userConfiguration
    }
    
    @Published var path: [Destination] = []
    
    func back() {
        guard !path.isEmpty else { return }
        _ = path.popLast()
    }
    
    func onRoot() {
        path = []
    }
    
    func onUserConfiguration() {
        path.append(.userConfiguration)
    }
            
    func joinToRoom() {
        path.append(.joinToRoom)
    }
}
