import XCTest
@testable import BGCheck

final class ReminderSettingsTests: XCTestCase {

    // MARK: - Public Methods
    func testDecodesLegacyNumericSettings() throws {
        let date = Date(timeIntervalSinceReferenceDate: 1_000)
        let legacySettings = LegacyReminderSettings(
            frequency: ReminderFrequency.biweekly.rawValue,
            isEnabled: true,
            monthDay: 15,
            time: date,
            weekDayIndex: CalendarWeekday.monday.rawValue - 1
        )
        let data = try JSONEncoder().encode(legacySettings)

        let settings = try JSONDecoder().decode(ReminderSettings.self, from: data)

        XCTAssertEqual(settings.frequency, .biweekly)
        XCTAssertEqual(settings.isEnabled, true)
        XCTAssertEqual(settings.monthDay, 15)
        XCTAssertEqual(settings.time, date)
        XCTAssertEqual(settings.weekday, .monday)
    }

    func testEncodesTypedSettingsWithoutLegacyWeekdayIndex() throws {
        let settings = ReminderSettings(
            isEnabled: true,
            frequency: .weekly,
            time: Date(timeIntervalSinceReferenceDate: 1_000),
            weekday: .friday,
            monthDay: 12
        )
        let data = try JSONEncoder().encode(settings)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["frequency"] as? Int, ReminderFrequency.weekly.rawValue)
        XCTAssertEqual(object["weekday"] as? Int, CalendarWeekday.friday.rawValue)
        XCTAssertNil(object["weekDayIndex"])
    }

    func testMonthDayIsLimitedToCalendarRange() {
        let settings = ReminderSettings(
            isEnabled: true,
            frequency: .monthly,
            time: Date(),
            weekday: .sunday,
            monthDay: 40
        )

        XCTAssertEqual(settings.monthDay, 31)
    }
}

private struct LegacyReminderSettings: Codable {

    // MARK: - Public Properties
    let frequency: Int
    let isEnabled: Bool
    let monthDay: Int
    let time: Date
    let weekDayIndex: Int
}
