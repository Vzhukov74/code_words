//
//  DayChamp.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 13.08.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class DayChamp: Model, Content {
    static let schema = "DayChamp"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "player_id")
    var player: SolitairePlayer
    
    @Parent(key: "challenge_id")
    var challenge: SolitaireChallenge
    
    @Parent(key: "week_id")
    var week: WeekChamp
    
    @Field(key: "points")
    var points: Int
    
    init() {}
    
    init(id: UUID? = nil, player: SolitairePlayer, challenge: SolitaireChallenge, weekChamp: WeekChamp, points: Int) throws {
        self.id = id
        self.$player.id = try player.requireID()
        self.$challenge.id = try challenge.requireID()
        self.$week.id = try weekChamp.requireID()
        self.points = points
    }
}

struct CreateDayChamp: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DayChamp.schema)
            .id()
            .field("player_id", .uuid, .required, .references(SolitairePlayer.schema, "id"))
            .field("challenge_id", .uuid, .required, .references(SolitaireChallenge.schema, "id"))
            .field("week_id", .uuid, .required, .references(WeekChamp.schema, "id"))
            .field("points", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DayChamp.schema).delete()
    }
}

extension DayChamp {
    static func createOrUpdate(
        player: SolitairePlayer,
        challenge: SolitaireChallenge,
        weekChamp: WeekChamp,
        points: Int,
        on db: Database
    ) async throws -> DayChamp {
        let dayChamp = try await DayChamp.query(on: db)
            .filter(\.$challenge.$id == challenge.requireID())
            .filter(\.$player.$id == player.requireID())
            .first()
        ?? DayChamp(player: player, challenge: challenge, weekChamp: weekChamp, points: points)
        
        dayChamp.points = points
        
        try await dayChamp.save(on: db)
        
        return dayChamp
    }
}
