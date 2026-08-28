import XCTest
@testable import BGCheck

final class NotificationScheduleCalculatorTests: XCTestCase {

    // MARK: - Public Methods
    func testBiweeklyStartsOnSelectedWeekdayInSecondWeek() {
        let calendar = makeCalendar()
        let now = makeDate(2026, 8, 28, 15, 0, calendar: calendar)
        let targetTime = makeDate(2026, 8, 28, 10, 15, calendar: calendar)

        let dates = NotificationScheduleCalculator.notificationDates(
            now: now,
            targetTime: targetTime,
            frequency: .biweekly,
            weekday: .monday,
            monthDay: nil,
            calendar: calendar
        )

        XCTAssertEqual(
            dates,
            Optional([
                makeDate(2026, 9, 7, 10, 15, calendar: calendar),
                makeDate(2026, 9, 8, 10, 15, calendar: calendar),
                makeDate(2026, 9, 9, 10, 15, calendar: calendar)
            ])
        )
    }

    func testDailyCreatesThreeConsecutiveDatesStartingTomorrow() {
        let calendar = makeCalendar()
        let now = makeDate(2026, 8, 28, 15, 0, calendar: calendar)
        let targetTime = makeDate(2026, 8, 28, 9, 30, calendar: calendar)

        let dates = NotificationScheduleCalculator.notificationDates(
            now: now,
            targetTime: targetTime,
            frequency: .daily,
            weekday: nil,
            monthDay: nil,
            calendar: calendar
        )

        XCTAssertEqual(
            dates,
            Optional([
                makeDate(2026, 8, 29, 9, 30, calendar: calendar),
                makeDate(2026, 8, 30, 9, 30, calendar: calendar),
                makeDate(2026, 8, 31, 9, 30, calendar: calendar)
            ])
        )
    }

    func testMonthlyMovesToNextMonthWhenAdjustedDateHasPassed() {
        let calendar = makeCalendar()
        let now = makeDate(2027, 2, 28, 10, 0, calendar: calendar)
        let targetTime = makeDate(2027, 2, 1, 9, 0, calendar: calendar)

        let dates = NotificationScheduleCalculator.notificationDates(
            now: now,
            targetTime: targetTime,
            frequency: .monthly,
            weekday: nil,
            monthDay: 31,
            calendar: calendar
        )

        XCTAssertEqual(
            dates,
            Optional([
                makeDate(2027, 3, 31, 9, 0, calendar: calendar),
                makeDate(2027, 4, 1, 9, 0, calendar: calendar),
                makeDate(2027, 4, 2, 9, 0, calendar: calendar)
            ])
        )
    }

    func testMonthlyUsesLastDayOfLeapFebruary() {
        let calendar = makeCalendar()
        let now = makeDate(2028, 2, 10, 12, 0, calendar: calendar)
        let targetTime = makeDate(2028, 2, 1, 9, 0, calendar: calendar)

        let dates = NotificationScheduleCalculator.notificationDates(
            now: now,
            targetTime: targetTime,
            frequency: .monthly,
            weekday: nil,
            monthDay: 31,
            calendar: calendar
        )

        XCTAssertEqual(dates?.first, makeDate(2028, 2, 29, 9, 0, calendar: calendar))
    }

    func testMonthlyUsesLastDayWhenSelectedDayIsMissing() {
        let calendar = makeCalendar()
        let now = makeDate(2027, 2, 10, 12, 0, calendar: calendar)
        let targetTime = makeDate(2027, 2, 1, 9, 0, calendar: calendar)

        let dates = NotificationScheduleCalculator.notificationDates(
            now: now,
            targetTime: targetTime,
            frequency: .monthly,
            weekday: nil,
            monthDay: 31,
            calendar: calendar
        )

        XCTAssertEqual(dates?.first, makeDate(2027, 2, 28, 9, 0, calendar: calendar))
    }

    func testWeeklyUsesNextSelectedWeekday() {
        let calendar = makeCalendar()
        let now = makeDate(2026, 8, 28, 15, 0, calendar: calendar)
        let targetTime = makeDate(2026, 8, 28, 10, 15, calendar: calendar)

        let dates = NotificationScheduleCalculator.notificationDates(
            now: now,
            targetTime: targetTime,
            frequency: .weekly,
            weekday: .monday,
            monthDay: nil,
            calendar: calendar
        )

        XCTAssertEqual(dates?.first, makeDate(2026, 8, 31, 10, 15, calendar: calendar))
    }

    // MARK: - Private Methods
    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func makeDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ hour: Int,
        _ minute: Int,
        calendar: Calendar
    ) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.day = day
        components.hour = hour
        components.minute = minute
        components.month = month
        components.timeZone = calendar.timeZone
        components.year = year

        return calendar.date(from: components)!
    }
}
