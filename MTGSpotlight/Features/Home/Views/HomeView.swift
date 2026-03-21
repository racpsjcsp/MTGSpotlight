//
//  HomeView.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 19/03/26.
//

import SwiftUI

@MainActor
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .background(backgroundGradient)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.load()
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: HomeViewModel(
                contentService: LocalSpotlightContentService(bundle: .main)
            )
        )
    }
}
