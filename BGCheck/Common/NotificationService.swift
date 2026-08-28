import Foundation
import UserNotifications

final class NotificationService {

    // MARK: - Constants
    private enum Constants {

        static let baseIdentifier = "\(Bundle.main.bundleIdentifier ?? "BGCheck").reminder"
        static let firstFollowUpIdentifier = "\(baseIdentifier).followUp.first"
        static let primaryIdentifier = "\(baseIdentifier).primary"
        static let secondFollowUpIdentifier = "\(baseIdentifier).followUp.second"
    }

    // MARK: - Public Properties
    static let shared = NotificationService()

    // MARK: - Private Properties
    private let legacyNotificationIdentifier = String.Localized.appName.filter { $0 != " " }
    private let notificationCenter = UNUserNotificationCenter.current()

    private var notificationIdentifiers: [String] {
        [
            Constants.primaryIdentifier,
            Constants.firstFollowUpIdentifier,
            Constants.secondFollowUpIdentifier
        ]
    }

    // MARK: - Initializers
    private init() {}

    // MARK: - Public Methods
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func cancelNotifications() {
        let identifiers = notificationIdentifiers + [
            Constants.baseIdentifier,
            legacyNotificationIdentifier
        ]

        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func scheduleNotifications(
        title: String,
        targetTime: Date,
        frequency: ReminderFrequency,
        weekday: CalendarWeekday? = nil,
        monthDay: Int? = nil,
        notes: String? = nil,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        cancelNotifications()

        guard let dates = NotificationScheduleCalculator.notificationDates(
            targetTime: targetTime,
            frequency: frequency,
            weekday: weekday,
            monthDay: monthDay
        ) else {
            complete(completion, success: false, error: NotificationServiceError.invalidDate)
            return
        }

        let body = notes.flatMap { $0.isEmpty ? nil : $0 } ?? .Localized.reminderMessage
        let requests = zip(notificationIdentifiers, dates).map {
            notificationRequest(identifier: $0.0, title: title, body: body, date: $0.1)
        }

        authorizeNotifications { error in
            if let error {
                self.complete(completion, success: false, error: error)
                return
            }

            self.addNotificationRequests(requests, completion: completion)
        }
    }

    func setNotification(with content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(
            identifier: Constants.baseIdentifier,
            content: content,
            trigger: trigger
        )

        authorizeNotifications { error in
            guard error == nil else { return }

            self.notificationCenter.add(request)
        }
    }

    func synchronizeNotifications(completion: @escaping (Bool, Error?) -> Void = { _, _ in }) {
        guard let settings = ReminderSettings.load(), settings.isEnabled else {
            cancelNotifications()
            complete(completion, success: true, error: nil)
            return
        }

        scheduleNotifications(
            title: .Localized.appName,
            targetTime: settings.time,
            frequency: settings.frequency,
            weekday: settings.weekday,
            monthDay: settings.monthDay,
            notes: .Localized.reminderMessage,
            completion: completion
        )
    }

    // MARK: - Private Methods
    private func addNotificationRequests(
        _ requests: [UNNotificationRequest],
        at index: Int = 0,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard index < requests.count else {
            complete(completion, success: true, error: nil)
            return
        }

        notificationCenter.add(requests[index]) { error in
            if let error {
                self.cancelNotifications()
                self.complete(completion, success: false, error: error)
                return
            }

            self.addNotificationRequests(requests, at: index + 1, completion: completion)
        }
    }

    private func authorizeNotifications(completion: @escaping (Error?) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .ephemeral, .provisional:
                completion(nil)
            case .denied:
                completion(NotificationServiceError.authorizationDenied)
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if let error {
                        completion(error)
                    } else {
                        completion(granted ? nil : NotificationServiceError.authorizationDenied)
                    }
                }
            @unknown default:
                completion(NotificationServiceError.unknownAuthorizationStatus)
            }
        }
    }

    private func complete(
        _ completion: @escaping (Bool, Error?) -> Void,
        success: Bool,
        error: Error?
    ) {
        DispatchQueue.main.async {
            completion(success, error)
        }
    }

    private func notificationRequest(
        identifier: String,
        title: String,
        body: String,
        date: Date
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.body = body
        content.sound = .default
        content.title = title

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.calendar = calendar
        components.timeZone = calendar.timeZone

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
}

enum NotificationServiceError: LocalizedError, Equatable {

    case authorizationDenied
    case invalidDate
    case unknownAuthorizationStatus

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Notification permission was denied."
        case .invalidDate:
            return "Unable to calculate the notification date."
        case .unknownAuthorizationStatus:
            return "Unknown notification authorization status."
        }
    }
}
