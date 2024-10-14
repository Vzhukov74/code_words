//
//  LeaderHitnInputViewModel.swift
//  project-name
//
//  Created by Владислав Жуков on 14.10.2024.
//

import Combine
import SwiftUI

final class LeaderHitnInputViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var number: Int? = nil
    @Published var isSendActive: Bool = false
    
    private var cancellable: Set<AnyCancellable> = []
    private let cmdService: CmdService
    
    init(cmdService: CmdService) {
        self.cmdService = cmdService
        
        $text.sink { [weak self] in
            guard let self else { return }
            self.isSendActive = !$0.isEmpty && self.number != nil
        }.store(in: &cancellable)
        
        $number.sink { [weak self] in
            guard let self else { return }
            self.isSendActive = !text.isEmpty && $0 != nil
        }.store(in: &cancellable)
    }
    
    func onSelectNumber(_ number: Int) {
        self.number = number
    }
    
    func onHint() {
        guard let number, !text.isEmpty else { return }
        cmdService.writeDownWord(word: text, number: number)
    }
    
    func clear() {
        number = nil
        text = ""
    }
}
