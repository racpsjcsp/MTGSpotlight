//
//  SpotlightContentService.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation

protocol SpotlightContentServing {
    func fetchScreen(named resourceName: String) throws -> SpotlightScreen
}

struct LocalSpotlightContentService: SpotlightContentServing {
    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchScreen(named resourceName: String) throws -> SpotlightScreen {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw SpotlightContentServiceError.missingResource(resourceName)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(SpotlightScreen.self, from: data)
    }
}

enum SpotlightContentServiceError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case let .missingResource(resourceName):
            return String(format: Strings.spotlightContentMissingResourceErrorFormat, resourceName)
        }
    }
}
