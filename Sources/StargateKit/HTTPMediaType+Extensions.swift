//
//  HTTPMediaType+Extensions.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Vapor

extension HTTPMediaType {
    static func fileExtension(_ ext: String) -> String? {
        switch ext.lowercased() {
        case "html": return "text/html"
        case "css": return "text/css"
        case "js": return "application/javascript"
        case "json": return "application/json"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "svg": return "image/svg+xml"
        case "ico": return "image/x-icon"
        default: return nil
        }
    }
}
