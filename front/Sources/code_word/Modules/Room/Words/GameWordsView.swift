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
    let selected: [Int: [Player]]
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
        WordCard(
            word: word,
            isOpen: isOpen,
            onSelect: onSelect,
            canSelect: canSelect,
            selected: selected
        )
    }
}
