# MTGSpotlight Vision

## Purpose

MTGSpotlight is an iOS app for presenting Magic: The Gathering deck spotlights.

The initial goal is not to build a fully dynamic product. The goal is to learn Server-Driven UI (SDUI) in a controlled way while keeping the code readable and easy to evolve.

The app will:

- fetch screen definitions from a Vapor backend
- render those definitions in SwiftUI
- use Scryfall as the source for card images and card-related metadata when needed

## Learning Goals

- understand the basics of SDUI without hiding the flow behind too many abstractions
- keep the client architecture familiar by using MVVM
- document each decision so the project remains easy to resume later
- add tests that protect the backend-client contract

## Product Scope For Phase 1

Phase 1 should stay intentionally small.

The first version of the app should support one deck spotlight screen with:

- a page title
- a deck title
- a short description
- a list of featured cards
- a call-to-action button

This is enough to learn the SDUI loop end to end:

1. backend defines screen JSON
2. app decodes JSON
3. app renders JSON into SwiftUI
4. user interaction sends actions back through the app layer

## Non-Goals For Phase 1

- full app-wide SDUI
- advanced personalization
- offline-first support
- complex navigation flows
- broad component catalog
- aggressive modularization

## Principles

- prefer clarity over flexibility
- keep the schema small until the rendering loop is stable
- add abstractions only after repeated use makes them necessary
- use documentation as part of the development process, not as a later cleanup step
