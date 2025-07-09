//
//  SolitairePlayerResult.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 08.07.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class SolitairePlayerResult: Model, Content {
    static let schema = "solitaire_player_results"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "player_id")
    var player: SolitairePlayer
    
    @Field(key: "points")
    var points: Int
    
    @Field(key: "day_points")
    var dayPoints: [Int: Int]

    @Field(key: "year")
    var year: Int
    
    @Field(key: "week")
    var week: Int
    
    init() { }
    
    init(id: UUID? = nil, playerID: UUID, year: Int, week: Int) {
        self.id = id
        self.$player.id = playerID
        self.points = 0
        self.year = year
        self.week = week
        self.dayPoints = [:]
    }
}

struct CreateSolitairePlayerResult: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("solitaire_player_results")
            .id()
            .field("player_id", .uuid, .required, .references("solitaire_players", "id"))
            .field("points", .int, .required, .sql(.default(0)))
            .field("year", .int, .required)
            .field("week", .int, .required)
            .field("day_points", .dictionary(of: .int))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("solitaire_player_results").delete()
    }
}
