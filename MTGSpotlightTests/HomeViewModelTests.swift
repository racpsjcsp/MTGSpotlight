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
    @Test func loadPublishesLoadedStateForSelectedVariant() {
        let service = MockSpotlightContentService()
        let viewModel = HomeViewModel(contentService: service)

        viewModel.load()

        guard case let .loaded(screen) = viewModel.state else {
            Issue.record("Expected loaded state after successful load")
            return
        }

        #expect(screen.title == "Phoenix Screen")
        #expect(service.requestedResources == ["deck-spotlight"])
    }

    @Test func selectVariantReloadsUsingNewResourceName() {
        let service = MockSpotlightContentService()
        let viewModel = HomeViewModel(contentService: service)

        viewModel.load()
        viewModel.selectVariant(.control)

        guard case let .loaded(screen) = viewModel.state else {
            Issue.record("Expected loaded state after selecting a new variant")
            return
        }

        #expect(viewModel.selectedVariant == .control)
        #expect(screen.title == "Control Screen")
        #expect(service.requestedResources == ["deck-spotlight", "deck-spotlight-control"])
    }

    @Test func loadPublishesErrorStateOnServiceFailure() {
        let service = MockSpotlightContentService(result: .failure(MockError.failedToLoad))
        let viewModel = HomeViewModel(contentService: service)

        viewModel.load()

        guard case let .error(message) = viewModel.state else {
            Issue.record("Expected error state after service failure")
            return
        }

        #expect(message == MockError.failedToLoad.localizedDescription)
    }

    @Test func handleActionAcceptsOpenDeckAction() {
        let viewModel = HomeViewModel(contentService: MockSpotlightContentService())
        let previousVariant = viewModel.selectedVariant
        let previousState = viewModel.state

        viewModel.handle(
            SpotlightAction(type: "openDeck", payload: ["deckId": "izzet-phoenix"])
        )

        #expect(viewModel.selectedVariant == previousVariant)

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
    private(set) var requestedResources: [String] = []

    init(result: Result = .success) {
        self.result = result
    }

    func fetchScreen(named resourceName: String) throws -> SpotlightScreen {
        requestedResources.append(resourceName)

        switch result {
        case .success:
            switch resourceName {
            case "deck-spotlight":
                return SpotlightScreen.fixture(title: "Phoenix Screen")
            case "deck-spotlight-control":
                return SpotlightScreen.fixture(title: "Control Screen")
            case "deck-spotlight-midrange":
                return SpotlightScreen.fixture(title: "Midrange Screen")
            default:
                return SpotlightScreen.fixture(title: "Fallback Screen")
            }
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
