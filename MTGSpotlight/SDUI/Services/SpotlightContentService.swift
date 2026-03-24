//
//  SpotlightContentService.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation

protocol SpotlightContentServing {
    func fetchDeckSpotlight() async throws -> SpotlightScreen
    func fetchDeckDetail(deckID: String) async throws -> SpotlightScreen
}

struct LocalSpotlightContentService: SpotlightContentServing {
    let resourceName: String
    let bundle: Bundle

    init(resourceName: String = "deck-spotlight", bundle: Bundle = .main) {
        self.resourceName = resourceName
        self.bundle = bundle
    }

    func fetchDeckSpotlight() async throws -> SpotlightScreen {
        try await loadScreen(resourceName: resourceName)
    }

    func fetchDeckDetail(deckID: String) async throws -> SpotlightScreen {
        try await loadScreen(resourceName: "deck-detail-\(deckID)")
    }

    private func loadScreen(resourceName: String) async throws -> SpotlightScreen {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw SpotlightContentServiceError.missingResource(resourceName)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(SpotlightScreen.self, from: data)
    }
}

struct RemoteSpotlightContentService: SpotlightContentServing {
    let baseURL: URL?
    let session: URLSession

    init(
        baseURL: URL? = nil,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchDeckSpotlight() async throws -> SpotlightScreen {
        try await fetchScreen(pathComponents: ["screens", "deck-spotlight"])
    }

    func fetchDeckDetail(deckID: String) async throws -> SpotlightScreen {
        try await fetchScreen(pathComponents: ["screens", "deck-detail", deckID])
    }

    private func fetchScreen(pathComponents: [String]) async throws -> SpotlightScreen {
        let baseURL = try baseURL ?? AppEnvironment.apiBaseURL()
        let endpoint = pathComponents.reduce(baseURL) { partialURL, component in
            partialURL.appending(path: component)
        }
        let (data, response) = try await session.data(from: endpoint)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotlightContentServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SpotlightContentServiceError.requestFailed(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(SpotlightScreen.self, from: data)
    }
}

enum AppEnvironment {
    static func apiBaseURL() throws -> URL {
        if
            let configuredURL = ProcessInfo.processInfo.environment["MTGSPOTLIGHT_API_BASE_URL"],
            let url = URL(string: configuredURL)
        {
            return url
        }

        if
            let configuredURL = Bundle.main.object(
                forInfoDictionaryKey: "MTGSpotlightAPIBaseURL"
            ) as? String,
            let url = URL(string: configuredURL)
        {
            return url
        }

#if targetEnvironment(simulator)
        return URL(string: "http://127.0.0.1:8080")!
#else
        throw SpotlightContentServiceError.missingAPIBaseURLConfiguration
#endif
    }
}

enum SpotlightContentServiceError: LocalizedError {
    case missingResource(String)
    case missingAPIBaseURLConfiguration
    case invalidResponse
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case let .missingResource(resourceName):
            return String(format: Strings.spotlightContentMissingResourceErrorFormat, resourceName)
        case .missingAPIBaseURLConfiguration:
            return Strings.spotlightContentMissingAPIBaseURLError
        case .invalidResponse:
            return Strings.spotlightContentInvalidResponseError
        case let .requestFailed(statusCode):
            return String(format: Strings.spotlightContentRequestFailedErrorFormat, statusCode)
        }
    }
}
