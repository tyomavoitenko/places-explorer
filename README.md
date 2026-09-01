# Places Explorer

[![CI](https://github.com/tyomavoitenko/places-explorer/actions/workflows/ci.yml/badge.svg)](https://github.com/tyomavoitenko/places-explorer/actions/workflows/ci.yml)

A small Flutter app that finds points of interest near you, shows them on a
map, and lets you favourite them and jot a private note. Built as a portfolio
project to demonstrate a pragmatic feature-first architecture and the common
Flutter toolchain — BLoC, Freezed, Dio/Retrofit, `flutter_map`, geolocation,
`get_it`, `go_router`, `hydrated_bloc`, code generation and testing — not to be
a feature-complete product.

## What it does

1. On launch, requests location permission and gets your current position.
2. Fetches nearby places from the [Geoapify Places API](https://apidocs.geoapify.com/docs/places/).
3. Shows them as category markers on an OpenStreetMap map, centred on you.
4. Tap a marker → a card with the basics; tap the card → a details sheet.
5. Filter by category (server-side) or search by name (client-side, debounced).
6. Favourite a place — it persists across restarts and has its own screen.
7. Add a note with an optional 1–5 rating — also persisted.

The permission flow handles services-off, denied, and denied-forever, with an
"use approximate location" fallback.

## Screenshots

<!-- Add images to docs/screenshots/ and reference them here. -->
| Map + markers | Details sheet | Favorites |
| --- | --- | --- |
| _todo_ | _todo_ | _todo_ |

## Architecture

Feature-first, with a deliberately light touch — Clean Architecture layering
only where it buys testability or a real seam.

```
lib/
  main.dart                     # bootstrap: HydratedStorage, DI, runApp
  app.dart                      # MaterialApp.router, global cubits, theme
  core/
    config/app_env.dart         # compile-time GEOAPIFY_API_KEY
    di/injector.dart            # get_it registrations + lifetime notes
    error/app_failure.dart      # sealed failure set (network/server/location/…)
    location/location_service.dart
    network/                    # Dio factory, api-key interceptor, error mapper
    router/app_router.dart      # go_router: / , /favorites , /place/:id
    utils/
  features/
    places/
      data/
        api/                    # @RestApi PlacesApiService (1:1 with the endpoint)
        models/                 # GeoJSON DTOs (Freezed + json_serializable)
        mappers/                # DTO -> entity, plain functions
        repositories/           # PlacesRepositoryImpl (builds circle:/proximity:)
      domain/
        entities/               # Place, PlaceCategory — no Flutter imports
        repositories/           # PlacesRepository (abstract)
      presentation/
        bloc/                   # PlacesBloc + Freezed events/states
        pages/ widgets/
    favorites/                  # HydratedCubit, no repository (no swappable backend)
    notes/                      # HydratedCubit + a Form
```

Key decisions:

- **`PlacesBloc` is a full Event/State BLoC**; favourites and notes are
  `HydratedCubit`s. A cubit models "toggle"/"save" fine; events would be
  ceremony. `PlacesBloc` uses `bloc_concurrency` transformers — `restartable`
  for location/category, `restartable` + a debounce for search, `droppable` for
  refresh.
- **One `PlacesState` class with a `status` enum**, not a state union — so the
  map keeps its markers visible during a refresh.
- **DTOs are separate from entities.** `PlacePropertiesDto` mirrors the GeoJSON
  wire shape; a mapper turns it into `Place` (name fallback, distance rounding,
  category classification from Geoapify's nested `categories` array).
- **The repository owns Geoapify's quirks** (`circle:lon,lat,radius` — longitude
  first). The `@RestApi` service is a literal 1:1 of the HTTP endpoint.
- **`AppFailure` is a hand-written `sealed` class, not Freezed** — the variants
  carry almost no data. Freezed is used where it earns its keep: DTOs, entities,
  BLoC events/states.
- **No `injectable`** — for ~10 registrations, an explicit list in
  `injector.dart` is more readable than generated code.
- **`hydrated_bloc` for persistence** — favourites store a full `Place` snapshot
  so the favourites screen needs no network.

## Tech

| Area | Package |
| --- | --- |
| State management | `flutter_bloc`, `bloc_concurrency` |
| Persistence | `hydrated_bloc` |
| Models / codegen | `freezed`, `json_serializable`, `build_runner` |
| Networking | `dio`, `retrofit` |
| Maps | `flutter_map` + OpenStreetMap tiles, `latlong2` |
| Location | `geolocator` |
| DI | `get_it` |
| Navigation | `go_router` |
| Testing | `flutter_test`, `bloc_test`, `mocktail` |

## Setup

Requires Flutter 3.38.x (Dart 3.10).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Get a free [Geoapify](https://myprojects.geoapify.com) API key (no card), then:

```bash
cp dart_define.example.json dart_define.json   # add your key to this file
flutter run --dart-define-from-file=dart_define.json
```

`dart_define.json` is gitignored. Without a key the app runs but shows a banner
and the API calls fail.

Tests need no key — they stub the network and platform channels:

```bash
flutter test
```

## API attribution

Place data from the **Geoapify Places API**, which is sourced from
**© OpenStreetMap contributors** (Open Database License). Map tiles from the
**OpenStreetMap** public tile server. Both attributions are shown on the map.

## Known limitations

- **Codegen stack is pinned to the analyzer-7 era.** `freezed` /
  `json_serializable` / `build_runner` on this Flutter version cap `analyzer`
  below 8, and the newer `retrofit_generator` doesn't compile under Dart 3.10.
  The working combination is `retrofit 4.5.0` + `retrofit_generator 9.3.0`.
  Moving to a newer Flutter would lift this.
- **`/place/:id` deep links need the app warm.** The `Place` is passed as
  go_router `extra`; a cold deep link shows a "open from the map" fallback since
  there's no "fetch one place by id" call wired.
- **Public OSM tile server.** Fine for a demo; a real deployment needs a proper
  tile provider (the app prints OSM's usage-policy warning in debug).
- Search is client-side over the loaded page (up to 40 results); there's no
  pagination.
- No dark-map tiles — the OSM raster tiles are light in both themes.

## Possible next steps

- Marker clustering at low zoom
- `url_launcher` on the website / "open in maps" actions
- Pull the full place record (photos, hours) via Geoapify Place Details
- Offline cache of the last result set
- `connectivity_plus` for an explicit offline state
- Localisation
