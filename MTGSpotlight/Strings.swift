//
//  Strings.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 19/03/26.
//

import Foundation

struct Strings {
    static let deckSpotlightTitle = "Deck Spotlight"
    static let headerIconName = "sparkles"
    static let errorIconName = "exclamationmark.triangle"
    static let loadingDeckSpotlightTitle = "Loading Deck Spotlight..."
    static let loadingDeckDetailsTitle = "Loading Deck Details..."
    static let loadingFailedTitle = "Unable to Load Deck Spotlight"
    static let loadingDeckDetailsFailedTitle = "Unable to Load Deck Details"
    static let retryButtonTitle = "Retry"
    static let deckDetailsTitle = "Deck Details"
    static let spotlightContentMissingResourceErrorFormat = "The local JSON file '%@.json' could not be found."
    static let spotlightContentMissingAPIBaseURLError = "The API base URL is not configured for this device."
    static let spotlightContentInvalidResponseError = "The server returned an invalid response."
    static let spotlightContentRequestFailedErrorFormat = "The server request failed with status code %d."
}
