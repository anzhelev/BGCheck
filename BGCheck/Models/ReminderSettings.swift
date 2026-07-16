import Foundation

struct ReminderSettings: Codable {
    let isEnabled: Bool
    let frequency: Int
    let time: Date
    let weekDayIndex: Int
    let monthDay: Int
}
