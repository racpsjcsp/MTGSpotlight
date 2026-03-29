//
//  HomeViewModel.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 20/03/26.
//

import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class HomeViewModel {
    enum State {
        case loading
        case loaded(SpotlightScreen)
        case error(String)
    }

    struct DeckDetailRoute: Identifiable, Equatable {
        let id: String
    }

    private(set) var state: State = .loading
    private(set) var pendingExternalURL: URL?
    var presentedDeckDetailRoute: DeckDetailRoute?

    private let logger = Logger(subsystem: "com.rafaelplinio.MTGSpotlight", category: "HomeViewModel")
    private let contentService: SpotlightContentServing
    private var hasLoaded = false

    init() {
        self.contentService = RemoteSpotlightContentService()
    }

    init(contentService: SpotlightContentServing) {
        self.contentService = contentService
    }

    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        do {
            let content = try await contentService.fetchDeckSpotlight()
            state = .loaded(content)
        } catch {
            logger.error("Deck spotlight load failed: \(String(describing: error), privacy: .public)")
            state = .error(error.localizedDescription)
        }
    }

    func retry() async {
        hasLoaded = false
        state = .loading
        await load()
    }

    func handle(_ action: SpotlightAction?) {
        guard let action else { return }

        switch action {
        case let .openURL(url):
            pendingExternalURL = url
        case let .openDeck(deckID):
            presentedDeckDetailRoute = DeckDetailRoute(id: deckID)
        case .refresh:
            logger.info("Refresh action received")
        case let .unsupported(type, _):
            logger.info("Unsupported action received: \(type, privacy: .public)")
        }
    }

    func consumePendingExternalURL() {
        pendingExternalURL = nil
    }

    func dismissPresentedDeckDetailRoute() {
        presentedDeckDetailRoute = nil
    }
}
