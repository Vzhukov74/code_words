import Vapor

// configures your application
public func configure(_ app: Application) async throws {

    app.gameService = GameService()

    try routes(app)
}
