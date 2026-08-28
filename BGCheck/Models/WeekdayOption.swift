import Foundation

struct WeekdayOption {

    // MARK: - Public Properties
    let title: String
    let weekday: CalendarWeekday

    // MARK: - Public Methods
    static func localized(for locale: Locale) -> [WeekdayOption] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale

        let symbols = calendar.standaloneWeekdaySymbols

        guard !symbols.isEmpty else { return [] }

        let firstWeekdayIndex = calendar.firstWeekday - 1

        return symbols.indices.compactMap { offset in
            let symbolIndex = (firstWeekdayIndex + offset) % symbols.count

            guard let weekday = CalendarWeekday(rawValue: symbolIndex + 1) else {
                return nil
            }

            return WeekdayOption(title: symbols[symbolIndex], weekday: weekday)
        }
    }
}
