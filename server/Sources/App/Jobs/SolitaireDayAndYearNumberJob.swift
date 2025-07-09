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

struct SolitaireDayAndYearNumberJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        try await SolitaireDayAndYearNumberJob.setupWeekAndYearNumber(for: context.application)
    }
    
    static func currnetDayNumber() -> Int? {
        Calendar.current.dateComponents([.weekOfYear], from: Date()).day
    }
    
    static func currentYearNumber() -> Int? {
        Calendar.current.dateComponents([.year], from: Date()).year
    }
    
    static func setupWeekAndYearNumber(for app: Application) async throws {
        guard let dayNumber = SolitaireDayAndYearNumberJob.currnetDayNumber() else { throw SolitaireJobError.ErrorFetchCurrentWeekNumber }
        guard let yearNumber = SolitaireDayAndYearNumberJob.currentYearNumber() else { throw SolitaireJobError.ErrorFetchCurrentYearNumber }
        
        try await app.setDayNumber(value: dayNumber)
        try await app.setYearNumber(value: yearNumber)
    }
}
