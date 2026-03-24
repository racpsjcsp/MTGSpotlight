//
//  DeckDetailView.swift
//  MTGSpotlight
//
//  Created by Codex on 23/03/26.
//

import SwiftUI

@MainActor
struct DeckDetailView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel: DeckDetailViewModel

    init(deckID: String) {
        _viewModel = StateObject(wrappedValue: DeckDetailViewModel(deckID: deckID))
    }

    init(deckID: String, contentService: SpotlightContentServing) {
        _viewModel = StateObject(wrappedValue: DeckDetailViewModel(deckID: deckID, contentService: contentService))
    }

    init(viewModel: DeckDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(detailBackground)
            .task {
                await viewModel.load()
            }
            .onChange(of: viewModel.pendingExternalURL) { _, url in
                guard let url else { return }
                openURL(url)
                viewModel.consumePendingExternalURL()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView(Strings.loadingDeckDetailsTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)

        case let .loaded(screen):
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ScreenRenderer(components: screen.components) { action in
                        Task {
                            await viewModel.handle(action)
                        }
                    }
                }
                .padding(20)
            }

        case let .error(message):
            ContentUnavailableView {
                Label(Strings.loadingDeckDetailsFailedTitle, systemImage: Strings.errorIconName)
            } description: {
                Text(message)
            } actions: {
                Button(Strings.retryButtonTitle) {
                    Task {
                        await viewModel.retry()
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        if case let .loaded(screen) = viewModel.state {
            return screen.title
        }

        return Strings.deckDetailsTitle
    }

    private var detailBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.99, green: 0.96, blue: 0.91),
                Color(red: 0.94, green: 0.96, blue: 0.99)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct DeckDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DeckDetailView(
                viewModel: DeckDetailViewModel(
                    deckID: "izzet-phoenix",
                    contentService: LocalSpotlightContentService(resourceName: "deck-detail-izzet-phoenix", bundle: .main)
                )
            )
        }
    }
}
