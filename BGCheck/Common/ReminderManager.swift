import UIKit
import EventKit

enum ReminderFrequency: Int {
    case daily = 0
    case weekly = 1
    case biweekly = 2
    case monthly = 3
}

final class ReminderManager {
    
    // MARK: - Constants
    private enum Strings: String {
        case nsErrorDomain = "ReminderManager"
        case requestAccessError = "@@@ Request access error:"
        case accessDenied = "@@@ Reminder access denied or restricted"
        case dueDateError = "Failed to calculate next due date"
        case predicateError = "Failed to create NSPredicate"
        case fetchError = "Failed to fetch reminders"
        case nothingToDelete = "@@@ No incomplete reminders with title"
        case weekDayMissing = "Weekday required for weekly recurrence"
        case monthDayMissing = "Monthday required for monthly recurrence"
        case defaultCalendarMissing = "Default reminder calendar not found"
        case remindersRemoved = "@@@ Removed %d reminders with title '%@'"
        case removeError = "@@@ Remove error:"
        case commitError = "@@@ Commit error:"
        case reminderCreated = "@@@ Reminder created, first fire:"
        case saveError = "@@@ Save error:"
    }
    
    // MARK: - Public Properties
    static let shared = ReminderManager()
    
    // MARK: - Private Properties
    private let calendar = Calendar.current
    private let eventStore = EKEventStore()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func createReminder(
        title: String,
        targetTime: Date,
        frequency: ReminderFrequency,
        weekday: Int? = nil,
        monthDay: Int? = nil,
        notes: String? = nil,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        removeReminders(withTitle: title) { [weak self] success, error in
            guard success else {
                completion(false, error)
                return
            }
            guard let dueDate = self?.computeNextDueDate(
                from: targetTime,
                frequency: frequency,
                weekday: weekday,
                monthDay: monthDay
            ) else {
                let error = NSError(domain: Strings.nsErrorDomain.rawValue, code: 5,
                                    userInfo: [NSLocalizedDescriptionKey: Strings.dueDateError.rawValue])
                completion(false, error)
                return
            }
            self?.saveReminder(
                title: title,
                dueDate: dueDate,
                frequency: frequency,
                weekday: weekday,
                monthDay: monthDay,
                notes: notes,
                completion: completion
            )
        }
    }
    
    func removeReminders(withTitle title: String, completion: @escaping (Bool, Error?) -> Void) {
        requestAccess { [weak self] granted in
            guard granted else {
                completion(false, nil)
                return
            }
            
            guard let predicate = self?.eventStore.predicateForReminders(in: nil) else {
                let error = NSError(domain: Strings.nsErrorDomain.rawValue, code: 6,
                                    userInfo: [NSLocalizedDescriptionKey: Strings.predicateError.rawValue])
                completion(false, error)
                return
            }
            
            self?.eventStore.fetchReminders(matching: predicate) { reminders in
                guard let reminders = reminders else {
                    let error = NSError(domain: Strings.nsErrorDomain.rawValue, code: 7,
                                        userInfo: [NSLocalizedDescriptionKey: Strings.fetchError.rawValue])
                    completion(false, error)
                    return
                }
                
                let remindersToRemove = reminders.filter {
                    !$0.isCompleted && $0.title == title
                }
                
                if remindersToRemove.isEmpty {
                    print(Strings.nothingToDelete.rawValue, title)
                    completion(true, nil)
                    return
                }
                
                remindersToRemove.forEach { reminder in
                    do {
                        try self?.eventStore.remove(reminder, commit: false)
                    } catch {
                        print(Strings.removeError.rawValue, error.localizedDescription)
                    }
                }
                
                do {
                    try self?.eventStore.commit()
                    print(String(format: Strings.remindersRemoved.rawValue, remindersToRemove.count, title))
                    completion(true, nil)
                } catch {
                    print(Strings.commitError.rawValue, error.localizedDescription)
                    completion(false, error)
                }
            }
        }
    }
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized, .fullAccess:
            completion(true)
        case .notDetermined:
            eventStore.requestAccess(to: .reminder) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print(Strings.requestAccessError.rawValue, error.localizedDescription)
                    }
                    completion(granted)
                }
            }
        case .denied, .restricted, .writeOnly:
            print(Strings.accessDenied.rawValue)
            completion(false)
        default:
            completion(false)
        }
    }
    
    // MARK: - Private Methods
    private func computeNextDueDate(
        from targetTime: Date,
        frequency: ReminderFrequency,
        weekday: Int?,
        monthDay: Int?
    ) -> Date? {
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: targetTime)
        var matchingComponents = DateComponents()
        matchingComponents.hour = components.hour
        matchingComponents.minute = components.minute
        matchingComponents.second = 0
        
        switch frequency {
        case .daily:
            break
        case .weekly, .biweekly:
            guard let wd = weekday else { return nil }
            matchingComponents.weekday = wd
        case .monthly:
            guard let md = monthDay else { return nil }
            matchingComponents.day = md
        }
        
        guard let nextDate = calendar.nextDate(
            after: now,
            matching: matchingComponents,
            matchingPolicy: .nextTime,
            direction: .forward
        ) else {
            return nil
        }
        return nextDate
    }
    
    private static func ekWeekday(from intValue: Int) -> EKWeekday {
        switch intValue {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .sunday
        }
    }
    
    private func saveReminder(
        title: String,
        dueDate: Date,
        frequency: ReminderFrequency,
        weekday: Int?,
        monthDay: Int?,
        notes: String?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        
        let dueComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.dueDateComponents = dueComponents
        
        let alarm = EKAlarm(absoluteDate: dueDate)
        reminder.addAlarm(alarm)
        
        var recurrenceRule: EKRecurrenceRule?
        
        switch frequency {
        case .daily:
            recurrenceRule = EKRecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: nil
            )
            
        case .weekly:
            guard let wd = weekday else {
                let error = NSError(domain: Strings.nsErrorDomain.rawValue, code: 2,
                                    userInfo: [NSLocalizedDescriptionKey: Strings.weekDayMissing.rawValue])
                completion(false, error)
                return
            }
            let ekWeekday = Self.ekWeekday(from: wd)
            let dayOfWeek = EKRecurrenceDayOfWeek(ekWeekday)
            recurrenceRule = EKRecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: [dayOfWeek],
                daysOfTheMonth: nil,
                monthsOfTheYear: nil,
                weeksOfTheYear: nil,
                daysOfTheYear: nil,
                setPositions: nil,
                end: nil
            )
            
        case .biweekly:
            guard let wd = weekday else {
                let error = NSError(domain: Strings.nsErrorDomain.rawValue, code: 3,
                                    userInfo: [NSLocalizedDescriptionKey: Strings.weekDayMissing.rawValue])
                completion(false, error)
                return
            }
            let ekWeekday = Self.ekWeekday(from: wd)
            let dayOfWeek = EKRecurrenceDayOfWeek(ekWeekday)
            recurrenceRule = EKRecurrenceRule(
                recurrenceWith: .weekly,
                interval: 2,
                daysOfTheWeek: [dayOfWeek],
                daysOfTheMonth: nil,
                monthsOfTheYear: nil,
                weeksOfTheYear: nil,
                daysOfTheYear: nil,
                setPositions: nil,
                end: nil
            )
            
        case .monthly:
            guard let md = monthDay else {
                let error = NSError(domain: Strings.nsErrorDomain.rawValue, code: 4,
                                    userInfo: [NSLocalizedDescriptionKey: Strings.monthDayMissing.rawValue])
                completion(false, error)
                return
            }
            recurrenceRule = EKRecurrenceRule(
                recurrenceWith: .monthly,
                interval: 1,
                daysOfTheWeek: nil,
                daysOfTheMonth: [md as NSNumber],
                monthsOfTheYear: nil,
                weeksOfTheYear: nil,
                daysOfTheYear: nil,
                setPositions: nil,
                end: nil
            )
        }
        
        if let rule = recurrenceRule {
            reminder.recurrenceRules = [rule]
        }
        
        guard let calendar = eventStore.defaultCalendarForNewReminders() else {
            let error = NSError(domain: Strings.nsErrorDomain.rawValue, code: 1,
                                userInfo: [NSLocalizedDescriptionKey: Strings.defaultCalendarMissing.rawValue])
            completion(false, error)
            return
        }
        reminder.calendar = calendar
        
        do {
            try eventStore.save(reminder, commit: true)
            print(Strings.reminderCreated.rawValue, dueDate)
            completion(true, nil)
        } catch {
            print(Strings.saveError.rawValue, error.localizedDescription)
            completion(false, error)
        }
    }
}
