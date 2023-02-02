# NetworkDispatcher

Simple network layer in swift.

## Installation

### In Xcode

To integrate NetworkDispatcher into your Xcode project as Swift package:

1. Select "File -> Add Packages..."
2. Enter "https://github.com/acidbeast/network-dispatcher".
3. Select "Add package".

### Swift package manager

Add NetworkDispatcher as a dependancy to your package is easy, just add it to the dependancies value of your Package.swift file.

```swift
dependencies: [
    .package(url: "https://github.com/acidbeast/network-dispatcher", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

### Create API Client

```swift
import NetworkDispatcher

enum SpacexAPI {
    case rockets
    case launches
}

extension SpaceXAPI: APIClient {

    var baseURL: URL {
        // Can be moved outside into configuration structure or class.
        guard let url = URL(string: "https://api.spacexdata.com/v4/") else {
            fatalError("URL is not provided")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .rockets:
            return "rockets"
        case .launches:
            return "rockets"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .rockets:
            return .get
        case .launches:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .rockets:
            return .request
        case .launches:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return [:]
    }
    
    var decoder: JSONDecoder {
        // Can be moved outside into configuration structure or class.
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    
}

```

### Making a request

```swift
import NetworkDispatcher

// Define data model.

struct Rocket: Decodable {
    let name: String
    let type: String
}

// Create NetworkDispatcher instance.

let dispatcher = NetworkDispatcher<SpacexAPI>()

// Make request

dispatcher.request(.rockets) { result in 
    dispatcher.handle {
        result: result,
        onSuccess: { (rockets: [Rocket]) in 
            print("Success: \(rockets)")
        },
        onError: { 
            print("Error: \(error)")
        }
    }
}

```

### Cancel request

```swift
dispatcher.cancel()
```


