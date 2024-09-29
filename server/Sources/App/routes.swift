import Vapor

func routes(_ app: Application) throws {
        app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    try app.register(collection: GameController())
    socketRoutes(app)
}

func socketRoutes(_ app: Application) {
    let socket = app.grouped("socket")

    socket.webSocket("connect", ":gameId", ":playerId") { req, ws in
        app.logger.debug("Handling request to play")
        
        guard let gameId = req.parameters.get("gameId"),
              let playerId = req.parameters.get("playerId") else {
            _ = ws.close(code: .protocolError)
            return
        }
        
        do {
            _ = try app.gameService.connect(to: gameId, playerId: playerId, ws: ws, on: req)
        } catch {
            ws.send(error: .unknownError(error), fromUser: playerId)
            _ = ws.close(code: .unexpectedServerError)
            app.logger.error("Error joining match: \(error)")
        }
    }
}

extension WebSocket {
    func send(error: GameServerResponseError, fromUser: String) {
        self.send("ERR \(fromUser) \(error.errorCode) \(error.errorDescription)")
    }
}

enum GameServerResponseError: LocalizedError {
    // Other errors
    case unknownError(Error?)

    var errorCode: Int {
        switch self {
        case .unknownError:          return 999
        }
    }

    var errorDescription: String {
        switch self {
        case .unknownError(let error):
            return error?.localizedDescription ?? "Unknown error."
        }
    }

    var shouldSendToOpponent: Bool {
        switch self {
        case .unknownError:
            return false
        }
    }
}
