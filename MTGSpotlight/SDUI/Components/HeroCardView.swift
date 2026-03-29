//
//  HeroCardView.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import SwiftUI

struct HeroCardView: View {
    let props: HeroSectionProps

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(props.eyebrowTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(props.deckName)
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text(props.tagline)
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(props.stats) { stat in
                    SpotlightStatView(title: stat.title, value: stat.value)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(alignment: .topTrailing) {
            Image(systemName: Strings.headerIconName)
                .font(.title2)
                .padding(18)
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
        }
    }
}
