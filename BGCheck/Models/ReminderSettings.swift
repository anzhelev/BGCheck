import Foundation

struct ReminderSettings {

    // MARK: - Constants
    static let storageKey = "notificationSettings"

    // MARK: - Public Properties
    let frequency: ReminderFrequency
    let isEnabled: Bool
    let monthDay: Int
    let time: Date
    let weekday: CalendarWeekday

    // MARK: - Initializers
    init(
        isEnabled: Bool,
        frequency: ReminderFrequency,
        time: Date,
        weekday: CalendarWeekday,
        monthDay: Int
    ) {
        self.frequency = frequency
        self.isEnabled = isEnabled
        self.monthDay = min(max(monthDay, 1), 31)
        self.time = time
        self.weekday = weekday
    }

    // MARK: - Public Methods
    static func load() -> ReminderSettings? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }

        return try? JSONDecoder().decode(ReminderSettings.self, from: data)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }

        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

}

// MARK: - Codable
extension ReminderSettings: Codable {

    private enum CodingKeys: String, CodingKey {

        case frequency
        case isEnabled
        case monthDay
        case time
        case weekday
        case weekDayIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let frequency = try container.decode(ReminderFrequency.self, forKey: .frequency)
        let isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        let monthDay = try container.decode(Int.self, forKey: .monthDay)
        let time = try container.decode(Date.self, forKey: .time)

        let weekday: CalendarWeekday

        if let storedWeekday = try container.decodeIfPresent(CalendarWeekday.self, forKey: .weekday) {
            weekday = storedWeekday
        } else {
            let legacyIndex = try container.decodeIfPresent(Int.self, forKey: .weekDayIndex) ?? 0
            weekday = CalendarWeekday(rawValue: legacyIndex + 1) ?? .sunday
        }

        self.init(
            isEnabled: isEnabled,
            frequency: frequency,
            time: time,
            weekday: weekday,
            monthDay: monthDay
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(monthDay, forKey: .monthDay)
        try container.encode(time, forKey: .time)
        try container.encode(weekday, forKey: .weekday)
    }
}
