//
//  Strings.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 19/03/26.
//

import Foundation

struct Strings {
    nonisolated static let deckSpotlightTitle = "Deck Spotlight"
    nonisolated static let headerIconName = "sparkles"
    nonisolated static let errorIconName = "exclamationmark.triangle"
    nonisolated static let loadingDeckSpotlightTitle = "Loading Deck Spotlight..."
    nonisolated static let loadingDeckDetailsTitle = "Loading Deck Details..."
    nonisolated static let loadingFailedTitle = "Unable to Load Deck Spotlight"
    nonisolated static let loadingDeckDetailsFailedTitle = "Unable to Load Deck Details"
    nonisolated static let retryButtonTitle = "Retry"
    nonisolated static let deckDetailsTitle = "Deck Details"
    nonisolated static let spotlightContentMissingResourceErrorFormat = "The local JSON file '%@.json' could not be found."
    nonisolated static let spotlightContentMissingAPIBaseURLError = "The API base URL is not configured for this device."
    nonisolated static let spotlightContentInvalidResponseError = "The server returned an invalid response."
    nonisolated static let spotlightContentRequestFailedErrorFormat = "The server request failed with status code %d."
}
