//
//  SolitaireJob.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 20.04.2025.
//

import Vapor
import Foundation
import Fluent
import Queues

struct SolitaireJobConfig {
    static func startInit(for app: Application) async throws {
        try await SolitaireDayNumberJob.job(on: app)
        try await SolitaireWeekNumberJob.job(on: app)
        try await SolitaireYearNumberJob.job(on: app)
        try await SolitaireDayChallengeJob.job(on: app)
    }
    
    static func setup(on queues: Application.Queues) {
        queues.schedule(SolitaireDayNumberJob())
            .daily()
            .at(.midnight)
        
        queues.schedule(SolitaireWeekNumberJob())
            .weekly()
            .on(.monday)
            .at(.midnight)
            
        queues.schedule(SolitaireYearNumberJob())
            .yearly()
            .in(.january)
            .on(.first)
            .at(.midnight)
        
        queues.schedule(SolitaireDayChallengeJob())
            .daily()
            .at(ScheduleBuilder.Time(stringLiteral: "12:02am"))
        
        queues.schedule(SolitaireDayChallengeJob())
            .weekly()
            .on(.monday)
            .at(ScheduleBuilder.Time(stringLiteral: "12:02am"))
    }
}

enum SolitaireJobError: Error {
    case ErrorFetchCurrentDayNumber
    case ErrorFetchCurrentWeekNumber
    case ErrorFetchCurrentYearNumber
}

struct SolitaireDayNumberJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        try await SolitaireDayNumberJob.job(on: context.application)
    }
    
    static func job(on app: Application) async throws {
        let calendar = Calendar.current
        guard let dayNumber = calendar.ordinality(of: .day, in: .year, for: Date())
        else {
            throw SolitaireJobError.ErrorFetchCurrentDayNumber
        }
        
        try await app.setDayNumber(value: dayNumber)
    }
}

struct SolitaireWeekNumberJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        try await SolitaireWeekNumberJob.job(on: context.application)
    }
    
    static func job(on app: Application) async throws {
        guard let weekNumber = Calendar.current.dateComponents([.weekOfYear], from: Date()).weekOfYear else { throw SolitaireJobError.ErrorFetchCurrentWeekNumber }
        
        try await app.setWeekNumber(value: weekNumber)
    }
}

struct SolitaireYearNumberJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        try await SolitaireYearNumberJob.job(on: context.application)
    }
    
    static func job(on app: Application) async throws {
        guard let yearNumber = Calendar.current.dateComponents([.year], from: Date()).year else { throw SolitaireJobError.ErrorFetchCurrentDayNumber }
        
        try await app.setYearNumber(value: yearNumber)
    }
}

struct SolitaireDayChallengeJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        try await SolitaireDayChallengeJob.job(on: context.application)
    }
    
    static func job(on app: Application) async throws {
        let year = try await app.getYearNumber()
        let day = try await app.getDayNumber()
        
        if let challenge = try await SolitaireChallenge.query(on: app.db)
            .filter(\.$year == year)
            .filter(\.$day == day)
            .first() {
            try await app.cacheService.cacheDayChallenge(challenge.value)
        } else {
            app.logger.info("coudn't fetch challenge for \(year):\(day)")
        }
    }
}

struct SolitaireWeekChampJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        let year = try await context.application.getYearNumber()
        let week = try await context.application.getPreviousWeekNumber()
        
        let topTen = try await WeekChamp.query(on: context.application.db)
            .filter(\.$year == year)
            .filter(\.$week == (week - 1))
            .sort(\.$points, .descending)
            .with(\.$player)
            .limit(10)
            .all()
            .compactMap {
                try LeaderResult(id: $0.player.requireID(), name: $0.player.name, points: $0.points)
            }

        try await context.application.cacheService.cacheWeekLeaders(topTen)
    }
}

extension Application {
    func getDayNumber() async throws -> Int {
        try await cache.get("app.solitaire.day.number", as: Int.self) ?? 1
    }
    
    func getWeekNumber() async throws -> Int {
        try await cache.get("app.solitaire.week.number", as: Int.self) ?? 1
    }
    
    func getPreviousWeekNumber() async throws -> Int {
        let currentWeek = try await getWeekNumber()
        var week = currentWeek - 1
        if week == 0 {
            let currentYear = try await getYearNumber()
            week = Calendar.weeksInYear(currentYear - 1)
        }

        return week
    }

    func getYearNumber() async throws -> Int {
        try await cache.get("app.solitaire.year.number", as: Int.self) ?? 0
    }
    
    func setWeekNumber(value: Int) async throws {
        try await cache.set("app.solitaire.week.number", to: value)
    }
    
    func setDayNumber(value: Int) async throws {
        try await cache.set("app.solitaire.day.number", to: value)
    }

    func setYearNumber(value: Int) async throws {
        try await cache.set("app.solitaire.year.number", to: value)
    }
}

extension Calendar {
    static func weeksInYear(_ year: Int) -> Int {
        let calendar = Calendar.current
        guard year > 0, let firstDay = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let lastDay = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            return 52
        }
        
        let weekDifference = calendar.dateComponents([.weekOfYear], from: firstDay, to: lastDay).weekOfYear ?? 52
        return weekDifference + 1
    }
}
