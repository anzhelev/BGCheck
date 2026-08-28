import Foundation

struct NotificationScheduleCalculator {

    // MARK: - Public Methods
    static func notificationDates(
        now: Date = Date(),
        targetTime: Date,
        frequency: ReminderFrequency,
        weekday: CalendarWeekday?,
        monthDay: Int?,
        calendar: Calendar = .current
    ) -> [Date]? {
        guard let firstDate = firstReminderDate(
            now: now,
            targetTime: targetTime,
            frequency: frequency,
            weekday: weekday,
            monthDay: monthDay,
            calendar: calendar
        ) else {
            return nil
        }

        guard
            let secondDate = calendar.date(byAdding: .day, value: 1, to: firstDate),
            let thirdDate = calendar.date(byAdding: .day, value: 2, to: firstDate)
        else {
            return nil
        }

        return [firstDate, secondDate, thirdDate]
    }

    // MARK: - Private Methods
    private static func firstReminderDate(
        now: Date,
        targetTime: Date,
        frequency: ReminderFrequency,
        weekday: CalendarWeekday?,
        monthDay: Int?,
        calendar: Calendar
    ) -> Date? {
        let timeComponents = calendar.dateComponents([.hour, .minute], from: targetTime)

        guard let hour = timeComponents.hour, let minute = timeComponents.minute else {
            return nil
        }

        switch frequency {
        case .daily:
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
                return nil
            }

            return calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: tomorrow,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .forward
            )
        case .weekly:
            return nextWeekdayDate(
                after: now,
                weekday: weekday,
                hour: hour,
                minute: minute,
                calendar: calendar
            )
        case .biweekly:
            guard let nextWeekdayDate = nextWeekdayDate(
                after: now,
                weekday: weekday,
                hour: hour,
                minute: minute,
                calendar: calendar
            ) else {
                return nil
            }

            return calendar.date(byAdding: .day, value: 7, to: nextWeekdayDate)
        case .monthly:
            return nextMonthlyDate(
                after: now,
                monthDay: monthDay,
                hour: hour,
                minute: minute,
                calendar: calendar
            )
        }
    }

    private static func nextMonthlyDate(
        after date: Date,
        monthDay: Int?,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date? {
        guard let monthDay, (1...31).contains(monthDay) else {
            return nil
        }

        var currentMonthComponents = calendar.dateComponents([.year, .month], from: date)
        currentMonthComponents.day = 1

        guard let currentMonthStart = calendar.date(from: currentMonthComponents) else {
            return nil
        }

        for monthOffset in 0...24 {
            guard
                let monthStart = calendar.date(byAdding: .month, value: monthOffset, to: currentMonthStart),
                let dayRange = calendar.range(of: .day, in: .month, for: monthStart),
                let dayStart = calendar.date(
                    byAdding: .day,
                    value: min(monthDay, dayRange.count) - 1,
                    to: monthStart
                ),
                let candidate = calendar.date(
                    bySettingHour: hour,
                    minute: minute,
                    second: 0,
                    of: dayStart,
                    matchingPolicy: .nextTime,
                    repeatedTimePolicy: .first,
                    direction: .forward
                )
            else {
                continue
            }

            if candidate > date {
                return candidate
            }
        }

        return nil
    }

    private static func nextWeekdayDate(
        after date: Date,
        weekday: CalendarWeekday?,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date? {
        guard let weekday else {
            return nil
        }

        var components = DateComponents()
        components.weekday = weekday.rawValue
        components.hour = hour
        components.minute = minute
        components.second = 0

        return calendar.nextDate(
            after: date,
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
    }
}
