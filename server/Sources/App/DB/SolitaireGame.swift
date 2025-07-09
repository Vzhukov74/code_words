//
//  SolitaireGame.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 13.04.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class SolitaireGame: Model, Content {
    static let schema = "SolitaireGames"

    @ID(custom: "id")
    var id: String?
    
    @Field(key: "challenge") var challenge: String
    @Field(key: "year") var year: Int
    @Field(key: "day") var day: Int
}

struct CreateSolitaireGame: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(SolitaireGame.schema)
            .field("id", .string, .identifier(auto: false))
            .field("challenge", .string)
            .field("year", .int)
            .field("day", .int)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(SolitaireGame.schema).delete()
    }
}
