//
//  SolitaireResults.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 13.04.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver





//struct AddPlayerResultIndexes: Migration {
//    func prepare(on database: Database) -> EventLoopFuture<Void> {
//        database.schema("solitaire_player_results")
//            .unique(on: "player_id", "year") // Ensure one result per player per year
//            .index(on: "year")                // Speed up year-based queries
//            .index(on: "points")              // Speed up sorting by points
//            .update()
//    }
//
//    func revert(on database: Database) -> EventLoopFuture<Void> {
//        database.schema("solitaire_player_results")
//            .deleteIndex(on: "year")
//            .deleteIndex(on: "points")
//            .deleteUnique(on: "player_id", "year")
//            .update()
//    }
//}
