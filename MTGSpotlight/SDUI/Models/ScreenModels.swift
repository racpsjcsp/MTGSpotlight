//
//  ScreenModels.swift
//  MTGSpotlight
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation

struct SpotlightScreen: Decodable {
    let screenID: String
    let version: Int
    let title: String
    let components: [SpotlightComponent]

    enum CodingKeys: String, CodingKey {
        case screenID = "screenId"
        case version
        case title
        case components
    }

    init(
        screenID: String,
        version: Int,
        title: String,
        components: [SpotlightComponent]
    ) {
        self.screenID = screenID
        self.version = version
        self.title = title
        self.components = components
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screenID = try container.decode(String.self, forKey: .screenID)
        version = try container.decode(Int.self, forKey: .version)
        title = try container.decode(String.self, forKey: .title)

        var componentsContainer = try container.nestedUnkeyedContainer(forKey: .components)
        var decodedComponents: [SpotlightComponent] = []

        while !componentsContainer.isAtEnd {
            let componentDecoder = try componentsContainer.superDecoder()

            do {
                decodedComponents.append(try SpotlightComponent(from: componentDecoder))
            } catch {
#if DEBUG
                debugPrint("Skipping unsupported or malformed component:", error)
#endif
            }
        }

        components = decodedComponents
    }
}

enum SpotlightComponent: Decodable, Identifiable {
    case hero(id: String, props: HeroSectionProps)
    case text(id: String, props: TextSectionProps)
    case cardCarousel(id: String, props: CardCarouselProps)
    case button(id: String, props: ButtonSectionProps, action: SpotlightAction?)

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
            let action = try container.decodeIfPresent(SpotlightAction.self, forKey: .action)
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

struct SpotlightAction: Decodable {
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
}

enum CardTheme: String, Decodable {
    case phoenix
    case cruise
    case axe
}
