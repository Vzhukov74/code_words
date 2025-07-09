//
//  SolitaireChallenge.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 09.07.2025.
//

import Vapor
import Fluent

final class SolitaireChallenge: Model, Content {
    static let schema = "SolitaireChallenge"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "year")
    var year: Int
    
    @Field(key: "day")
    var day: Int
        
    init() {}
    
    init(id: UUID? = nil, value: String, year: Int, day: Int) {
        self.id = id
        self.value = value
        self.year = year
        self.day = day
    }
}

// Add migration
struct CreateSolitaireChallenge: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(SolitaireChallenge.schema)
            .id()
            .field("value", .string, .required)
            .field("year", .int, .required)
            .field("day", .int, .required)
            .unique(on: "year", "day")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(SolitaireChallenge.schema).delete()
    }
}
