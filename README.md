<p align="center">
  <img src="docs/icon.png" width="128" alt="Odjezdy icon">
</p>

<h1 align="center">Odjezdy</h1>

<p align="center">
  <b>Live public transport departures in your Mac's menu bar, for Prague and all of Czechia.</b><br>
  Click the tram icon and see what leaves next from the stop you're standing at: metro, tram, bus, train and ferry,<br>
  styled like the departure boards at the stops.
</p>

<p align="center">
  <img src="docs/screenshot-dark.png" width="380" alt="Odjezdy in dark mode">
  <img src="docs/screenshot-light.png" width="380" alt="Odjezdy in light mode">
</p>

*Odjezdy* is Czech for "departures". It covers **Prague and Central Bohemia (PID)** in full detail, and **the rest of Czechia** (Brno, Ostrava, Olomouc, Plzeň, Liberec, trains everywhere, …) through a community MOTIS server. No API key is needed to start. It is free and open source (GPL-3.0), and has no accounts or tracking.

| Where | Data source | Live data | Key |
|---|---|---|---|
| Prague + Central Bohemia (PID) | [Golemio](https://api.golemio.cz), Prague's official open-data API | metro, tram, bus, train; predictions to the second; stop notices | free key, optional |
| Prague without a key | [MOTIS @ motis.obehy.cz](https://motis.obehy.cz) | metro, trams, most lines (to the minute) | none |
| Rest of Czechia | [MOTIS @ motis.obehy.cz](https://motis.obehy.cz) | all trains; buses and trams in all regions except Karlovarský, Plzeňský and Vysočina (timetable there) | none |

---

## Contents

- [Features](#features)
- [Install](#install)
- [First start: the Golemio API key](#first-start-the-golemio-api-key)
- [How to use it](#how-to-use-it)
- [Privacy and battery](#privacy-and-battery)
- [How it works](#how-it-works)
- [Build from source](#build-from-source)
- [Updating the stop list](#updating-the-stop-list)
- [FAQ and troubleshooting](#faq-and-troubleshooting)
- [Data sources and credits](#data-sources-and-credits)
- [License](#license)

---

## Features

### Departure board
- **Live departures for the stop you're at.** One click finds where you are and shows the next departures. Live predictions have a green dot; departures without live data show their timetable time.
- **Grouped by transport type.** Metro, train, tram, bus and ferry each get their own section with the official PID line colours (A green, B yellow, C red, maroon trams, …), so you're not reading a mix of numbers.
- **"More" on every section.** Big stops like Dejvická or Anděl have dozens of departures; click **More ▾** on a section to see up to 12 later ones.
- **Second-accurate countdowns.** In the last 4 minutes, live departures count down as `3:25 … 0:40 … now` (with Golemio data, which predicts to the second; MOTIS data shows minutes). Further out they show `7 min`, and anything over an hour shows the clock time.
- **Pick your time format.** Prefer one style? ⚙︎ → *Time Format* switches every row to *Minutes Remaining* (`now`, `7 min`, `75 min`, never seconds) or *Departure Time* (`14:32`). *Automatic* is the mix described above.
- **Delays and cancellations.** A delayed departure shows the scheduled time crossed out next to the predicted one; cancelled trips are struck through in red.
- **Disruption notices.** Service notices for the stop (closures, moved stops, diversions) appear as an orange banner above the board: official PID notices via Golemio (in English when translated), and MOTIS alerts elsewhere.
- **Sign-style amber text** (optional): a nod to the LED boards at the stops (⚙︎ → *Sign-style Amber Text*).

### Smart stop picking
- **The stop people actually use, not just the nearest pole.** Nearby stops are ranked by how busy they are (weekday departures), how far they are, and whether they have metro or tram, so a major stop 300 m away beats a little-used one 100 m away.
- **Up to 3 nearby stops as tabs.** Switching tabs is instant, because all three are loaded together.
- **Remembers your choice.** If you pick the second tab at a place, Odjezdy prefers that stop next time you're there.
- **Distance to the nearest platform.** Big stops have platforms spread over hundreds of metres, so distance and walking time are measured to the closest platform, not the stop's centre.

### Walking time
- The header shows the **walking time** to the stop, e.g. `Praha · 290 m · 🚶 5 min`.
- **How it's calculated:** straight-line distance to the nearest platform, plus 25% because streets aren't straight, at a walking pace of 4.8 km/h (80 m/min). It's an estimate, worked out on your Mac with no route planning, so it can differ from Google Maps, especially where you have to go around a river, railway or big block.
- **Departures you can't reach in time are skipped.** A departure counts as reachable if it leaves after at least 75% of your walking time (you might hurry a bit). Only the last unreachable one in each section is kept, dimmed, in case you want to run for it, so the board doesn't fill up with trams leaving in the next 60 seconds.

### Leave-now alerts 🔔
- **Click any departure** to get a notification when it's time to walk to the stop: *"Leave within 5 min for 26 → Nádraží Hostivař"*.
- **It follows live delays:** while an alert is set, the departure is re-checked once a minute (even with the popover closed) and the alert moves if the tram does.
- **Adjustable lead time:** ⚙︎ → *Leave-Now Alert* → 1, 2, 3, 5 (default), 10 or 15 minutes.
- Click the same departure again, or *Cancel* in the banner, to remove it.

### Your lines ⭐
- **Right-click a departure → "Add 20 to Your Lines".** That line gets its own section at the top of the board for that stop.
- Saved per stop, so line 20 at Dejvická doesn't affect other stops.

### Find any stop 🔍
<img src="docs/search.png" width="340" align="right" alt="Stop search">

- Click 🔍 to **search any stop in the region you're in** and see its departures without being there. In Prague the search works offline; elsewhere it uses MOTIS's search, ranked towards where you are.
- Accents and capitals don't matter (`hlavni` finds *Hlavní nádraží*), and busy stops rank first.
- **Recent searches** are one click away.
- *Back to nearby* returns to the stops around you.

<br clear="right">

### A good menu bar citizen
- **Lives only in the menu bar**: no Dock icon, no windows.
- **Starts at login** automatically (toggle in ⚙︎).
- **Hides itself outside Czechia.** Open it from Spotlight to bring it back if you need it.
- **Follows macOS Light/Dark/Auto appearance** and your accent colour.
- **Universal app** for Apple silicon and Intel Macs.

---

## Install

**Requirements:** macOS 14 Sonoma or newer. A free Golemio API key is optional but recommended in Prague ([see below](#first-start-the-golemio-api-key)).

1. Download **`Odjezdy.zip`** from the [latest release](../../releases/latest).
2. Unzip it and drag **Odjezdy** into your **Applications** folder.
3. Open it. macOS will say it can't verify the developer, because the app isn't notarized (that needs a paid Apple developer account).
   - Click **Done**, then go to **System Settings → Privacy & Security**, scroll down and click **Open Anyway** next to *"Odjezdy" was blocked*. Confirm.
   - You only need to do this once.
4. Allow **Location** when asked. Odjezdy uses it only to find nearby stops; see [Privacy](#privacy-and-battery).
5. A tram icon appears in your menu bar. Click it, and that's it. In Prague, adding a Golemio key (below) gives you even better data.

> Prefer to build it yourself? See [Build from source](#build-from-source).

---

## First start: the Golemio API key

*Optional.* Without a key, Prague departures come from MOTIS, like the rest of Czechia. With a key, Prague uses **[Golemio](https://api.golemio.cz)**, the City of Prague's official open-data platform. You get predictions to the second (so the `3:25` countdown is exact), live data for buses, and official stop notices. It's free, but each user needs their own key:

1. Sign up at **[api.golemio.cz/api-keys](https://api.golemio.cz/api-keys/auth/sign-up)** and confirm your email.
2. Generate an API key and copy it (it's a long string).
3. Click the Odjezdy icon → ⚙︎ → **Golemio API Key (Prague, optional)…**, paste the key and press **Save**.

The key is stored only on your Mac (in the app's preferences) and is sent only to `api.golemio.cz`. The footer shows which source you're seeing (*Updated 18:28 · Golemio* or *· MOTIS*).

---

## How to use it

| Action | How |
|---|---|
| See departures | Click the tram icon in the menu bar |
| Switch between nearby stops | Click the tabs under the stop name |
| Show later departures of one type | Click **More ▾** on the section heading |
| Get a leave-now alert | Click a departure (click again to cancel) |
| Pin a line to the top | Right-click a departure → **Add … to Your Lines** |
| Look up another stop | Click 🔍 next to the stop name |
| Refresh now | Click ↻ (it also refreshes every 15 s while open) |
| Settings | Click ⚙︎: start at login, amber sign style, time format, alert lead time, API key, quit |

---

## Privacy and battery

- **No accounts, no analytics, no servers of our own.** The app talks only to `api.golemio.cz` and `motis.obehy.cz`, and only while the popover is open (or while a leave-now alert is pending).
- **Location is used for two things:**
  - a single location fix when you click the icon, to pick nearby stops;
  - macOS's low-power *significant location change* service (Wi-Fi based, wakes only on moves of roughly 500 m+), used to hide the icon outside Czechia. The country check is offline, using a border built into the app.
- **What is sent where:**
  - **In Prague:** your location never leaves your Mac. Stops are found offline from the stop list built into the app; Golemio/MOTIS are only asked for departures of specific stops.
  - **Elsewhere in Czechia:** to find nearby stops, the app asks MOTIS for stops in a ~1.3 km box around you, so the MOTIS server sees that approximate area, like any map app would. Search text is sent to MOTIS when you search there.
- **Lightweight:** about 35 MB of memory, ~0% CPU when idle, and no network use while the popover is closed. A Golemio refresh is about 8 KB per stop (compressed). MOTIS is polled every 30 s, to be gentle with a volunteer-run server.

---

## How it works

```
 click ──► one location fix ──► Prague: stop list built into the app (8,000+ PID stops, offline)
                                 elsewhere: MOTIS stops near you
                                     │  rank by busyness, distance to nearest platform, mode
                                     ▼
                       3 nearby stops ──► Golemio (Prague, key) or MOTIS (no key / rest of CZ)
                                     │
                                     ▼
            sections per mode · catchable filter · countdowns · notices · alerts
```

- **Stop list** (`Odjezdy/Resources/stops_prague.json`, ~1.4 MB): every PID stop with its platforms, Golemio stop IDs, line colours and a busyness score, generated from the official PID GTFS feed by [`tools/build_stops.py`](tools/build_stops.py).
- **Live data, Prague**: `GET https://api.golemio.cz/v2/pid/departureboards` with the selected stops' GTFS IDs. It returns predicted times (to the second), delays, cancellations and service notices.
- **Live data, everywhere else** (and Prague without a key): the [MOTIS API](https://redocly.github.io/redoc?url=https://raw.githubusercontent.com/motis-project/motis/refs/tags/v2.11.4/openapi.yaml) at `motis.obehy.cz`: `/api/v1/map/stops` for nearby stops, `/api/v1/stoptimes` for departures and alerts, `/api/v1/geocode` for search. The app identifies itself in the User-Agent (`Odjezdy/<version> (+repo URL)`), as the server operator asks.
- **Country check**: `Odjezdy/Resources/cz_border.json`, from Natural Earth via [`tools/build_border.py`](tools/build_border.py).
- **Code layout:**

| File | What it does |
|---|---|
| `OdjezdyApp.swift` | Menu bar item, app delegate, notification presentation, menu bar icon drawing |
| `AppState.swift` | Location → stops → fetch loop, sections, tabs, search, favourites |
| `StopIndex.swift` | Loads the stop list, nearby ranking, search |
| `GolemioClient.swift` | Golemio API client and parsing |
| `MotisClient.swift` | MOTIS client (stops, departures, alerts, search) and the Prague provider that picks Golemio or MOTIS |
| `CountryBorder.swift` | Offline "inside Czechia?" check |
| `LocationService.swift` | One-shot location and significant-change monitoring |
| `LeaveAlert.swift` | Leave-now notifications that follow live delays |
| `PopoverView.swift` / `DeparturesView.swift` | The UI |
| `Region.swift` | Prague (PID) and Czechia |

---

## Build from source

You need **Xcode 16 or newer** (free on the Mac App Store).

```bash
git clone https://github.com/rp20048/OdjezdyPraha.git
cd OdjezdyPraha
open Odjezdy.xcodeproj
```

Press **⌘R** to run. To install a release build into `/Applications`:

```bash
scripts/install.sh
```

**Signing (recommended):** in Xcode, select the **Odjezdy** target → **Signing & Capabilities** → **Team** → your Apple ID (a free *Personal Team* is enough). Without a team the app is signed to run locally only, which works, but macOS may ask for location permission again after every rebuild. From the command line you can pass your team instead:

```bash
DEVELOPMENT_TEAM=YOURTEAMID scripts/install.sh
```

**Make a release zip** (universal, Apple silicon + Intel):

```bash
scripts/package.sh      # → dist/Odjezdy.zip
```

**Debugging tips:**

- Live log:
  ```bash
  log stream --predicate 'subsystem == "io.github.rp20048.Odjezdy"'
  ```
- Fake a location (e.g. Old Town Square):
  ```bash
  defaults write io.github.rp20048.Odjezdy debugLocation "50.0875,14.4213"
  ```
  Remove it again with:
  ```bash
  defaults delete io.github.rp20048.Odjezdy debugLocation
  ```

---

## Updating the stop list

The stop list changes slowly, so refreshing it every few months is plenty:

```bash
curl -o /tmp/pid.zip https://data.pid.cz/PID_GTFS.zip
curl -o /tmp/pid-stops.json https://data.pid.cz/stops/json/stops.json
python3 tools/build_stops.py --region prague --gtfs /tmp/pid.zip --pid-stops /tmp/pid-stops.json
```

Then rebuild the app. The script needs only Python 3, and takes about a minute.

---

## FAQ and troubleshooting

**The icon disappeared.**
You're probably outside Czechia, so it hides itself. Open **Odjezdy** from Spotlight or Applications, and the icon comes back for the rest of the session.

**The footer says "MOTIS" in Prague even though I entered a Golemio key.**
The key was rejected (or Golemio was briefly down), so the app fell back to MOTIS. Check that you copied the whole key, and that it's active in your Golemio account.

**No live data (no green dots) in Plzeň, Karlovy Vary or Vysočina.**
MOTIS has only timetable data for those regions, so departures show their scheduled times.

**I don't get leave-now notifications.**
1. Check **System Settings → Notifications → Odjezdy**: notifications on, style *Banners* or *Alerts*.
2. Check whether a **Focus / Do Not Disturb** mode is on (Control Centre → Focus). Focus mutes app notifications. Either turn it off, or add Odjezdy under **System Settings → Focus → (your Focus) → Allowed Notifications → Apps**.
   *(Apps can only break through Focus with Apple's "Time Sensitive" entitlement, which requires a paid developer account.)*

**The distance or nearest stop looks wrong.**
macOS gets your location from nearby Wi-Fi, which is usually accurate to tens of metres, but can be off when there's little Wi-Fi around. Use 🔍 to pick a stop manually.

**Why isn't it on the Mac App Store, or notarized?**
Both require a paid Apple Developer account (€99/year). This is a free hobby project.

**Can it support another country?**
The code is built around a `Region` enum and a `DepartureProvider` protocol. A fork can add another network by providing stops and a client for that network's live-data API. Any MOTIS instance would work with the existing `MotisClient`.

---

## Data sources and credits

- **Live departures and notices:** [Golemio](https://api.golemio.cz), the City of Prague's data platform (operated by Operátor ICT, a.s.). Use of the API is subject to Golemio's terms.
- **Stops, lines and colours (Prague):** [PID open data](https://data.pid.cz) (GTFS and stop list), published by ROPID. See [pid.cz/opendata](https://pid.cz/opendata/) for the data license and terms.
- **All of Czechia:** the community [MOTIS](https://github.com/motis-project/motis) instance at [motis.obehy.cz](https://motis.obehy.cz), generously offered for this project by its operator. Thank you!
- **Border:** [Natural Earth](https://www.naturalearthdata.com) (public domain).
- Icons: Apple SF Symbols.

Odjezdy is an independent hobby project and is **not affiliated with PID, ROPID, DPP, the City of Prague, or any transport operator.**

---

## License

Copyright © 2026 Richard Pospisil

This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License v3.0** as published by the Free Software Foundation. See [LICENSE](LICENSE) for the full text.

The bundled stop data is derived from PID open data and remains subject to its own license.
