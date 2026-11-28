import SwiftUI

/// How departure times are shown (⚙︎ → Time Format).
enum TimeFormat: String, CaseIterable {
    /// Countdown: m:ss in the last 4 minutes (second-accurate live data only), "N min" up to an
    /// hour, the clock time after that.
    case automatic
    /// Always whole minutes remaining: "now", "7 min", "75 min".
    case minutes
    /// Always the departure time: "14:32".
    case clock

    static let key = "timeFormat"

    var title: String {
        switch self {
        case .automatic: return "Automatic"
        case .minutes: return "Minutes Remaining"
        case .clock: return "Departure Time"
        }
    }

    private static let hhmm: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = TimeZone(identifier: "Europe/Prague")
        return f
    }()

    static func clockString(_ date: Date) -> String { hhmm.string(from: date) }

    /// The time label for a departure, and whether it is leaving now (drawn highlighted).
    /// `secondAccurate`: live data with real seconds (Golemio), the only case that counts down m:ss.
    func label(expected: Date, now: Date, secondAccurate: Bool) -> (text: String, isNow: Bool) {
        let secs = Int(expected.timeIntervalSince(now).rounded(.down))
        let mins = secs / 60
        switch self {
        case .clock:
            return (Self.clockString(expected), mins < 1)
        case .minutes:
            return mins < 1 ? ("now", true) : ("\(mins) min", false)
        case .automatic:
            let showSeconds = secondAccurate && secs < 240
            if showSeconds ? secs <= 0 : mins < 1 { return ("now", true) }
            if showSeconds { return (String(format: "%d:%02d", mins, secs % 60), false) }
            if mins < 60 { return ("\(mins) min", false) }
            return (Self.clockString(expected), false)
        }
    }
}

/// The dark "stop sign" panel with departure rows.
struct DeparturesView: View {
    let group: StopGroup
    let sections: [ModeSection]
    let hasData: Bool
    let live: AppState.LiveState
    let ledStyle: Bool
    var timeFormat: TimeFormat = .automatic
    var onToggle: (Int) -> Void = { _ in }
    var isAlertSet: (Departure) -> Bool = { _ in false }
    var onAlert: (Departure) -> Void = { _ in }
    var isFavourite: (String) -> Bool = { _ in false }
    var onFavourite: (String) -> Void = { _ in }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            VStack(alignment: .leading, spacing: 0) {
                if sections.isEmpty {
                    placeholder
                } else {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { si, section in
                        SectionHeader(title: section.isFavourites ? "Your lines" : section.mode.title,
                                      symbol: section.isFavourites ? "star.fill" : section.mode.symbol,
                                      ledStyle: ledStyle,
                                      expandable: section.hasMore || section.expanded,
                                      expanded: section.expanded) { onToggle(section.id) }
                            .padding(.top, si == 0 ? 2 : 8)
                        ForEach(Array(section.departures.enumerated()), id: \.element.id) { i, d in
                            DepartureRow(departure: d, colors: group.badgeColors(for: d),
                                         now: ctx.date, ledStyle: ledStyle, alertSet: isAlertSet(d),
                                         timeFormat: timeFormat)
                                // Leaves before you can walk there: dimmed.
                                .opacity(group.isCatchable(d, now: ctx.date) || d.isCancelled ? 1 : 0.4)
                                .contentShape(Rectangle())
                                .onTapGesture { if !d.isCancelled { onAlert(d) } }
                                .contextMenu {
                                    if !d.isCancelled {
                                        Button(isAlertSet(d) ? "Cancel Leave-Now Alert" : "Leave-Now Alert") { onAlert(d) }
                                    }
                                    Button(isFavourite(d.line) ? "Remove \(d.line) from Your Lines" : "Add \(d.line) to Your Lines") {
                                        onFavourite(d.line)
                                    }
                                }
                            if i < section.departures.count - 1 {
                                Rectangle().fill(.white.opacity(0.07)).frame(height: 1).padding(.leading, 62)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.07, green: 0.08, blue: 0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.white.opacity(0.06))
            )
        }
    }

    @ViewBuilder private var placeholder: some View {
        HStack(spacing: 8) {
            switch hasData ? .ok : live {
            case .loading:
                ProgressView().controlSize(.small).tint(.white)
                Text("Loading departures…")
            case .unavailable:
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                Text("Live data unavailable")
            case .ok:
                Image(systemName: "moon.zzz")
                Text("No departures soon")
            }
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.white.opacity(0.6))
        .frame(maxWidth: .infinity, minHeight: 64)
    }
}

/// "METRO" / "TRAM" / "BUS" label between groups, like the headings on a station board.
struct SectionHeader: View {
    let title: String
    let symbol: String
    let ledStyle: Bool
    var expandable = false
    var expanded = false
    var action: () -> Void = {}

    private var tint: Color {
        ledStyle ? Color(red: 1.0, green: 0.69, blue: 0.0).opacity(0.6) : .white.opacity(0.45)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 9, weight: .semibold))
                Text(title.uppercased())
                    .font(.system(size: 9.5, weight: .semibold))
                    .tracking(0.8)
                Spacer()
                if expandable {
                    Text(expanded ? "Less" : "More")
                        .font(.system(size: 9.5, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!expandable)
        .help(expandable ? (expanded ? "Show fewer" : "Show later departures") : "")
    }
}

struct DepartureRow: View {
    let departure: Departure
    let colors: (bg: Color, fg: Color)
    let now: Date
    let ledStyle: Bool
    var alertSet = false
    var timeFormat: TimeFormat = .automatic

    private var amber: Color { Color(red: 1.0, green: 0.69, blue: 0.0) }
    private var mainText: Color { ledStyle ? amber : .white }

    var body: some View {
        HStack(spacing: 10) {
            Text(departure.line)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(colors.fg)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 5)
                .frame(minWidth: 34, minHeight: 22)
                .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(colors.bg))
                .frame(width: 40, alignment: .leading)

            Text(departure.destination)
                .font(ledStyle ? .system(size: 13, weight: .medium, design: .monospaced)
                               : .system(size: 13, weight: .medium))
                .foregroundStyle(departure.isCancelled ? .white.opacity(0.4) : mainText)
                .strikethrough(departure.isCancelled, color: .red.opacity(0.8))
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 6)

            VStack(alignment: .trailing, spacing: 1) {
                timeLabel
                if !departure.isCancelled && departure.delayMinutes >= 2 {
                    HStack(spacing: 3) {
                        Text(TimeFormat.clockString(departure.planned))
                            .strikethrough()
                            .foregroundStyle(.white.opacity(0.4))
                        // The main label already is the expected time in Departure Time format.
                        if timeFormat != .clock {
                            Text(TimeFormat.clockString(departure.expected))
                                .foregroundStyle(.orange)
                        }
                    }
                    .font(.system(size: 10, weight: .medium).monospacedDigit())
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .help((departure.isLive ? "Live" : "Planned (no live data for this trip)")
              + (alertSet ? " · Leave-now alert set (click to cancel)" : " · Click for a leave-now alert, right-click for more"))
    }

    @ViewBuilder private var timeLabel: some View {
        if departure.isCancelled {
            Text("Cancelled")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.red)
        } else {
            // Only live predictions with real seconds count down m:ss (Automatic format);
            // planned and per-minute times don't pretend to be precise.
            let label = timeFormat.label(expected: departure.expected, now: now,
                                         secondAccurate: departure.isLive && departure.precise)
            let isNow = label.isNow
            HStack(spacing: 5) {
                if alertSet {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 1.0, green: 0.69, blue: 0.0))
                }
                if departure.isLive {
                    Circle().fill(Color.green).frame(width: 5, height: 5)
                }
                Text(label.text)
                .font(ledStyle ? .system(size: 14, weight: .semibold, design: .monospaced)
                               : .system(size: 14, weight: .semibold).monospacedDigit())
                .foregroundStyle(isNow ? (ledStyle ? amber : .green) : mainText)
            }
        }
    }
}
