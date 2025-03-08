//
//  RouteProtocol.swift
//  StargateKit
//
//  Created by Murilo Araujo on 08/03/25.
//

import Vapor

public protocol RequestPerformer {
    func handle(request: ClientRequest) async throws -> ClientResponse
}

public protocol ProxyModifier: Sendable {
    /// If set, the request performer is used to send the final request.
    var requestPerformer: RequestPerformer? { get set }

    /// Child modifiers that can further process a matching request.
    var children: [ProxyModifier] { get }

    /// Array of modifiers to adjust the incoming request.
    var requestModifiers: [RequestModifier] { get }

    /// Array of modifiers to adjust the outgoing response.
    var responseModifiers: [ResponseModifier] { get }

    /// Reference to the parent modifier in the chain.
    var superProxyModifier: ProxyModifier? { get set }

    /// Determines if this proxy modifier should handle a request based on its URL.
    func matches(url: URI) -> Bool

    /// Processes an incoming ClientRequest and returns a ClientResponse.
    func process(request: ClientRequest) async throws -> ClientResponse
}

public extension ProxyModifier {

    var requestPerformer: RequestPerformer? { nil }

    var children: [ProxyModifier] { [] }

    var superProxyModifier: ProxyModifier? { nil }

    /// Retrieves the request performer by checking self and recursively up the chain.
    var currentRequestPerformer: RequestPerformer? {
        requestPerformer ?? superProxyModifier?.currentRequestPerformer
    }

    /// Processes the request by:
    ///  1. Running all request modifiers.
    ///  2. Chaining any child proxy modifiers (if they match the request URL).
    ///  3. Falling back to a request performer.
    ///  4. Running all response modifiers on the received response.
    func process(request: ClientRequest) async throws -> ClientResponse {
        // Apply request modifiers sequentially.
        var mutableRequest = request
        for modifier in requestModifiers {
            try modifier.handle(request: &mutableRequest)
        }

        // Filter matching children for the given URL.
        let matchingChildren = children.filter { $0.matches(url: mutableRequest.url) }

        // Process the chain of matching children.
        let response: ClientResponse = try await processChain(for: matchingChildren, request: mutableRequest) { req in
            if let performer = self.currentRequestPerformer {
                return try await performer.handle(request: req)
            }
            throw StargateError.noRequestPerformer(url: req.url.string)
        }

        // Apply response modifiers sequentially.
        var mutableResponse = response
        for modifier in responseModifiers {
            try modifier.handle(response: &mutableResponse)
        }

        return mutableResponse
    }

    /// Processes an array of ProxyModifier as a chain.
    /// Each modifier is applied sequentially; the response from the last modifier is returned.
    private func processChain(for modifiers: [ProxyModifier],
                              request: ClientRequest,
                              defaultHandler: @escaping (ClientRequest) async throws -> ClientResponse) async throws -> ClientResponse {
        // If no matching modifiers, call the default handler.
        guard !modifiers.isEmpty else {
            return try await defaultHandler(request)
        }

        var currentResponse: ClientResponse?
        // Iterate the chain in order.
        for var modifier in modifiers {
            modifier.superProxyModifier = self
            currentResponse = try await modifier.process(request: request)
        }
        // Return the last response.
        if let finalResponse = currentResponse {
            return finalResponse
        }
        return try await defaultHandler(request)
    }
}
