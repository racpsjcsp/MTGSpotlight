//
//  ScreenContentService.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation

protocol HomeContentServing {
    func fetchScreen(named resourceName: String) throws -> HomeScreen
}

struct LocalHomeContentService: HomeContentServing {
    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchScreen(named resourceName: String) throws -> HomeScreen {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw HomeContentServiceError.missingResource(resourceName)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(HomeScreen.self, from: data)
    }
}

enum HomeContentServiceError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case let .missingResource(resourceName):
            return String(format: Strings.homeContentMissingResourceErrorFormat, resourceName)
        }
    }
}
