//
//  Server.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Foundation
import Vapor

public struct Server: Sendable {
    let port: Int
    let hosts: [String]
    let routes: [RouteProtocol]
    
    public init(port: Int, hosts: [String], routes: [RouteProtocol]) {
        self.port = port
        self.hosts = hosts
        self.routes = routes
    }
    
    public func start() async throws {
        let app = Application(.production)
        defer { app.shutdown() }
        
        // Configure the server's port
        app.http.server.configuration.port = port
        
        // Register routes for all HTTP methods
        for method in HTTPMethod.allCases {
            app.on(method, "**", body: .collect(maxSize: "10mb"), use: handle)
        }
        
        try await app.start()
    }
    
    @Sendable
    private func handle(request: Request) async throws -> Response {
        // Check if the request host is allowed
        guard hosts.contains(request.url.host ?? "") else {
            return Response(status: .forbidden)
        }
        
        // Find the first route that matches the request URL
        guard let route = routes.first(where: { $0.matches(url: request.url) }) else {
            return Response(status: .notFound)
        }
        
        // Handle the request using the matched route
        return try await route.handle(request: request)
    }
}
