//
//  SocketService.swift
//  project-name
//
//  Created by Владислав Жуков on 30.09.2024.
//

import Foundation

final class SocketService {
    #if !SKIP
    private let baseUrl = URL(string: "http://127.0.0.1:8080/socket/connect")!
    #else
    private let baseUrl = URL(string: "http://192.168.31.236:8080/socket/connect")! //10.0.2.2
    #endif
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var onReceive: ((Data) -> Void)?
    
    func connect(to gameId: String, userId: String, onReceive: @escaping (Data) -> Void) {
        let url = baseUrl.appendingPathComponent("\(gameId)/\(userId)")
        let request = URLRequest(url: url)
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        self.onReceive = onReceive
        
        receive()
        webSocketTask!.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel()
    }
    
    func send(msg: String) {
        Task {
            try await webSocketTask!.send(URLSessionWebSocketTask.Message.string(msg))
        }
    }
    
    private func receive() {
        Task {
            let result = try? await webSocketTask?.receive()
            logger.info("receive_result" )
            if result != nil {
                switch result {
                case let .string(msg):
                    print(msg)
                case let .data(data):
                    onReceive?(data)
                default: break
                }
            }
            receive()
        }
    }
}
