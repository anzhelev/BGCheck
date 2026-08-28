import Foundation

enum ReminderFrequency: Int, Codable, CaseIterable {

    case daily = 0
    case weekly = 1
    case biweekly = 2
    case monthly = 3
}
