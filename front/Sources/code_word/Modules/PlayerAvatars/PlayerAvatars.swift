//
//  PlayerAvatars.swift
//  project-name
//
//  Created by Владислав Жуков on 08.10.2024.
//

import SwiftUI

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
    
    static func vm(by index: Int) -> AvatarViewModel {
        guard index < PlayerAvatars.allCases.count, index >= 0 else { return PlayerAvatars.avt1.model() }
        
        return PlayerAvatars.allCases[index].model()
    }
    
    static func image(by index: Int) -> Image {
        guard index < PlayerAvatars.allCases.count, index >= 0 else { return PlayerAvatars.avt1.image() }
        
        return PlayerAvatars.allCases[index].image()
    }
    
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
    
    func image() -> Image {
        switch self {
        case .avt1:
            return Image("0", bundle: .module)
        case .avt2:
            return Image("1", bundle: .module)
        case .avt3:
            return Image("2", bundle: .module)
        case .avt4:
            return Image("3", bundle: .module)
        case .avt5:
            return Image("4", bundle: .module)
        case .avt6:
            return Image("5", bundle: .module)
        case .avt7:
            return Image("6", bundle: .module)
        case .avt8:
            return Image("7", bundle: .module)
        case .avt9:
            return Image("8", bundle: .module)
        case .avt10:
            return Image("9", bundle: .module)
        case .avt11:
            return Image("10", bundle: .module)
        case .avt12:
            return Image("11", bundle: .module)
        case .avt13:
            return Image("12", bundle: .module)
        case .avt14:
            return Image("13", bundle: .module)
        case .avt15:
            return Image("14", bundle: .module)
        case .avt16:
            return Image("15", bundle: .module)
        case .avt17:
            return Image("16", bundle: .module)
        case .avt18:
            return Image("17", bundle: .module)
        case .avt19:
            return Image("18", bundle: .module)
        case .avt20:
            return Image("19", bundle: .module)
        }
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
                [false, true, false, false, false, true, false],
                [false, false, true, false, true, false, false],
                [false, true, true, true, true, true, false],
                [true, true, true, true, true, true, true],
                [true, false, true, true, true, false, true],
                [true, true, true, true, true, true, true],
                [false, true, false, false, false, true, false],
                [true, true, false, false, false, true, true],
            ]
        case .avt7:
            return [
                [true, false, false, false, false, false, true],
                [true, false, true, true, true, false, true],
                [false, true, true, true, true, true, false],
                [false, true, false, true, false, true, false],
                [true, true, false, true, false, true, true],
                [true, true, true, true, true, true, true],
                [true, true, true, true, true, true, true],
                [true, false, true, false, true, false, true],
            ]
        case .avt8:
            return [
                [false, true, false, false, false, false, true, false],
                [false, false, true, true, true, true, false, false],
                [true, true, true, true, true, true, true, true],
                [true, true, false, true, true, false, true, true],
                [false, true, true, true, true, true, true, false],
                [false, false, true, true, true, true, false, false],
                [false, false, true, false, false, true, false, false],
                [false, true, true, false, false, true, true, false],
            ]
        case .avt9:
            return [
                [false, false, true, false, true, true, false, true, false, false],
                [false, false, false, true, true, true, true, false, false, false],
                [true, false, true, true, true, true, true, true, false, true],
                [true, false, true, false, true, true, false, true, false, true],
                [true, true, true, true, true, true, true, true, true, true],
                [false, false, true, true, true, true, true, true, false, false],
                [false, false, true, false, true, true, false, true, false, false],
                [false, true, true, false, false, false, false, true, true, false],
            ]
        case .avt10:
            return [
                [false, false, false, true, true, false, false, false],
                [false, false, true, true, true, true, false, false],
                [false, true, false, true, true, false, true, false],
                [true, true, true, true, true, true, true, true],
                [true, false, true, true, true, true, false, true],
                [false, false, true, false, false, true, false, false],
                [false, true, true, false, false, true, true, false],
                [true, true, false, false, false, false, true, true],
            ]
        case .avt11:
            return [
                [false, false, true, false, false, false, true, false, false],
                [false, false, false, true, false, true, false, false, false],
                [false, false, true, true, true, true, true, false, false],
                [false, true, true, false, true, false, true, true, false],
                [true, true, true, false, true, false, true, true, true],
                [true, false, true, true, true, true, true, false, true],
                [true, false, true, true, true, true, true, false, true],
                [false, false, false, true, false, true, false, false, false],
                [false, false, true, true, false, true, true, false, false],
            ]
        case .avt12:
            return [
                [false, false, true, false, false, true, false, false],
                [false, false, true, true, true, true, false, false],
                [false, true, true, true, true, true, true, false],
                [true, true, false, true, true, false, true, true],
                [true, true, true, true, true, true, true, true],
                [false, false, true, false, false, true, false, false],
                [false, true, false, true, true, false, true, false],
                [true, false, true, false, false, true, false, true],
            ]
        case .avt13:
            return [
                [false, false, true, true, true, true, true, false, false],
                [false, true, true, true, true, true, true, true, false],
                [false, true, true, true, true, true, true, true, false],
                [true, true, false, false, true, false, false, true, true],
                [true, true, false, true, true, false, true, true, true],
                [true, true, true, true, true, true, true, true, true],
                [true, true, true, true, true, true, true, true, true],
                [true, false, true, false, true, false, true, false, true],
            ]
        case .avt14:
            return [
                [false, false, true, false, false, false, false, false, true, false, false],
                [false, false, false, true, false, false, false, true, false, false, false],
                [false, false, true, true, true, true, true, true, true, false, false],
                [false, true, true, false, true, true, true, false, true, true, false],
                [true, true, true, false, true, true, true, false, true, true, true],
                [false, true, true, true, true, true, true, true, true, true, false],
                [false, true, false, true, false, true, false, true, false, true, false],
                [true, true, false, false, false, false, false, false, false, true, true],
            ]
        case .avt15:
            return [
                [false, false, false, true, true, true, true, true, false, false, false],
                [false, false, true, true, false, true, false, true, true, false, false],
                [true, false, true, true, true, true, true, true, true, false, true],
                [true, false, true, false, false, false, false, false, true, false, true],
                [true, true, true, false, true, false, true, false, true, true, true],
                [false, false, true, true, true, true, true, true, true, false, false],
                [false, false, false, true, false, false, false, true, false, false, false],
                [false, false, true, false, false, false, false, false, true, false, false],
            ]
        case .avt16:
            return [
                [false, false, true, false, false, true, false, false],
                [false, false, false, true, true, false, false, false],
                [false, false, true, true, true, true, false, false],
                [false, true, true, true, true, true, true, false],
                [false, true, false, true, true, false, true, false],
                [false, false, true, true, true, true, false, false],
                [true, false, true, true, true, true, false, true],
                [false, true, true, false, false, true, true, false],
            ]
        case .avt17:
            return [
                [false, false, false, false, true, false, true, false, false, false, false],
                [false, false, false, true, true, true, true, true, false, false, false],
                [true, false, true, true, true, true, true, true, true, false, true],
                [true, false, true, false, false, true, false, false, true, false, true],
                [false, true, true, true, true, true, true, true, true, true, false],
                [false, false, true, false, true, false, true, false, true, false, false],
                [false, true, false, false, false, false, false, false, false, true, false],
                [true, true, false, false, false, false, false, false, false, true, true],
            ]
        case .avt18:
            return [
                [false, false, true, true, false, false, false, true, true, false, false],
                [false, false, false, false, true, true, true, false, false, false, false],
                [false, false, false, true, true, true, true, true, false, false, false],
                [false, false, true, true, false, true, true, false, true, false, true],
                [false, false, true, false, false, true, false, false, true, false, true],
                [true, true, true, true, true, true, true, true, true, true, true],
                [true, false, true, false, false, false, false, false, true, false, false],
                [true, false, false, true, false, false, false, true, false, false, false],
            ]
        case .avt19:
            return [
                [false, true, false, false, false, false, true, false],
                [false, true, false, false, false, false, true, false],
                [false, false, true, false, false, true, false, false],
                [false, true, true, true, true, true, true, false],
                [true, true, true, true, true, true, true, true],
                [true, true, false, true, true, false, true, true],
                [false, true, true, true, true, true, true, false],
                [true, true, true, false, false, true, true, true],
            ]
        case .avt20:
            return [
                [false, false, true, false, false, false, true, false, false],
                [false, false, true, true, true, true, true, false, false],
                [false, true, true, true, true, true, true, true, false],
                [false, true, false, false, true, false, false, true, false],
                [true, true, true, true, true, true, true, true, true],
                [true, true, true, false, false, false, true, true, true],
                [true, true, true, true, true, true, true, true, true],
                [true, false, true, false, true, false, true, false, true],
            ]
        }
    }
}
