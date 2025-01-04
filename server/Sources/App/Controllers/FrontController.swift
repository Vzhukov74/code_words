//
//  FrontController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 03.01.2025.
//

import Vapor

final class FrontController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get { req async throws in
            try await req.view.render("root")
        }
    }
}
