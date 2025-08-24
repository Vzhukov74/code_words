//
//  WeekChamp.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 18.08.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class WeekChamp: Model, Content {
    static let schema = "WeekChamp"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "player_id")
    var player: SolitairePlayer
    
    @Children(for: \.$week)
    var dayChamps: [DayChamp]
    
    @Field(key: "week")
    var week: Int
    
    @Field(key: "year")
    var year: Int
    
    @Field(key: "points")
    var points: Int
    
    init() {}
    
    init(id: UUID? = nil, player: SolitairePlayer, week: Int, year: Int) throws {
        self.id = id
        self.$player.id = try player.requireID()
        self.points = 0
        self.week = week
        self.year = year
    }
}

struct CreateWeekChamp: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(WeekChamp.schema)
            .id()
            .field("player_id", .uuid, .required, .references(SolitairePlayer.schema, "id"))
            .field("points", .int, .required)
            .field("year", .int, .required)
            .field("week", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DayChamp.schema).delete()
    }
}

extension WeekChamp {
    static func createOrUpdate(player: SolitairePlayer, week: Int, year: Int, on db: Database) async throws -> WeekChamp {
        let weekChamp = try await WeekChamp.query(on: db)
            .filter(\.$player.$id == player.requireID())
            .filter(\.$year == year)
            .filter(\.$week == week)
            .first()
        ?? WeekChamp(player: player, week: week, year: year)
        
        try await weekChamp.save(on: db)
        
        return weekChamp
    }
    
    static func updatePoints(for weekID: UUID, on db: Database) async throws {
        // Calculate sum of all day results for this week
        let sum = try await DayChamp.query(on: db)
            .filter(\.$week.$id == weekID)
            .sum(\.$points) ?? 0
        
        // Update the week's points
        try await WeekChamp.query(on: db)
            .filter(\.$id == weekID)
            .set(\.$points, to: sum)
            .update()
    }
}

struct UpdateWeekChampPointsMiddleware: AsyncModelMiddleware {
    func create(model: DayChamp, on db: Database, next: AnyAsyncModelResponder) async throws {
        // First create the day result
        try await next.create(model, on: db)
        
        // Then update the associated week's points
        try await WeekChamp.updatePoints(for: model.$week.id, on: db)
    }
    
    func update(model: DayChamp, on db: Database, next: AnyAsyncModelResponder) async throws {
        // First update the day result
        try await next.update(model, on: db)
        
        // Then update the associated week's points
        try await WeekChamp.updatePoints(for: model.$week.id, on: db)
    }
    
    func delete(model: DayChamp, force: Bool, on db: Database, next: AnyAsyncModelResponder) async throws {
        // First delete the day result
        try await next.delete(model, force: force, on: db)
        
        // Then update the associated week's points
        try await WeekChamp.updatePoints(for: model.$week.id, on: db)
    }
}
