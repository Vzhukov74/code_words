//
//  SolitaireResults.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 13.04.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class SolitaireResult: Model, Content {
    static let schema = "SolitaireResults"

    @ID(custom: "id")
    var id: String?
    
    @Field(key: "name") var name: String
    @Field(key: "points") var points: Int
    @Field(key: "year") var year: Int
    @Field(key: "week") var week: Int
}

struct CreateSolitaireResult: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(SolitaireResult.schema)
            .field("id", .string, .identifier(auto: false))
            .field("name", .string)
            .field("points", .int)
            .field("year", .int)
            .field("week", .int)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(SolitaireResult.schema).delete()
    }
}
