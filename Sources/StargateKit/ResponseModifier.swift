//
//  ResponseModifier.swift
//  StargateKit
//
//  Created by Murilo Araujo on 08/03/25.
//

import Vapor

public protocol ResponseModifier: Sendable {
    /// Allows in–place modification of a ClientResponse.
    func handle(response: inout ClientResponse) throws
}
