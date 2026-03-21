//
//  ActionButtonSectionView.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import SwiftUI

struct ActionButtonSectionView: View {
    let props: ButtonSectionProps
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(props.title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
    }
}
