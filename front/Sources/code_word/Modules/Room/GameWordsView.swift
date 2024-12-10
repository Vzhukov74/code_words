//
//  GameWordsView.swift
//  project-name
//
//  Created by Владислав Жуков on 30.09.2024.
//

import SwiftUI

struct GameWordsView: View {
    
    let words: [Word]
    let isOpen: Bool
    let canSelect: Bool
    let onSelect: (Word) -> Void
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40)))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: CGFloat(8)) {
            ForEach(words, id: \.self) { word in
                wordCard(word)
            }
        }
    }
    
    private func wordCard(_ word: Word) -> some View {
        Text(word.word)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 44)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cyan)
            }
            .onTapGesture { onSelect(word) }
//            .overlay {
//                VStack {
//                    Spacer(minLength: 0)
//                    HStack {
//                        ForEach(word.elections, id: \.self) { player in
//                            Text(player.name)
//                        }
//                    }
//                }
//            }
    }
}
