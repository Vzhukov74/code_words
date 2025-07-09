//
//  SolitaireAddNewDayGame.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 13.05.2025.
//

import Vapor
import Foundation
import Queues

struct SolitaireAddNewDayGame: AsyncJob {
    typealias Payload = String
    
    func dequeue(_ context: Queues.QueueContext, _ payload: String) async throws {
        let currentYear = try await context.application.getYearNumber()
        let currnetDay = try await context.application.getDayNumber()
        
        var year = try await SolitaireGame.query(on: context.application.db).min(\SolitaireGame.$year) ?? currentYear
        var day = try await SolitaireGame.query(on: context.application.db).min(\SolitaireGame.$day) ?? 1
        
        if day >= 366 {
            year += 1
            day = 1
        } else {
            day += 1
        }
        
        var new = SolitaireGame()
        new.id = "\(year)_\(day)"
        new.year = year
        new.day = day
        new.challenge = payload
        
        try await new.save(on: context.application.db)
    }
    
    func error(_ context: QueueContext, _ error: Error, _ payload: String) async throws {
        // do nothing
    }
}
