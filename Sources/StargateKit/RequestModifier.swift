//
//  RequestModifier.swift
//  StargateKit
//
//  Created by Murilo Araujo on 08/03/25.
//

import Vapor

public protocol RequestModifier: Sendable {
    /// Allows in–place modification of a ClientRequest.
    func handle(request: inout ClientRequest) throws
}
