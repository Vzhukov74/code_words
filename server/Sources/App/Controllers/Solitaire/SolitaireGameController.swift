//
//  SolitaireGameController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 10.07.2025.
//

import Foundation
@preconcurrency import Vapor
import FluentKit
import FluentSQL
import FluentSQLiteDriver

actor SolitaireGameController: RouteCollection {
        
    struct UploadChallengeRequest: Content {
        let value: String
    }
    
    struct ChallengeResponse: Content {
        let id: UUID
        let value: String
        let year: Int
        let day: Int
    }
    
    struct ChallengesResponse: Content {
        let challenges: [Dto]
        
        struct Dto: Content {
            let value: String
            let day: Int
        }
    }

    struct UpdateChallengeRequest: Content {
        let value: String
        let year: Int
        let day: Int
    }

    struct ChallengesViewContext: Encodable {
        let year: Int
        let challenges: [ChallengeView]
        
        struct ChallengeView: Encodable {
            let day: Int
            let text: String
            let isToday: Bool
        }
    }
    
    nonisolated func boot(routes: any RoutesBuilder) throws {
        routes.group("solitaire") { route in
            route.get("challenge", use: challenge)
            route.post("challenge", use: uploadChallenge)
        }
        
        // MARK: for develop
        routes.group("solitaire", "api") { route in
            route.get("challenges", use: challenges)
            route.post("test-data", "generate", use: generateTestData)
            route.post("challenge", "update", use: updateOrCreateChallenge)
            
            route.get("challenges", ":year", use: showChallengesForYear)
        }
    }
    
    // MARK: public routes
        
    @Sendable private func uploadChallenge(req: Request) async throws -> HTTPStatus {
        let request = try req.content.decode(UploadChallengeRequest.self)
        
        let calendar = Calendar.current
        let today = Date()
        var year = calendar.component(.year, from: today)
        var day = calendar.component(.day, from: today)
        
        // Find the latest challenge to determine if we need to increment
        if let latest = try await SolitaireChallenge.query(on: req.db)
            .sort(\.$year, .descending)
            .sort(\.$day, .descending)
            .first() {
            
            day = latest.day + 1
            year = latest.year
            
            let daysInYear = calendar.range(of: .day, in: .year, for: today)!.count
            if day > daysInYear {
                day = 1
                year += 1
            }
        }
        
        // Check if challenge for this day/year already exists
        if try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .filter(\.$day == day)
            .first() != nil {
            throw Abort(.conflict, reason: "Challenge already exists for day \(day), year \(year)")
        }
        
        // Validate challenge text is unique
        if try await SolitaireChallenge.query(on: req.db)
            .filter(\.$value == request.value)
            .first() != nil {
            throw Abort(.conflict, reason: "Challenge text must be unique")
        }
        
        // Create and save new challenge
        let challenge = SolitaireChallenge(value: request.value, year: year, day: day)
        try await challenge.save(on: req.db)
        
        return .ok
    }
    
    @Sendable private func challenge(req: Request) async throws -> ChallengeResponse {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let day = calendar.component(.day, from: today)
                
        guard let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .filter(\.$day == day)
            .first() else {
                throw Abort(.notFound, reason: "No challenge found for today")
            }
        
        return ChallengeResponse(
            id: try challenge.requireID(),
            value: challenge.value,
            year: challenge.year,
            day: challenge.day
        )
    }
    
    @Sendable private func challenges(req: Request) async throws -> ChallengesResponse {
        guard let year = req.parameters.get("year", as: Int.self) else {
            throw Abort(.badRequest, reason: "Invalid year parameter")
        }
                
        let challenges = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .sort(\.$day, .ascending)
            .all()
                
        return ChallengesResponse(
            challenges: challenges.compactMap {
                ChallengesResponse.Dto(
                    value: $0.value,
                    day: $0.day
                )
            }
        )
    }
    
    @Sendable private func showChallengesForYear(req: Request) async throws -> View {
        guard let year = req.parameters.get("year", as: Int.self) else {
            throw Abort(.badRequest, reason: "Invalid year parameter")
        }
        
        // Get current day of year
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        // Get challenges from API
        let challenges = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .sort(\.$day, .ascending)
            .all()
        
        // Prepare view context
        let viewChallenges = challenges.map { challenge in
            ChallengesViewContext.ChallengeView(
                day: challenge.day,
                text: challenge.value,
                isToday: challenge.year == currentYear && challenge.day == currentDay
            )
        }
        
        let context = ChallengesViewContext(
            year: year,
            challenges: viewChallenges
        )
        
        return try await req.view.render("challenges", context)
    }
    
    @Sendable private func generateTestData(req: Request) async throws -> HTTPStatus {
        let year = try req.query.get(Int.self, at: "year")
        let daysInYear = Calendar.current.range(of: .day, in: .year, for: Date())!.count
        
        // Delete existing challenges for this year
        try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .delete()
        
        // Create test challenges for each day
        for day in 1...daysInYear {
            let challengeText = "Challenge for day \(day) of \(year)"
            let challenge = SolitaireChallenge(
                value: challengeText,
                year: year,
                day: day
            )
            try await challenge.save(on: req.db)
        }
        
        return .created
    }
    
    @Sendable private func updateOrCreateChallenge(req: Request) async throws -> HTTPStatus {
        let request = try req.content.decode(UpdateChallengeRequest.self)
        
        // Validate day is valid for the year
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: request.year, day: request.day)
        guard let date = calendar.date(from: dateComponents),
              let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) else {
            throw Abort(.badRequest, reason: "Invalid day/year combination")
        }
        
        // Find existing challenge or create new
        let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == request.year)
            .filter(\.$day == dayOfYear)
            .first()
        ?? SolitaireChallenge(value: request.value, year: request.year, day: dayOfYear)
        
        // Update challenge text
        challenge.value = request.value
        try await challenge.save(on: req.db)
        
        return .ok
    }
}
