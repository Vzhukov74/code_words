//
//  PlayerAvatars.swift
//  project-name
//
//  Created by Владислав Жуков on 08.10.2024.
//

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
