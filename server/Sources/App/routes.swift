import Vapor

func routes(_ app: Application) throws {
        app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    try app.register(collection: GameController())
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
