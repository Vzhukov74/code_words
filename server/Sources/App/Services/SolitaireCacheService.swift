//
//  SolitaireCacheService.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 24.08.2025.
//

import Vapor
import Redis

struct LeaderResult: Content, Equatable {
    let id: UUID
    let name: String
    let points: Int
}

// Models/CacheKeys.swift
enum CacheKeys: String {
    case dayChallenge = "day_challenge"
    case dayLeaders = "day_leaders"
    case weekLeaders = "week_leaders"
}

protocol ISolitaireCacheService: Sendable {
    func cacheDayChallenge(_ challenge: String) async throws
    func getDayChallenge() async throws -> String?
    
    func cacheDayLeaders(_ leaders: [LeaderResult]) async throws
    func getDayLeaders() async throws -> [LeaderResult]?
    
    func cacheWeekLeaders(_ leaders: [LeaderResult]) async throws
    func getWeekLeaders() async throws -> [LeaderResult]?
    
    func updateDayChallenge(_ challenge: String) async throws
    func updateDayLeaders(_ leaders: [LeaderResult]) async throws
    func updateWeekLeaders(_ leaders: [LeaderResult]) async throws
    
    func clearAllCache() async throws
}

final class SolitaireCacheService: ISolitaireCacheService, @unchecked Sendable {
    private let app: Application
    private let redis: RedisClient
    
    private var dayChallengeKey: RedisKey { RedisKey(CacheKeys.dayChallenge.rawValue) }
    private var dayLeadersKey: RedisKey { RedisKey(CacheKeys.dayLeaders.rawValue) }
    private var weekLeadersKey: RedisKey { RedisKey(CacheKeys.weekLeaders.rawValue) }
    
    init(app: Application) throws {
        self.app = app
        self.redis = app.redis
    }
    
    // MARK: - Day Challenge
    
    func cacheDayChallenge(_ challenge: String) async throws {
        try await redis.set(
            dayChallengeKey,
            to: challenge
        ).get()
    }
    
    func getDayChallenge() async throws -> String? {
        try await redis.get(
            dayChallengeKey,
            as: String.self
        ).get()
    }
    
    func updateDayChallenge(_ challenge: String) async throws {
        try await cacheDayChallenge(challenge)
    }
    
    // MARK: - Day Leaders
    
    func cacheDayLeaders(_ leaders: [LeaderResult]) async throws {
        let data = try JSONEncoder().encode(leaders)
        try await redis.set(
            dayLeadersKey,
            to: data
        ).get()
    }
    
    func getDayLeaders() async throws -> [LeaderResult]? {
        guard let data = try await redis.get(
            dayLeadersKey,
            as: Data.self
        ).get() else {
            return nil
        }
        
        return try JSONDecoder().decode([LeaderResult].self, from: data)
    }
    
    func updateDayLeaders(_ leaders: [LeaderResult]) async throws {
        try await cacheDayLeaders(leaders)
    }
    
    // MARK: - Week Leaders
    
    func cacheWeekLeaders(_ leaders: [LeaderResult]) async throws {
        let data = try JSONEncoder().encode(leaders)
        try await redis.set(
            weekLeadersKey,
            to: data
        ).get()
    }
    
    func getWeekLeaders() async throws -> [LeaderResult]? {
        guard let data = try await redis.get(
            weekLeadersKey,
            as: Data.self
        ).get() else {
            return nil
        }
        
        return try JSONDecoder().decode([LeaderResult].self, from: data)
    }
    
    func updateWeekLeaders(_ leaders: [LeaderResult]) async throws {
        try await cacheWeekLeaders(leaders)
    }
    
    // MARK: - Utility
    
    func clearAllCache() async throws {
        let keys = [
            dayChallengeKey,
            dayLeadersKey,
            weekLeadersKey
        ]
        
        _ = redis.delete(keys)
    }
}

extension Application {
    struct CacheServiceKey: StorageKey {
        typealias Value = ISolitaireCacheService
    }
    
    var cacheService: ISolitaireCacheService {
        get {
            guard let service = storage[CacheServiceKey.self] else {
                fatalError("CacheService not configured. Use app.use(:)")
            }
            return service
        }
        set {
            storage[CacheServiceKey.self] = newValue
        }
    }
    
    func use(_ makeService: @escaping (Application) throws -> ISolitaireCacheService) {
        storage[CacheServiceKey.self] = try? makeService(self)
    }
}
