# Pokemon iOS App

An example Pokémon app built with SwiftUI and modern Swift concurrency. It features a clear layered architecture, networking, image loading and caching, dominant color extraction, and comprehensive unit tests.

## Features

- List and detail screens built with SwiftUI
- MVVM architecture with clean separation of data and views
- Unified API and networking layer
- Asynchronous image loading with caching
- Dominant color analysis for adaptive theming
- Centralized extensions and utilities for readability and reuse
- Comprehensive unit tests covering key functionality

## Architecture Overview

The project uses a layered design with clear boundaries and simple dependencies:

- UI Layer (`CustomUI/`)
  - `PokemonListView.swift`: List screen displaying basic info and images
  - `PokemonDetailView.swift`: Detail screen with richer information and theme color
  - `AsynImageView.swift`: Asynchronous image view working with image loader and cache
  - `ViewModel/`: ViewModels in MVVM, responsible for state and data flow
- API Layer (`API/`)
  - `Endpoints.swift`: Centralized endpoint definitions and request construction
  - `APIService.swift`: Business-facing service layer encapsulating fetch logic
  - `APIModels.swift`: Data models for decoding network responses
- Tools Layer (`Tools/`)
  - `Network.swift`: Low-level networking and response handling
  - `DataLoader.swift` / `DataStorageReader.swift`: Data loading and local read/write
  - `ImageLoader.swift`: Image loading, caching, and memory management
  - `ImageColorAnalyzer.swift`: Dominant color extraction for dynamic theming
  - `EnvironmentValues/`: Inject dependencies and configuration via SwiftUI Environment
- Extensions (`Extensions/`)
  - `Color.swift`, `UIImage.swift`, `ViewModifier.swift`: Common type extensions and modifiers

## Directory Structure

```
Pokemon/
├── API/
│   ├── APIModels.swift
│   ├── APIService.swift
│   ├── Endpoints.swift
│   └── Pokemon/
├── Assets.xcassets/
├── CustomUI/
│   ├── AsynImageView.swift
│   ├── PokemonDetailView.swift
│   ├── PokemonListView.swift
│   └── ViewModel/
├── Extensions/
│   ├── Color.swift
│   ├── UIImage.swift
│   └── ViewModifier.swift
├── PokemonApp.swift
└── Tools/
    ├── DataLoader.swift
    ├── DataStorageReader.swift
    ├── EnvironmentValues/
    ├── ImageColorAnalyzer.swift
    ├── ImageLoader.swift
    └── Network.swift
```

Tests and UI tests are located at:

```
PokemonTests/
├── API/
│   ├── APIServiceTests.swift
│   ├── EndpointsAndRequestTests.swift
│   ├── PokemonAPIModelsTests.swift
│   └── PokemonServiceTests.swift
├── Extensions/
│   ├── ColorExtensionTests.swift
│   ├── UIImageExtensionTests.swift
│   └── URLStringExtensionTests.swift
└── Tools/
    ├── ImageColorAnalyzerTests.swift
    ├── ImageLoaderTests.swift
    └── NetworkServiceTests.swift
```

## Requirements

- Xcode 16.0 or later
- iOS 16.0 or later (use the latest simulator recommended)
- No third-party dependencies; uses standard library and system frameworks

## Testing

- Unit tests cover: API services, endpoint construction, model decoding, tools (image loading, dominant color analysis, networking), and extensions

## Acknowledgments

- Public data source: PokeAPI