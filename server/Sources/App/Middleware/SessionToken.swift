//
//  SessionToken.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 06.04.2025.
//

import Vapor
import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {

    // Constants
    var expirationTime: TimeInterval = 60 * 15

    // Token Data
    var expiration: ExpirationClaim
    var userId: String

    init(userId: String) {
        self.userId = userId
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
}

struct ClientTokenResponse: Content {
    var token: String
}
