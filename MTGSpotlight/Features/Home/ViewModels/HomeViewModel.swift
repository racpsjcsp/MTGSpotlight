//
//  HomeViewModel.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 20/03/26.
//

import Combine
import Foundation
import OSLog

@MainActor
final class HomeViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(SpotlightScreen)
        case error(String)
    }

    @Published private(set) var state: State = .loading

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

        switch action.type {
        case "openDeck":
            debugPrint("Open deck action received:", action.payload)
        default:
            debugPrint("Unsupported action received:", action.type)
        }
    }
}
