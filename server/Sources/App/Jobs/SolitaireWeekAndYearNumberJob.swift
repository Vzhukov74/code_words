//
//  SolitaireJob.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 20.04.2025.
//

import Vapor
import Foundation
import Queues

enum SolitaireJobError: Error {
    case ErrorFetchCurrentWeekNumber
    case ErrorFetchCurrentYearNumber
}

struct SolitaireWeekAndYearNumberJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        try await SolitaireWeekAndYearNumberJob.setupWeekAndYearNumber(for: context.application)
    }
    
    static func currnetWeekNumber() -> Int? {
        Calendar.current.dateComponents([.weekOfYear], from: Date()).weekOfYear
    }
    
    static func currentYearNumber() -> Int? {
        Calendar.current.dateComponents([.year], from: Date()).year
    }
    
    static func setupWeekAndYearNumber(for app: Application) async throws {
        guard let weekNumber = SolitaireWeekAndYearNumberJob.currnetWeekNumber() else { throw SolitaireJobError.ErrorFetchCurrentWeekNumber }
        guard let yearNumber = SolitaireWeekAndYearNumberJob.currentYearNumber() else { throw SolitaireJobError.ErrorFetchCurrentYearNumber }
        
        try await app.setWeekNumber(value: weekNumber)
        try await app.setYearNumber(value: yearNumber)
    }
}
