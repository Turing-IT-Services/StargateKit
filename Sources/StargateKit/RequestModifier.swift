//
//  RequestModifier.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Vapor

public protocol RequestModifier: Sendable {
    func handle(request: inout ClientRequest)
}
