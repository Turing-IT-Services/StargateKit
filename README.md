# StargateKit

StargateKit is the core foundation behind **Stargate**, a Swift replacement for Nginx and Apigee. It's a simple yet powerful abstraction for implementing proxies, BFFs (Backend-For-Frontend), and quick web servers. This basic structure allows for more libraries to emerge with abstractions for authentication modifiers, response format translation modifiers, and more.

## Features

- **Routing Abstraction**: Match requests based on custom logic.
- **Static File Serving**: Host static files effortlessly.
- **Request and Response Modifiers**: Modify requests and responses using custom modifiers.
- **Proxy Endpoints**: Forward requests to other servers with ease.

## Getting Started

### Prerequisites

- Swift 5.7 or later
- macOS 12 or later
- [Vapor 4](https://vapor.codes/)

### Installation

Add StargateKit to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/StargateKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourProject",
        dependencies: [
            "StargateKit",
        ]
    )
]
```

Then run:

```shell
swift package update
```

## Usage

### Creating a Server

```swift
import StargateKit

let server = Server(
    port: 8080,
    hosts: ["localhost", "127.0.0.1"],
    routes: [
        // Add your routes here
    ]
)

Task {
    do {
        try await server.start()
    } catch {
        print("Failed to start server: \(error)")
    }
}
```

### Serving Static Files

```swift
let webServer = WebServer(
    host: "localhost",
    rootDirectory: URL(fileURLWithPath: "/path/to/your/static/files")
)

let server = Server(
    port: 8080,
    hosts: ["localhost"],
    routes: [webServer]
)
```

### Creating a Proxy Endpoint

```swift
let apiProxy = ProxyEndpoint(
    pathMatcher: { uri in
        uri.path.starts(with: "/api")
    },
    targetURL: URI(string: "https://api.yourbackend.com"),
    requestModifiers: [YourRequestModifier()],
    responseModifiers: [YourResponseModifier()]
)

let server = Server(
    port: 8080,
    hosts: ["localhost"],
    routes: [apiProxy]
)
```

### Implementing Request and Response Modifiers

```swift
struct AuthenticationModifier: RequestModifier {
    func handle(request: inout ClientRequest) {
        // Add authentication headers
        request.headers.add(name: "Authorization", value: "Bearer YOUR_TOKEN")
    }
}

struct JSONResponseModifier: ResponseModifier {
    func handle(response: inout ClientResponse) {
        // Modify the response, e.g., transform data
        if let bodyData = response.body?.readData(length: response.body?.readableBytes ?? 0),
           var jsonObject = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] {
            // Modify the JSON object
            jsonObject["modified"] = true
            if let newData = try? JSONSerialization.data(withJSONObject: jsonObject) {
                response.body = .init(data: newData)
            }
        }
    }
}
```

## Example

```swift
import StargateKit

struct AuthorizationModifier: RequestModifier {
    func handle(request: inout ClientRequest) {
        request.headers.add(name: "Authorization", value: "Bearer MY_SECRET_TOKEN")
    }
}

let webServer = WebServer(
    host: "localhost",
    rootDirectory: URL(fileURLWithPath: "/var/www/html")
)

let apiProxy = ProxyEndpoint(
    pathMatcher: { uri in
        uri.path.starts(with: "/api")
    },
    targetURL: URI(string: "https://api.example.com"),
    requestModifiers: [AuthorizationModifier()],
    responseModifiers: []
)

let server = Server(
    port: 8080,
    hosts: ["localhost"],
    routes: [webServer, apiProxy]
)

Task {
    do {
        try await server.start()
    } catch {
        print("Failed to start server: \(error)")
    }
}
```

## Documentation

- [API Reference](https://yourusername.github.io/StargateKit/)
- [Examples](https://github.com/yourusername/StargateKit/tree/main/Examples)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request. For major changes, please discuss them in an issue first to ensure they align with the project's goals.

## License

StargateKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
```

```markdown:LICENSE
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
...
```

**Note**: Replace `yourusername` with your actual GitHub username in the URLs.

## Directory Structure

```
StargateKit/
├── Package.swift
├── README.md
├── LICENSE
├── Sources/
│   └── StargateKit/
│       ├── Server.swift
│       ├── RouteProtocol.swift
│       ├── RequestModifier.swift
│       ├── ResponseModifier.swift
│       ├── WebServer.swift
│       ├── ProxyEndpoint.swift
│       └── HTTPMediaType+Extensions.swift
└── Tests/
    └── StargateKitTests/
        └── StargateKitTests.swift
```

## Additional Documentation

### Server Initialization

The `Server` struct is the entry point of StargateKit. It requires you to specify the `port`, `hosts`, and an array of `routes`.

- **port**: The port number on which the server will listen.
- **hosts**: An array of hostnames that the server will accept. Requests to other hosts will receive a `403 Forbidden`.
- **routes**: An array of objects conforming to `RouteProtocol`, which determine how requests are handled.

### Route Protocol

Conform to `RouteProtocol` to create custom routes. Implement the `matches(url:)` method to determine if the route should handle a request, and the `handle(request:)` method to process the request.

### Request and Response Modifiers

Modifiers allow you to intercept and modify requests and responses.

- **RequestModifier**: Modify outbound requests (e.g., add headers).
- **ResponseModifier**: Modify inbound responses (e.g., transform data).

### HTTPMediaType+Extensions

This extension facilitates setting the correct `Content-Type` header when serving static files.

### Testing

Unit tests are located in the `Tests` directory. Run tests using:

```shell
swift test
```
