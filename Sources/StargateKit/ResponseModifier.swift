//
//  ResponseModifier.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Vapor

public protocol ResponseModifier: Sendable {
    func handle(response: inout ClientResponse)
}
