import XCTest
@testable import BGCheck

final class WeekdayOptionTests: XCTestCase {

    // MARK: - Private Properties
    private var mondayFirstWeekdays: [CalendarWeekday] {
        [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday,
            .sunday
        ]
    }

    // MARK: - Public Methods
    func testBulgarianWeekStartsOnMonday() {
        let weekdays = WeekdayOption.localized(for: Locale(identifier: "bg_BG"))

        XCTAssertEqual(weekdays.map(\.weekday), mondayFirstWeekdays)
    }

    func testEnglishUSWeekStartsOnSunday() {
        let weekdays = WeekdayOption.localized(for: Locale(identifier: "en_US"))

        XCTAssertEqual(weekdays.map(\.weekday), CalendarWeekday.allCases)
    }

    func testLocalizedWeekdayTitlesAreNotEmpty() {
        let locales = ["bg_BG", "en_US", "ru_RU"].map { Locale(identifier: $0) }

        locales.forEach { locale in
            let weekdays = WeekdayOption.localized(for: locale)

            XCTAssertEqual(weekdays.count, CalendarWeekday.allCases.count)
            XCTAssertTrue(weekdays.allSatisfy { !$0.title.isEmpty })
        }
    }

    func testRussianWeekStartsOnMonday() {
        let weekdays = WeekdayOption.localized(for: Locale(identifier: "ru_RU"))

        XCTAssertEqual(weekdays.map(\.weekday), mondayFirstWeekdays)
    }
}
