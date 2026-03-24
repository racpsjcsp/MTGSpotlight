//
//  DeckDetailViewModel.swift
//  MTGSpotlight
//
//  Created by Codex on 23/03/26.
//

import Combine
import Foundation
import OSLog

@MainActor
final class DeckDetailViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(SpotlightScreen)
        case error(String)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var pendingExternalURL: URL?

    let deckID: String

    private let logger = Logger(subsystem: "com.rafaelplinio.MTGSpotlight", category: "DeckDetailViewModel")
    private let contentService: SpotlightContentServing
    private var hasLoaded = false

    init(deckID: String) {
        self.deckID = deckID
        self.contentService = RemoteSpotlightContentService()
    }

    init(deckID: String, contentService: SpotlightContentServing) {
        self.deckID = deckID
        self.contentService = contentService
    }

    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        await reload()
    }

    func retry() async {
        hasLoaded = true
        await reload()
    }

    func handle(_ action: SpotlightAction?) async {
        guard let action else { return }

        switch action {
        case let .openURL(url):
            pendingExternalURL = url
        case .refresh:
            await retry()
        case let .openDeck(deckID):
            logger.info("Nested open deck action received inside deck detail for \(deckID, privacy: .public)")
        case let .unsupported(type, _):
            logger.info("Unsupported deck detail action received: \(type, privacy: .public)")
        }
    }

    func consumePendingExternalURL() {
        pendingExternalURL = nil
    }

    private func reload() async {
        state = .loading

        do {
            let screen = try await contentService.fetchDeckDetail(deckID: deckID)
            state = .loaded(screen)
        } catch {
            logger.error("Deck detail load failed for \(self.deckID, privacy: .public): \(String(describing: error), privacy: .public)")
            state = .error(error.localizedDescription)
        }
    }
}
