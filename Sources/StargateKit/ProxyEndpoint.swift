//
//  ProxyEndpoint.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Vapor

public struct ProxyEndpoint: RouteProtocol {
    let pathMatcher: @Sendable (URI) -> Bool
    let targetURL: URI
    var requestModifiers: [RequestModifier]
    var responseModifiers: [ResponseModifier]
    
    public init(
        pathMatcher: @Sendable @escaping (URI) -> Bool,
        targetURL: URI,
        requestModifiers: [RequestModifier] = [],
        responseModifiers: [ResponseModifier] = []
    ) {
        self.pathMatcher = pathMatcher
        self.targetURL = targetURL
        self.requestModifiers = requestModifiers
        self.responseModifiers = responseModifiers
    }
    
    public func matches(url: URI) -> Bool {
        pathMatcher(url)
    }
    
    public func handle(request: Request) async throws -> Response {
        // Create a new client request
        var clientRequest = ClientRequest(method: request.method, url: targetURL, headers: request.headers, body: request.body.data)
        
        // Apply request modifiers
        for modifier in requestModifiers {
            modifier.handle(request: &clientRequest)
        }
        
        // Send the request using the client's event loop
        let clientResponse = try await request.client.send(clientRequest)
        
        // Apply response modifiers
        var modifiedResponse = clientResponse
        for modifier in responseModifiers {
            modifier.handle(response: &modifiedResponse)
        }
        
        // Return the response to the client
        return .init(status: modifiedResponse.status, headers: modifiedResponse.headers, body: .init(buffer: modifiedResponse.body ?? ByteBuffer()))
    }
}
