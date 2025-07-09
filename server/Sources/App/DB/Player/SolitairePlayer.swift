//
//  SolitairePlayer.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 08.07.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class SolitairePlayer: Model, Content {
    static let schema = "solitaire_players"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$player)
    var results: [SolitairePlayerResult]
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

struct CreateSolitairePlayer: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("solitaire_players")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("solitaire_players").delete()
    }
}
