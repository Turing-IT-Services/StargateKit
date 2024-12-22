//
//  RouteProtocol.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Vapor

public protocol RouteProtocol: Sendable {
    func matches(url: URI) -> Bool
    func handle(request: Request) async throws -> Response
}
