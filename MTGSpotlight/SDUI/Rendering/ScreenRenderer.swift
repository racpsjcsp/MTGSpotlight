//
//  ScreenRenderer.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import SwiftUI

struct ScreenRenderer: View {
    let components: [ScreenComponent]
    let actionHandler: (ScreenAction?) -> Void

    var body: some View {
        ForEach(components) { component in
            render(component)
        }
    }

    @ViewBuilder
    private func render(_ component: ScreenComponent) -> some View {
        switch component {
        case let .hero(_, props):
            HeroCardView(props: props)
        case let .text(_, props):
            TextSectionView(props: props)
        case let .cardCarousel(_, props):
            CardCarouselSectionView(props: props)
        case let .button(_, props, action):
            ActionButtonSectionView(props: props) {
                actionHandler(action)
            }
        }
    }
}
