//
//  TextSectionView.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import SwiftUI

struct TextSectionView: View {
    let props: TextSectionProps

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(props.title)
                .font(.headline)

            Text(props.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
