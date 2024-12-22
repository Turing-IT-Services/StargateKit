//
//  WebServer.swift
//  StargateKit
//
//  Created by Murilo Araujo on 22/12/24.
//

import Vapor
import Foundation

public struct WebServer: RouteProtocol {
    let host: String
    let rootDirectory: URL
    
    public init(host: String, rootDirectory: URL) {
        self.host = host
        self.rootDirectory = rootDirectory
    }
    
    public func matches(url: URI) -> Bool {
        url.host == host
    }
    
    public func handle(request: Request) async throws -> Response {
        // Build the file path from the request URL
        let filePath = request.url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let fileURL = rootDirectory.appendingPathComponent(filePath.isEmpty ? "index.html" : filePath)
        
        // Read the file data
        do {
            let fileData = try Data(contentsOf: fileURL)
            var headers = HTTPHeaders()
            headers.add(name: .contentType, value: HTTPMediaType.fileExtension(fileURL.pathExtension) ?? "application/octet-stream")
            return Response(status: .ok, headers: headers, body: .init(data: fileData))
        } catch {
            // File not found
            return Response(status: .notFound)
        }
    }
}
