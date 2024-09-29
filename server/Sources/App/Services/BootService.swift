//
//  BootService.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//

import Vapor

struct BootService: LifecycleHandler {
//    func didBootAsync(_ application: Application) async throws {
//        application.eventLoopGroup.next().scheduleRepeatedAsyncTask(
//            initialDelay: .seconds(0),
//            delay: .minutes(5)
//        ) { _ in
//            application.cleanupExpiredGames()
//        }
//    }
}

// MARK: Application

//extension Application {
//    func cleanupExpiredGames() -> EventLoopFuture<Void> {
////        Match.query(on: db)
////            .filter(\Match.$status == .notStarted)
////            .all()
////            .flatMap { [unowned self] matches in
////                do {
////                    return try matches.map {
////                        let id = try $0.requireID()
////                        return ExpiredGameJob(id: id).invoke(self)
////                    }.flatten(on: eventLoopGroup.next())
////                } catch {
////                    return eventLoopGroup.next().future()
////                }
////            }
//    }
//}
