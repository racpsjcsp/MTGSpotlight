//
//  CardCarouselSectionView.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import SwiftUI

struct CardCarouselSectionView: View {
    let props: CardCarouselProps

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(props.title)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(props.cards) { card in
                        CardPreviewView(card: card)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
