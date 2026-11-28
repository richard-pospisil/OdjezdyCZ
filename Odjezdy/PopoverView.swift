import SwiftUI
import AppKit

struct PopoverView: View {
    @ObservedObject var state: AppState
    @AppStorage("ledStyle") private var ledStyle = false
    @AppStorage(LeaveAlert.bufferKey) private var alertBuffer = 5
    @AppStorage(TimeFormat.key) private var timeFormat = TimeFormat.automatic
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if state.editingKey {
                keyEntry
            } else {
            switch state.phase {
            case .ready:
                if state.searchOpen {
                    searchPanel
                } else if let g = state.selected {
                    header(g)
                    if state.searchedGroup?.id == g.id { searchedBar(g) }
                    else if state.groups.count > 1 { tabs }
                    if !state.notices.isEmpty { noticesBanner }
                    if let a = state.leaveAlert.pending { alertBanner(a) }
                    DeparturesView(group: g, sections: state.sections, hasData: state.hasDeparturesForSelected,
                                   live: state.live, ledStyle: ledStyle, timeFormat: timeFormat,
                                   onToggle: { state.toggleExpanded($0) },
                                   isAlertSet: { state.leaveAlert.isSet($0) },
                                   onAlert: { state.toggleLeaveAlert($0) },
                                   isFavourite: { state.isFavourite($0) },
                                   onFavourite: { state.toggleFavourite($0) })
                }
            case .idle, .locating:
                message(icon: nil, title: "Finding nearby stops…")
            case .noPermission:
                message(icon: "location.slash", title: "Location access is off",
                        detail: "Odjezdy needs your location only when you click, to find the nearest stop.",
                        button: ("Open Location Settings", openLocationSettings))
            case .noLocation:
                message(icon: "location.slash", title: "Couldn't determine your location",
                        detail: "Check that Wi-Fi is on, then try again.",
                        button: ("Try Again", { state.reload() }))
            case .outsideArea:
                message(icon: "globe.europe.africa", title: "You're not in Czechia",
                        detail: "Odjezdy shows departures for stops in Czechia.")
            case .needsKey:
                message(icon: "key", title: "Prague needs a free API key",
                        detail: "Live PID departures come from Golemio, Prague's open data API. Sign up, copy your key, and paste it here.",
                        button: ("Enter API Key…", { state.beginKeyEntry() }))
            case .noStops:
                message(icon: "mappin.slash", title: "No stops nearby")
            }
            }
            footer
        }
        .padding(12)
        .frame(width: 340)
        .onAppear { state.popoverOpened() }
        .onDisappear { state.popoverClosed() }
    }

    // MARK: Header

    private func header(_ g: StopGroup) -> some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(g.name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text([g.town, distanceText(g.distance)].filter { !$0.isEmpty }.joined(separator: " · "))
                    if g.isNearby {
                        Text("·")
                        Image(systemName: "figure.walk")
                        Text("\(g.walkMinutes) min")
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 4) {
                ForEach(g.modes.all, id: \.rawValue) { m in
                    Image(systemName: m.symbol)
                }
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            Button { state.openSearch() } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Find a stop in \(state.region?.name ?? "this area")")
        }
    }

    // MARK: Search

    private var searchPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Stop in \(state.region?.name ?? "this area")", text: $state.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused($searchFocused)
                    .onSubmit { if let first = state.searchResults.first { state.choose(first) } }
                    .onExitCommand { state.closeSearch() }
                Button("Cancel") { state.closeSearch() }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.primary.opacity(0.06)))

            if state.searchText.trimmingCharacters(in: .whitespaces).count < 2 && !state.searchResults.isEmpty {
                Text("RECENT").font(.system(size: 9.5, weight: .semibold)).tracking(0.8).foregroundStyle(.secondary)
            }
            if state.searchResults.isEmpty {
                Text(state.searchText.count < 2 ? "Type a stop name." : "No stops found.")
                    .font(.system(size: 11)).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 40)
            } else {
                VStack(spacing: 2) {
                    ForEach(state.searchResults) { g in
                        Button { state.choose(g) } label: {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(g.name).font(.system(size: 13, weight: .medium)).lineLimit(1)
                                    Text([g.town, g.distance > 0 ? distanceText(g.distance) : ""]
                                        .filter { !$0.isEmpty }.joined(separator: " · "))
                                        .font(.system(size: 10.5)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 3) {
                                    ForEach(g.modes.all, id: \.rawValue) { Image(systemName: $0.symbol) }
                                }
                                .font(.system(size: 10)).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .onAppear { searchFocused = true }
    }

    private func searchedBar(_ g: StopGroup) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
            Text("Searched stop").lineLimit(1)
            Spacer()
            Button { state.clearSearchedStop() } label: {
                HStack(spacing: 3) {
                    Image(systemName: "location.fill")
                    Text("Back to nearby")
                }
            }
            .buttonStyle(.borderless)
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
    }

    private var tabs: some View {
        HStack(spacing: 6) {
            ForEach(state.groups) { g in
                let on = g.id == state.selected?.id
                Button { state.select(g.id) } label: {
                    HStack(spacing: 4) {
                        Text(g.name).lineLimit(1)
                        Text(distanceText(g.distance)).foregroundStyle(on ? .primary : .secondary).opacity(0.7)
                    }
                    .font(.system(size: 11, weight: on ? .semibold : .regular))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(on ? Color.accentColor.opacity(0.22) : Color.primary.opacity(0.06)))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 10) {
            Group {
                if let t = state.lastUpdated, state.phase == .ready {
                    if state.live == .unavailable {
                        Label("Live data unavailable", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    } else {
                        Text("Updated \(t.formatted(date: .omitted, time: .shortened))"
                             + (state.dataSource.isEmpty ? "" : " · \(state.dataSource)"))
                            .help(state.dataSource == "MOTIS"
                                  ? "Data from motis.obehy.cz (to the minute). In Prague, add a free Golemio key for second-accurate times, live buses and notices."
                                  : "Data from Golemio, Prague's open-data API")
                    }
                } else {
                    Text(" ")
                }
            }
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
            .lineLimit(1)

            Spacer()

            Button { state.reload() } label: { Image(systemName: "arrow.clockwise") }
                .buttonStyle(.borderless)
                .help("Refresh")

            Menu {
                Toggle("Start at Login", isOn: $state.startAtLogin)
                Toggle("Sign-style Amber Text", isOn: $ledStyle)
                Picker("Time Format", selection: $timeFormat) {
                    ForEach(TimeFormat.allCases, id: \.self) { Text($0.title).tag($0) }
                }
                Picker("Leave-Now Alert", selection: $alertBuffer) {
                    ForEach(LeaveAlert.bufferChoices, id: \.self) { m in
                        Text("\(m) min before I must leave").tag(m)
                    }
                }
                Divider()
                Button("Golemio API Key (Prague, optional)…") { state.beginKeyEntry() }
                Divider()
                Button("Quit Odjezdy") { NSApp.terminate(nil) }
            } label: {
                Image(systemName: "gearshape")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
    }

    // MARK: Notices and alert

    private var noticesBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(state.notices.prefix(3), id: \.self) { n in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(n)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .help(n)
                }
            }
        }
        .font(.system(size: 11))
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.orange.opacity(0.12)))
    }

    private func alertBanner(_ a: LeaveAlert.Pending) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.fill").foregroundStyle(Color(red: 1.0, green: 0.69, blue: 0.0))
            Text("Alert at \(a.fireAt.formatted(date: .omitted, time: .shortened)) for \(a.line) → \(a.destination)")
                .lineLimit(1)
            Spacer(minLength: 4)
            Button("Cancel") { state.leaveAlert.cancel() }
                .buttonStyle(.borderless)
                .controlSize(.small)
        }
        .font(.system(size: 11))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.primary.opacity(0.06)))
    }

    // MARK: Key entry

    private var keyEntry: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Golemio API key (Prague)").font(.system(size: 13, weight: .semibold))
            Text("Optional. Without it Prague uses MOTIS too; with it you get second-accurate times, live buses and stop notices. Free at api.golemio.cz, stored only on this Mac.")
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 11)).foregroundStyle(.secondary)
            TextField("Paste key", text: $state.keyDraft)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11, design: .monospaced))
                .onSubmit { state.setGolemioKey(state.keyDraft) }
            HStack {
                Link("Get a key", destination: GolemioClient.signUpURL).font(.system(size: 11))
                Spacer()
                Button("Cancel") { state.editingKey = false }.controlSize(.small)
                Button("Save") { state.setGolemioKey(state.keyDraft) }
                    .controlSize(.small)
                    .keyboardShortcut(.defaultAction)
                    .disabled(state.keyDraft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: Helpers

    private func message(icon: String?, title: String, detail: String? = nil,
                         button: (String, () -> Void)? = nil) -> some View {
        VStack(spacing: 8) {
            if let icon {
                Image(systemName: icon).font(.system(size: 22)).foregroundStyle(.secondary)
            } else {
                ProgressView().controlSize(.small)
            }
            Text(title).font(.system(size: 13, weight: .semibold))
            if let detail {
                Text(detail).font(.system(size: 11)).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            if let button {
                Button(button.0, action: button.1).controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }

    private func distanceText(_ m: Double) -> String {
        m < 1000 ? "\(Int((m / 10).rounded() * 10)) m" : String(format: "%.1f km", m / 1000)
    }

    private func openLocationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
    }
}
