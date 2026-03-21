//
//  HomeViewModel.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 20/03/26.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    enum Variant: String, CaseIterable, Identifiable {
        case phoenix
        case control
        case midrange

        var id: String { rawValue }

        var title: String {
            switch self {
            case .phoenix:
                return "Phoenix"
            case .control:
                return "Control"
            case .midrange:
                return "Midrange"
            }
        }

        var resourceName: String {
            switch self {
            case .phoenix:
                return "deck-spotlight"
            case .control:
                return "deck-spotlight-control"
            case .midrange:
                return "deck-spotlight-midrange"
            }
        }
    }

    enum State {
        case loading
        case loaded(SpotlightScreen)
        case error(String)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var selectedVariant: Variant = .phoenix

    private let contentService: SpotlightContentServing
    private var hasLoaded = false

    init() {
        self.contentService = LocalSpotlightContentService(bundle: .main)
    }

    init(contentService: SpotlightContentServing) {
        self.contentService = contentService
    }

    func load() {
        guard !hasLoaded else { return }
        hasLoaded = true

        do {
            let content = try contentService.fetchScreen(named: selectedVariant.resourceName)
            state = .loaded(content)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func retry() {
        hasLoaded = false
        state = .loading
        load()
    }

    func selectVariant(_ variant: Variant) {
        guard selectedVariant != variant else { return }
        selectedVariant = variant
        retry()
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
