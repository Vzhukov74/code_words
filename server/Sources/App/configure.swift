import Vapor
import Redis
import Leaf
import JWT
import Fluent
import FluentSQL
import FluentSQLiteDriver
import QueuesRedisDriver

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.views.use(.leaf)

    // TODO: install sqlite3 locally or switch on postgress or mangoDB
    
    if Environment.get("APP_ENV") ?? "" == "prod" {
        let sqlFilePath = Environment.get("DB_NAME") ?? ""
        app.databases.use(.sqlite(.file("/data/\(sqlFilePath)")), as: .sqlite)
    } else {
        app.databases.use(.sqlite(.memory), as: .sqlite)
    }
    
    app.migrations.add(CreateSolitaireGame())
    app.migrations.add(CreateSolitaireResult())
    try await app.autoMigrate()
        
    let evnRedisUrl = Environment.get("REDIS_URL") ?? "redis://127.0.0.1:6379"
    let redisConfiguration = try RedisConfiguration(url: evnRedisUrl, pool: .init(connectionRetryTimeout: .seconds(5)))
    
    app.redis.configuration = redisConfiguration
    app.queues.use(.redis(redisConfiguration))

    try await SolitaireWeekAndYearNumberJob.setupWeekAndYearNumber(for: app)
    
    app.queues.schedule(SolitaireWeekAndYearNumberJob())
        .weekly()
        .on(.sunday)
        .at(.midnight)
    
    app.gameService = GameService()

    await app.jwt.keys.add(hmac: "secret", digestAlgorithm: .sha256)
    
    try routes(app)
}

extension Application {
    func getWeekNumber() async throws -> Int {
        try await cache.get("app.solitaire.week.number", as: Int.self) ?? 0
    }

    func getYearNumber() async throws -> Int {
        try await cache.get("app.solitaire.year.number", as: Int.self) ?? 0
    }
    
    func setWeekNumber(value: Int) async throws {
        try await cache.set("app.solitaire.week.number", to: value)
    }

    func setYearNumber(value: Int) async throws {
        try await cache.set("app.solitaire.year.number", to: value)
    }
}
