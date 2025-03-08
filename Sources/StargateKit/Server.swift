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
    let routes: [ProxyModifier]
    public var app: Application?
    var logger: Logger?

    public init(port: Int, routes: [ProxyModifier]) {
        self.port = port
        self.routes = routes
    }

    public mutating func start() async throws {
        let app = try await Application.make(.development)
        self.app = app
        if let logger = logger {
            app.logger = logger
        }
        // Configure the server's port.
        app.http.server.configuration.port = port

        // Register routes for all HTTP methods.
        for method in HTTPMethod.allCases {
            app.on(method, "**", body: .collect(maxSize: nil), use: handle)
        }

        app.logger.info("Starting StargateKit server on port \(port)")
        try await app.startup()
    }

    public mutating func stop() async throws {
        guard let app = app else { return }
        app.logger.info("Shutting down StargateKit server")
        try await app.asyncShutdown()
        self.app = nil
    }

    @Sendable
    private func handle(request: Request) async throws -> Response {
        app?.logger.debug("Received request: \(request.method) \(request.url.string)")

        // Find the first route that matches the request URL.
        guard let route = routes.first(where: { $0.matches(url: request.url) }) else {
            app?.logger.warning("No matching route found for URL: \(request.url.string)")
            return Response(status: .notFound)
        }

        // If the route doesn't have a request performer set, default to Server as performer.
        if route.requestPerformer == nil {
            var mutableRoute = route
            mutableRoute.requestPerformer = self
        }

        let clientRequest = ClientRequest(
            method: request.method,
            url: request.url,
            headers: request.headers,
            body: request.body.data,
            timeout: nil
        )

        do {
            // Process the request through the modifier chain.
            let clientResponse = try await route.process(request: clientRequest)
            var responseBody: Response.Body
            if let byteBuffer = clientResponse.body {
                responseBody = .init(buffer: byteBuffer)
            } else {
                responseBody = .init(stringLiteral: "")
            }

            let response = Response(
                status: clientResponse.status,
                version: .http3,
                headers: clientResponse.headers,
                body: responseBody
            )
            app?.logger.debug("Responding with status: \(clientResponse.status.code)")
            return response
        } catch {
            app?.logger.error("Error processing request: \(error.localizedDescription)")
            return Response(status: .internalServerError, body: .init(string: "Internal Server Error"))
        }
    }
}

extension Server: RequestPerformer {
    public func handle(request: ClientRequest) async throws -> ClientResponse {
        guard let client = app?.client else {
            throw StargateError.noRequestPerformer(url: request.url.string)
        }
        return try await client.send(request)
    }
}

public extension Client {
    func send(_ request: Request) async throws -> Response {
        var clientRequest = ClientRequest()
        clientRequest.method = request.method
        clientRequest.body = request.body.data
        clientRequest.headers = request.headers
        clientRequest.url = request.url
        clientRequest.query = request.query

        let clientResponse = try await send(clientRequest)

        var response = Response()
        response.status = clientResponse.status
        if let responseBody = clientResponse.body {
            response.body = .init(buffer: responseBody)
        }
        response.headers = clientResponse.headers
        if let cookies = clientResponse.headers.cookie {
            response.cookies = cookies
        }
        return response
    }
}
