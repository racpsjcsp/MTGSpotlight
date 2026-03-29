//
//  HomeView.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 19/03/26.
//

import SwiftUI

@MainActor
struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @State private var viewModel: HomeViewModel

    init() {
        _viewModel = State(initialValue: HomeViewModel())
    }

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        NavigationStack {
            content
                .background(backgroundGradient)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.pendingExternalURL) { _, url in
            guard let url else { return }
            openURL(url)
            viewModel.consumePendingExternalURL()
        }
        .sheet(item: $bindableViewModel.presentedDeckDetailRoute) { route in
            NavigationStack {
                DeckDetailView(deckID: route.id)
            }
            .presentationDetents([.large])
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView(Strings.loadingDeckSpotlightTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)

        case let .loaded(screen):
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ScreenRenderer(components: screen.components, actionHandler: viewModel.handle)
                }
                .padding(20)
            }

        case let .error(message):
            ContentUnavailableView {
                Label(Strings.loadingFailedTitle, systemImage: Strings.errorIconName)
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

        return Strings.deckSpotlightTitle
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.93, blue: 0.87),
                Color(red: 0.93, green: 0.95, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            contentService: LocalSpotlightContentService(bundle: .main)
        )
    )
}
