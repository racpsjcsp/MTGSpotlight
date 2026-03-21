//
//  CardPreviewView.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import SwiftUI

struct CardPreviewView: View {
    let card: SpotlightCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(card.gradient)
                .frame(width: 160, height: 220)
                .overlay(alignment: .topLeading) {
                    Text(card.manaCost)
                        .font(.caption.weight(.bold))
                        .padding(10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(12)
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.name)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(card.typeLine)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(14)
                }

            Text(card.note)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 160, alignment: .leading)
        }
    }
}
