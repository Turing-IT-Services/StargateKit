//
//  HTTPMethod+Extensions.swift
//  StargateKit
//
//  Created by Murilo Araujo on 21/01/25.
//

import Vapor

// Using retroactive conformance to allow HTTPMethod to be iterable.
// Note: This list is static. In future versions of Vapor, update this list if new HTTP methods are introduced.
extension HTTPMethod: @retroactive CaseIterable {
    public static var allCases: [HTTPMethod] {
        [
            .GET,
            .PUT,
            .ACL,
            .HEAD,
            .POST,
            .COPY,
            .LOCK,
            .MOVE,
            .BIND,
            .LINK,
            .PATCH,
            .TRACE,
            .MKCOL,
            .MERGE,
            .PURGE,
            .NOTIFY,
            .SEARCH,
            .UNLOCK,
            .REBIND,
            .UNBIND,
            .REPORT,
            .DELETE,
            .UNLINK,
            .CONNECT,
            .MSEARCH,
            .OPTIONS,
            .PROPFIND,
            .CHECKOUT,
            .PROPPATCH,
            .SUBSCRIBE,
            .MKCALENDAR,
            .MKACTIVITY,
            .UNSUBSCRIBE,
            .SOURCE
        ]
    }
}
