//
//  ScreenModels.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation
import SwiftUI

struct HomeScreen: Decodable {
    let screenID: String
    let version: Int
    let title: String
    let components: [ScreenComponent]

    enum CodingKeys: String, CodingKey {
        case screenID = "screenId"
        case version
        case title
        case components
    }
}

enum ScreenComponent: Decodable, Identifiable {
    case hero(id: String, props: HeroSectionProps)
    case text(id: String, props: TextSectionProps)
    case cardCarousel(id: String, props: CardCarouselProps)
    case button(id: String, props: ButtonSectionProps, action: ScreenAction?)

    var id: String {
        switch self {
        case let .hero(id, _),
             let .text(id, _),
             let .cardCarousel(id, _),
             let .button(id, _, _):
            id
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case props
        case action
    }

    private enum ComponentType: String, Decodable {
        case hero
        case text
        case cardCarousel
        case button
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(ComponentType.self, forKey: .type)

        switch type {
        case .hero:
            let props = try container.decode(HeroSectionProps.self, forKey: .props)
            self = .hero(id: id, props: props)
        case .text:
            let props = try container.decode(TextSectionProps.self, forKey: .props)
            self = .text(id: id, props: props)
        case .cardCarousel:
            let props = try container.decode(CardCarouselProps.self, forKey: .props)
            self = .cardCarousel(id: id, props: props)
        case .button:
            let props = try container.decode(ButtonSectionProps.self, forKey: .props)
            let action = try container.decodeIfPresent(ScreenAction.self, forKey: .action)
            self = .button(id: id, props: props, action: action)
        }
    }
}

struct HeroSectionProps: Decodable {
    let eyebrowTitle: String
    let deckName: String
    let tagline: String
    let stats: [HeroStat]
}

struct HeroStat: Decodable, Identifiable {
    let id: String
    let title: String
    let value: String
}

struct TextSectionProps: Decodable {
    let title: String
    let body: String
}

struct CardCarouselProps: Decodable {
    let title: String
    let cards: [SpotlightCard]
}

struct ButtonSectionProps: Decodable {
    let title: String
}

struct ScreenAction: Decodable {
    let type: String
    let payload: [String: String]
}

struct SpotlightCard: Decodable, Identifiable {
    let id: String
    let name: String
    let typeLine: String
    let manaCost: String
    let note: String
    let theme: CardTheme

    var gradient: LinearGradient {
        theme.gradient
    }
}

enum CardTheme: String, Decodable {
    case phoenix
    case cruise
    case axe

    var gradient: LinearGradient {
        switch self {
        case .phoenix:
            LinearGradient(
                colors: [.orange, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cruise:
            LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .axe:
            LinearGradient(
                colors: [.pink, .red.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
