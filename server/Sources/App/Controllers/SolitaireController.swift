//
//  SolitaireController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 06.04.2025.
//

import Foundation
import Vapor

struct LeadersSheet: Content {
    struct Leaders: Content {
        let id: String
        let name: String
        let points: Int
        let place: Int
    }
    
    let leaders: [Leaders]
}

actor SolitaireController: RouteCollection {
    nonisolated func boot(routes: any RoutesBuilder) throws {
        routes.get("solitaire", use: mainPage)
        
        routes.group("solitaire") { route in
            route.get("challenge", use: challengeOfWeek)
            route.get("leaders", use: leadersSheet)
            route.get("place", ":id", use: place)
            route.post("result", use: uploadResult)

            //let secure = route.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware())
            
            route.get("challenges", use: challengesList)
            route.post("challenge", use: setupChallenge)
            
            route.get("editor" , ":year", use: challengesEditor)
        }
    }

    // MARK: public routes
    
    nonisolated private func mainPage(req: Request) async throws -> View {
        try await req.view.render("solitaire_challenges_list_editor")
    }
        
    @Sendable private func challengeOfWeek(req: Request) async throws -> SolitaireGame {
        let weekNumber = try await req.application.getWeekNumber()
        let yearNumber = try await req.application.getYearNumber()
        
        let game = try await SolitaireGame.query(on: req.db)
            .filter(\SolitaireGame.$year, .equal, yearNumber)
            .filter(\SolitaireGame.$week, .equal, weekNumber)
            .first()
        
        guard let game else { throw Abort(.notFound) }

        return game
    }
    
    @Sendable private func leadersSheet(req: Request) async throws -> LeadersSheet {
        guard let id = req.parameters.get("id") else { throw Abort(.badRequest) }
        
        return try await fetchLeadersSheet(req: req)
    }
    
    @Sendable private func place(req: Request) async throws -> Int {
        guard let id = req.parameters.get("id") else { throw Abort(.badRequest) }
        
        return try await fetchPlace(req: req, id: id)
    }
    
    @Sendable private func uploadResult(req: Request) async throws -> LeadersSheet {
        struct ChallengeResult: Content {
            let name: String
            let id: String
            let points: Int
        }
        
        let weekNumber = try await req.application.getWeekNumber()
        let yearNumber = try await req.application.getYearNumber()

        let resultRaw = try req.content.decode(ChallengeResult.self)

        let resultDB = SolitaireResult()
        resultDB.id = resultRaw.id
        resultDB.name = resultRaw.name
        resultDB.points = resultRaw.points
        resultDB.year = yearNumber
        resultDB.week = weekNumber
        
        try await resultDB.save(on: req.db)
        
        return try await fetchLeadersSheet(req: req, updateIfLastLessThat: resultRaw.points)
    }
    
    // MARK: private routes
    
    @Sendable private func challengesList(req: Request) async throws -> [SolitaireGame] {
//        let sessionToken = try req.auth.require(SessionToken.self)
//        print(sessionToken.userId)
        
        let yearNumber = try await req.application.getYearNumber()
        
        let games = try await SolitaireGame.query(on: req.db)
            .filter(\SolitaireGame.$year, .equal, yearNumber)
            .all()

        return games
    }
    
    @Sendable private func setupChallenge(req: Request) async throws -> HTTPStatus {
//        let sessionToken = try req.auth.require(SessionToken.self)
//        print(sessionToken.userId)
        
        let game = try req.content.decode(SolitaireGame.self)
        
        try await game.save(on: req.db)
        
        return HTTPStatus.ok
    }
    
    nonisolated private func challengesEditor(req: Request) async throws -> View {
        guard let year = Int(req.parameters.get("year") ?? "") else { throw Abort(.badRequest) }
        
        let games = try await SolitaireGame.query(on: req.db)
            .filter(\SolitaireGame.$year, .equal, year)
            .all()

        return try await req.view.render(
            "solitaire_challenges_list_editor",
            EditorContent(year: "\(year)", challenges: games)
        )
    }
    
    // MARK: helpers
    
    @Sendable private func fetchLeadersSheet(req: Request, updateIfLastLessThat: Int = 0) async throws -> LeadersSheet {
        let weekNumber = try await req.application.getWeekNumber()
        let yearNumber = try await req.application.getYearNumber()
        
        func fetchFromDBAndCache() async throws -> LeadersSheet {
            let leadersRaw = try await SolitaireResult.query(on: req.db)
                .filter(\SolitaireResult.$year, .equal, yearNumber)
                .filter(\SolitaireResult.$week, .equal, weekNumber)
                .sort(\SolitaireResult.$points)
                .range(..<10)
                .all()
                    
            let leaders = LeadersSheet(leaders: leadersRaw.indices.compactMap { index in
                LeadersSheet.Leaders(
                    id: leadersRaw[index].id ?? "",
                    name: leadersRaw[index].name,
                    points: leadersRaw[index].points,
                    place: index + 1
                )
            })
            
            try await req.redis.set("app.solitaire.leaders.sheet", toJSON: leaders)
            
            return leaders
        }
        
        if let leaders = try await req.redis.get("app.solitaire.leaders.sheet", asJSON: LeadersSheet.self) {
            if (leaders.leaders.last?.points ?? 0) < updateIfLastLessThat {
                return try await fetchFromDBAndCache()
            } else {
                return leaders
            }
        } else {
            return try await fetchFromDBAndCache()
        }
    }
    
    @Sendable private func fetchPlace(req: Request, id: String) async throws -> Int {
        let weekNumber = try await req.application.getWeekNumber()
        let yearNumber = try await req.application.getYearNumber()
        
        let leaders = try await SolitaireResult.query(on: req.db)
            .filter(\SolitaireResult.$year, .equal, yearNumber)
            .filter(\SolitaireResult.$week, .equal, weekNumber)
            .sort(\SolitaireResult.$points)
            .range(..<10)
            .all()
                
        return 0
    }
}

private struct EditorContent: Codable {
    let year: String
    let challenges: [SolitaireGame]
}
