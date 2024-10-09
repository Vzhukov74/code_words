//
//  AvatarView.swift
//  project-name
//
//  Created by Владислав Жуков on 08.10.2024.
//

import SwiftUI

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
    
    let space: CGFloat = 4
    let size: CGFloat
    
    var body: some View {
        VStack(spacing: space) {
            ForEach(vm.cells, id: \.self) { cell in
                HStack(spacing: space) {
                    ForEach(cell, id: \.self) { cellVM in
                        cellView(cellVM: cellVM)
                    }
                }
            }
        }
    }
    
    private func cellView(cellVM: AvatarCellViewModel) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundStyle(cellVM.hasColor ? vm.color : Color.clear)
            .frame(width: size, height: size)
    }
}
