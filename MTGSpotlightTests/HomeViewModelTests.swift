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
            SpotlightAction(type: "openDeck", payload: ["deckId": "izzet-phoenix"])
        )

        guard case .loading = previousState else {
            Issue.record("Expected test precondition to start from loading state")
            return
        }

        guard case .loading = viewModel.state else {
            Issue.record("Handling an action should not mutate loading state yet")
            return
        }
    }
}

private final class MockSpotlightContentService: SpotlightContentServing {
    enum Result {
        case success
        case failure(Error)
    }

    private let result: Result
    private(set) var fetchCallCount = 0

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
                .text(
                    id: "fixture-text",
                    props: TextSectionProps(title: "Fixture", body: "Body")
                )
            ]
        )
    }
}
