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
    
    app.databases.middleware.use(UpdateWeekChampPointsMiddleware())
    
    app.migrations.add(CreateSolitaireGame())
    app.migrations.add(CreateSolitairePlayer())
    app.migrations.add(CreateDayChamp())
    app.migrations.add(CreateWeekChamp())
    app.migrations.add(CreateSolitairePlayerResult())
    app.migrations.add(CreateSolitaireChallenge())
    try await app.autoMigrate()
        
    let evnRedisUrl = Environment.get("REDIS_URL") ?? "redis://127.0.0.1:6379"
    let redisConfiguration = try RedisConfiguration(url: evnRedisUrl, pool: .init(connectionRetryTimeout: .seconds(5)))
    
    app.redis.configuration = redisConfiguration
    app.queues.use(.redis(redisConfiguration))
    
    try await SolitaireJobConfig.startInit(for: app)
    //SolitaireJobConfig.setup(on: app.queues)
    
    app.gameService = GameService()

    await app.jwt.keys.add(hmac: "secret", digestAlgorithm: .sha256)
    
    let dayNumber = try await app.getDayNumber()
    let weekNumber = try await app.getWeekNumber()
    let yearNumber = try await app.getYearNumber()
    app.use { app in
        try SolitaireCacheService(app: app)
    }
    
    app.logger.info("""
        - Year number: \(yearNumber)
        - Week number: \(weekNumber)
        - Day number: \(dayNumber)
    """)
    
    try routes(app)
}
