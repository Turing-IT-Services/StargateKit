////
////  StargateKitTests.swift
////  StargateKit
////
////  Created by Murilo Araujo on 22/12/24.
////
//import Testing
//import Foundation
//@testable import StargateKit
//import Vapor
//
//@Suite("StargateKit Tests")
//struct StargateKitTests {
//    
//    // Helper function for async operations
//    func awaitResult<T>(_ future: EventLoopFuture<T>) throws -> T {
//        try future.wait()
//    }
//    
//    @Test("WebServer should correctly match routes")
//    func webServerRouteMatching() throws {
//        let webServer = WebServer(
//            host: "localhost",
//            rootDirectory: URL(fileURLWithPath: "/var/www/html")
//        )
//        
//        let matchingURI = URI(string: "http://localhost/index.html")
//        let nonMatchingURI = URI(string: "http://example.com/index.html")
//        
//        #expect(webServer.matches(url: matchingURI))
//        #expect(!webServer.matches(url: nonMatchingURI))
//    }
//    
//    @Test("ProxyEndpoint should correctly match API routes")
//    func proxyEndpointRouteMatching() throws {
//        let proxyEndpoint = ProxyEndpoint(
//            pathMatcher: { uri in
//                uri.path.starts(with: "/api")
//            },
//            targetURL: URI(string: "https://api.example.com")
//        )
//        
//        #expect(proxyEndpoint.matches(url: URI(path: "/api/users")))
//        #expect(!proxyEndpoint.matches(url: URI(path: "/home")))
//    }
//    
//    @Test("RequestModifier should modify request headers")
//    func requestModifier() throws {
//        struct MockRequestModifier: RequestModifier {
//            func handle(request: inout ClientRequest) {
//                request.headers.add(name: "X-Test-Header", value: "TestValue")
//            }
//        }
//        
//        var clientRequest = ClientRequest(
//            method: .GET,
//            url: URI(string: "https://api.example.com/data"),
//            headers: HTTPHeaders(),
//            body: nil
//        )
//        
//        let modifier = MockRequestModifier()
//        modifier.handle(request: &clientRequest)
//        
//        #expect(clientRequest.headers.first(name: "X-Test-Header") == "TestValue")
//    }
//    
//    @Test("ResponseModifier should modify response headers")
//    func responseModifier() throws {
//        struct MockResponseModifier: ResponseModifier {
//            func handle(response: inout ClientResponse) {
//                response.headers.add(name: "X-Modified", value: "True")
//            }
//        }
//        
//        var clientResponse = ClientResponse(
//            status: .ok,
//            headers: HTTPHeaders(),
//            body: nil
//        )
//        
//        let modifier = MockResponseModifier()
//        modifier.handle(response: &clientResponse)
//        
//        #expect(clientResponse.headers.first(name: "X-Modified") == "True")
//    }
//    
//    @Test("WebServer should serve static files correctly",
//          .traits(.requires(.init(trait: .filesystemAccess))))
//    func webServerFileServing() async throws {
//        // Create temporary test environment
//        let fileManager = FileManager.default
//        let tempDirectory = fileManager.temporaryDirectory
//            .appendingPathComponent(UUID().uuidString)
//        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
//        
//        let testFileURL = tempDirectory.appendingPathComponent("test.txt")
//        let testContent = "Hello, StargateKit!"
//        try testContent.write(to: testFileURL, atomically: true, encoding: .utf8)
//        
//        // Test file serving
//        let webServer = WebServer(
//            host: "localhost",
//            rootDirectory: tempDirectory
//        )
//        
//        let app = Application(.testing)
//        defer { app.shutdown() }
//        
//        let request = Request(
//            application: app,
//            method: .GET,
//            url: URI(path: "/test.txt"),
//            on: app.eventLoopGroup.next()
//        )
//        request.url.host = "localhost"
//        
//        let response = try awaitResult(webServer.handle(request: request))
//        
//        #expect(response.status == .ok)
//        #expect(response.body.string == testContent)
//        #expect(response.headers.contentType == .plainText)
//        
//        // Cleanup
//        try fileManager.removeItem(at: tempDirectory)
//    }
//    
//    @Test("ProxyEndpoint should forward requests correctly",
//          .traits(.networkAccess))
//    func proxyEndpoint() async throws {
//        let targetApp = Application(.testing)
//        defer { targetApp.shutdown() }
//        
//        targetApp.get("api", "test") { req in
//            "Mock Response"
//        }
//        
//        try targetApp.start()
//        let targetPort = targetApp.http.server.shared.localAddress?.port ?? 8080
//        let targetURL = URI(string: "http://localhost:\(targetPort)")
//        
//        let proxyEndpoint = ProxyEndpoint(
//            pathMatcher: { uri in
//                uri.path.starts(with: "/api")
//            },
//            targetURL: targetURL
//        )
//        
//        let app = Application(.testing)
//        defer { app.shutdown() }
//        
//        let request = Request(
//            application: app,
//            method: .GET,
//            url: URI(path: "/api/test"),
//            on: app.eventLoopGroup.next()
//        )
//        request.url.host = "localhost"
//        
//        let response = try awaitResult(proxyEndpoint.handle(request: request))
//        
//        #expect(response.status == .ok)
//        #expect(response.body.string == "Mock Response")
//    }
//    
//    @Test("Server should enforce host restrictions")
//    func serverHostRestriction() async throws {
//        let webServer = WebServer(
//            host: "localhost",
//            rootDirectory: URL(fileURLWithPath: "/tmp")
//        )
//        
//        let server = Server(
//            port: 8080,
//            hosts: ["localhost"],
//            routes: [webServer]
//        )
//        
//        let app = Application(.testing)
//        defer { app.shutdown() }
//        
//        // Test allowed host
//        let allowedRequest = Request(
//            application: app,
//            method: .GET,
//            url: URI(path: "/index.html"),
//            on: app.eventLoopGroup.next()
//        )
//        allowedRequest.url.host = "localhost"
//        
//        let allowedResponse = try awaitResult(server.handle(request: allowedRequest))
//        #expect([HTTPStatus.ok, .notFound].contains(allowedResponse.status))
//        
//        // Test disallowed host
//        let disallowedRequest = Request(
//            application: app,
//            method: .GET,
//            url: URI(path: "/index.html"),
//            on: app.eventLoopGroup.next()
//        )
//        disallowedRequest.url.host = "disallowed.com"
//        
//        let disallowedResponse = try awaitResult(server.handle(request: disallowedRequest))
//        #expect(disallowedResponse.status == .forbidden)
//    }
//    
//    @Test("Server handles requests with different HTTP methods",
//          arguments: [
//            HTTPMethod.GET,
//            HTTPMethod.POST,
//            HTTPMethod.PUT,
//            HTTPMethod.DELETE
//          ])
//    func serverHandlesHTTPMethods(method: HTTPMethod) async throws {
//        let webServer = WebServer(
//            host: "localhost",
//            rootDirectory: URL(fileURLWithPath: "/tmp")
//        )
//        
//        let server = Server(
//            port: 8080,
//            hosts: ["localhost"],
//            routes: [webServer]
//        )
//        
//        let app = Application(.testing)
//        defer { app.shutdown() }
//        
//        let request = Request(
//            application: app,
//            method: method,
//            url: URI(path: "/test"),
//            on: app.eventLoopGroup.next()
//        )
//        request.url.host = "localhost"
//        
//        let response = try awaitResult(server.handle(request: request))
//        #expect([HTTPStatus.ok, .notFound].contains(response.status))
//    }
//}
