//
//  DeckDetailViewModelTests.swift
//  MTGSpotlightTests
//
//  Created by Codex on 23/03/26.
//

import Foundation
import Testing
@testable import MTGSpotlight

@MainActor
struct DeckDetailViewModelTests {
    @Test func loadPublishesLoadedStateForRequestedDeck() async {
        let service = MockDeckDetailContentService()
        let viewModel = DeckDetailViewModel(deckID: "izzet-phoenix", contentService: service)

        await viewModel.load()

        guard case let .loaded(screen) = viewModel.state else {
            Issue.record("Expected loaded state after successful deck detail load")
            return
        }

        #expect(screen.title == "Izzet Phoenix Detail")
        #expect(service.requestedDeckDetailIDs == ["izzet-phoenix"])
    }

    @Test func loadPublishesErrorStateOnDeckDetailFailure() async {
        let service = MockDeckDetailContentService(result: .failure(MockDeckDetailError.failedToLoad))
        let viewModel = DeckDetailViewModel(deckID: "izzet-phoenix", contentService: service)

        await viewModel.load()

        guard case let .error(message) = viewModel.state else {
            Issue.record("Expected error state after failed deck detail load")
            return
        }

        #expect(message == MockDeckDetailError.failedToLoad.localizedDescription)
    }

    @Test func refreshActionReloadsDeckDetailScreen() async {
        let service = MockDeckDetailContentService()
        let viewModel = DeckDetailViewModel(deckID: "izzet-phoenix", contentService: service)

        await viewModel.load()
        await viewModel.handle(SpotlightAction.refresh)

        #expect(service.requestedDeckDetailIDs == ["izzet-phoenix", "izzet-phoenix"])
    }

    @Test func openURLActionPublishesPendingExternalURL() async {
        let service = MockDeckDetailContentService()
        let viewModel = DeckDetailViewModel(deckID: "izzet-phoenix", contentService: service)

        await viewModel.handle(SpotlightAction.openURL(URL(string: "https://example.com")!))

        #expect(viewModel.pendingExternalURL?.absoluteString == "https://example.com")
    }

    @Test func consumePendingExternalURLClearsPublishedURL() async {
        let service = MockDeckDetailContentService()
        let viewModel = DeckDetailViewModel(deckID: "izzet-phoenix", contentService: service)

        await viewModel.handle(SpotlightAction.openURL(URL(string: "https://example.com")!))
        viewModel.consumePendingExternalURL()

        #expect(viewModel.pendingExternalURL == nil)
    }
}

private final class MockDeckDetailContentService: SpotlightContentServing {
    enum Result {
        case success
        case failure(Error)
    }

    private let result: Result
    private(set) var requestedDeckDetailIDs: [String] = []

    init(result: Result = .success) {
        self.result = result
    }

    func fetchDeckSpotlight() async throws -> SpotlightScreen {
        SpotlightScreen.fixture(title: "Unused Spotlight")
    }

    func fetchDeckDetail(deckID: String) async throws -> SpotlightScreen {
        requestedDeckDetailIDs.append(deckID)

        switch result {
        case .success:
            return SpotlightScreen.fixture(title: "Izzet Phoenix Detail")
        case let .failure(error):
            throw error
        }
    }
}

private enum MockDeckDetailError: LocalizedError {
    case failedToLoad

    var errorDescription: String? {
        switch self {
        case .failedToLoad:
            return "Mock deck detail load failed."
        }
    }
}

private extension SpotlightScreen {
    @MainActor
    static func fixture(title: String) -> SpotlightScreen {
        SpotlightScreen(
            screenID: "fixture-screen",
            version: 1,
            title: title,
            components: [
                .hero(
                    id: "fixture-hero",
                    props: HeroSectionProps(
                        eyebrowTitle: "Deck Detail",
                        deckName: title,
                        tagline: "Fixture tagline",
                        stats: [HeroStat(id: "colors", title: "Colors", value: "Blue / Red")]
                    )
                )
            ]
        )
    }
}
