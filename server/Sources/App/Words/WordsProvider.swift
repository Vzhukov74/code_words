//
//  WordsProvider.swift
//  code_word_server
//
//  Created by Владислав Жуков on 13.11.2024.
//

protocol IWordsProvider: Sendable {
    func words() -> [Game.Word]
}

final class WordsProvider: IWordsProvider {
    
    let dictionary: WDictionary
        
    init(dictionary: WDictionary = .common) {
        self.dictionary = dictionary
    }
    
    func words() -> [Game.Word] {
        switch dictionary {
        case .common:
            return WordsPreparer.prepare(words: CommonWords.words())
        }
    }
}

enum WDictionary {
    case common
}
