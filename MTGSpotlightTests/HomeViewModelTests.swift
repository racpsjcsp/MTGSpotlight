//
//  HomeViewModelTests.swift
//  MTGSpotlightTests
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation
import Testing
@testable import MTGSpotlight

@MainActor
struct HomeViewModelTests {
    @Test func loadPublishesLoadedStateForDeckSpotlight() async {
        let service = MockSpotlightContentService()
        let viewModel = HomeViewModel(contentService: service)

        await viewModel.load()

        guard case let .loaded(screen) = viewModel.state else {
            Issue.record("Expected loaded state after successful load")
            return
        }

        #expect(screen.title == "Phoenix Screen")
        #expect(service.fetchCallCount == 1)
    }

    @Test func retryReloadsAfterInitialSuccess() async {
        let service = MockSpotlightContentService()
        let viewModel = HomeViewModel(contentService: service)

        await viewModel.load()
        await viewModel.retry()

        guard case let .loaded(screen) = viewModel.state else {
            Issue.record("Expected loaded state after retrying")
            return
        }

        #expect(screen.title == "Phoenix Screen")
        #expect(service.fetchCallCount == 2)
    }

    @Test func loadPublishesErrorStateOnServiceFailure() async {
        let service = MockSpotlightContentService(result: .failure(MockError.failedToLoad))
        let viewModel = HomeViewModel(contentService: service)

        await viewModel.load()

        guard case let .error(message) = viewModel.state else {
            Issue.record("Expected error state after service failure")
            return
        }

        #expect(message == MockError.failedToLoad.localizedDescription)
    }

    @Test func handleActionAcceptsOpenDeckAction() {
        let viewModel = HomeViewModel(contentService: MockSpotlightContentService())
        let previousState = viewModel.state

        viewModel.handle(
            .openDeck(deckID: "izzet-phoenix")
        )

        guard case .loading = previousState else {
            Issue.record("Expected test precondition to start from loading state")
            return
        }

        guard case .loading = viewModel.state else {
            Issue.record("Handling an action should not mutate loading state yet")
            return
        }

        #expect(viewModel.presentedDeckDetailRoute?.id == "izzet-phoenix")
    }

    @Test func handleActionPublishesPendingExternalURLForOpenURL() {
        let viewModel = HomeViewModel(contentService: MockSpotlightContentService())

        viewModel.handle(
            .openURL(URL(string: "https://example.com/decks/izzet-phoenix")!)
        )

        #expect(viewModel.pendingExternalURL?.absoluteString == "https://example.com/decks/izzet-phoenix")
    }

    @Test func handleActionIgnoresUnsupportedAction() {
        let viewModel = HomeViewModel(contentService: MockSpotlightContentService())

        viewModel.handle(
            .unsupported(type: "surpriseAction", payload: ["deckId": "izzet-phoenix"])
        )

        #expect(viewModel.pendingExternalURL == nil)
    }

    @Test func consumePendingExternalURLClearsPublishedURL() {
        let viewModel = HomeViewModel(contentService: MockSpotlightContentService())

        viewModel.handle(
            .openURL(URL(string: "https://example.com")!)
        )
        viewModel.consumePendingExternalURL()

        #expect(viewModel.pendingExternalURL == nil)
    }

    @Test func dismissPresentedDeckClearsPublishedDeckRoute() {
        let viewModel = HomeViewModel(contentService: MockSpotlightContentService())

        viewModel.handle(.openDeck(deckID: "izzet-phoenix"))
        viewModel.dismissPresentedDeckDetailRoute()

        #expect(viewModel.presentedDeckDetailRoute == nil)
    }
}

private final class MockSpotlightContentService: SpotlightContentServing {
    enum Result {
        case success
        case failure(Error)
    }

    private let result: Result
    private(set) var fetchCallCount = 0
    private(set) var requestedDeckDetailIDs: [String] = []

    init(result: Result = .success) {
        self.result = result
    }

    func fetchDeckSpotlight() async throws -> SpotlightScreen {
        fetchCallCount += 1

        switch result {
        case .success:
            return SpotlightScreen.fixture(title: "Phoenix Screen")
        case let .failure(error):
            throw error
        }
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

private enum MockError: LocalizedError {
    case failedToLoad

    var errorDescription: String? {
        switch self {
        case .failedToLoad:
            return "Mock load failed."
        }
    }
}

private extension SpotlightScreen {
    static func fixture(title: String) -> SpotlightScreen {
        SpotlightScreen(
            screenID: "fixture-screen",
            version: 1,
            title: title,
            components: [
                .hero(
                    id: "fixture-hero",
                    props: HeroSectionProps(
                        eyebrowTitle: "Magic: The Gathering",
                        deckName: title,
                        tagline: "Fixture tagline",
                        stats: [
                            HeroStat(id: "colors", title: "Colors", value: "Blue / Red")
                        ]
                    )
                ),
                .text(
                    id: "fixture-text",
                    props: TextSectionProps(title: "Fixture", body: "Body")
                ),
                .cardCarousel(
                    id: "fixture-carousel",
                    props: CardCarouselProps(
                        title: "Featured Cards",
                        cards: [
                            SpotlightCard(
                                id: "fixture-card",
                                name: "Arclight Phoenix",
                                typeLine: "Creature",
                                manaCost: "3R",
                                note: "Recurring threat.",
                                theme: .phoenix
                            )
                        ]
                    )
                )
            ]
        )
    }
}
