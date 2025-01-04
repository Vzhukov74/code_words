import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) async throws {

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.views.use(.leaf)
    
    app.gameService = GameService()

    try routes(app)
}
