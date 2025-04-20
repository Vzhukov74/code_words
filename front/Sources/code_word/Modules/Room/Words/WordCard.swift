//
//  WordCard.swift
//  project-name
//
//  Created by Vladislav Zhukov on 11.01.2025.
//

import SwiftUI

struct WordCard: View {
    
    @State private var confettiCannonCounter: Int = 0
    
    let word: Word
    let isOpen: Bool
    let onSelect: (Word) -> Void
    let canSelect: Bool
    let selected: [Int: [Player]]
    
    var body: some View {
        Text(word.word)
            .font(.system(size: 16))
            .fontWeight(.regular)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 44)
            .foregroundStyle(labelColor(for: word))
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(wordColor(word))
            }
            .overlay {
                if let players = selected[word.id], !players.isEmpty {
                    voteView(count: players.count)
                }
            }
            .confettiCannon(counter: $confettiCannonCounter, num: 40)
            .onAppear {
                if word.isOpen, confettiCannonCounter == 0 {
                    withAnimation { confettiCannonCounter += 1 }
                }
            }
            .onTapGesture { onSelect(word) }
    }
    
    private func voteView(count: Int) -> some View {
        Text("\(count)")
            .font(.system(size: 16))
            .fontWeight(.semibold)
            .padding(8)
            .background {
                Circle()
                    .fill(AppColor.main)
            }
            .offset(y: -22)
    }
    
    private func wordColor(_ word: Word) -> Color {
        if isOpen || word.isOpen {
            return word.color.scolor
        } else {
            return .gray
        }
    }
    
    private func labelColor(for word: Word) -> Color {
        if (isOpen || word.isOpen) && word.color == .black {
            return .white
        }
        return .black
    }
}

extension WColor {
    var scolor: Color {
        switch self {
        case .gray:
            return AppColor.gray
        case .red:
            return AppColor.red
        case .blue:
            return AppColor.blue
        case .black:
            return AppColor.black
        }
    }
}
