//
//  HTTPMediaType+Extensions.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Vapor

import Vapor

public extension HTTPMediaType {
    /// Returns the media type string for a given file extension.
    /// This method first looks into the fixed base mapping and then into the additionalMappings.
    static func fileExtension(_ ext: String) -> String? {
        let baseMapping: [String: String] = [
            "html": "text/html",
            "css": "text/css",
            "js": "application/javascript",
            "json": "application/json",
            "png": "image/png",
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "gif": "image/gif",
            "svg": "image/svg+xml",
            "ico": "image/x-icon"
        ]
        let key = ext.lowercased()
        return baseMapping[key]
    }
}
