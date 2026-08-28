import Foundation

extension String {
    enum Localized {

        // MARK: - Constants
        static let appName = NSLocalizedString("app.name", comment: "")
        static let localeIdentifier = NSLocalizedString("locale.identifier", comment: "")

        static let historyVCDateFormat = NSLocalizedString("historyVC.formatter.dateFormat", comment: "")
        static let historyVCMessageStartMonitoring = NSLocalizedString("historyVC.message.startMonitoring", comment: "")

        static let onboardingVCButtonAddNewCase = NSLocalizedString("onboardingVC.button.addNewCase", comment: "")
        static let onboardingVCButtonDelete = NSLocalizedString("onboardingVC.button.delete", comment: "")
        static let onboardingVCButtonDone = NSLocalizedString("onboardingVC.button.done", comment: "")
        static let onboardingVCLabelCaseName = NSLocalizedString("onboardingVC.label.caseName", comment: "")
        static let onboardingVCLabelCaseNumber = NSLocalizedString("onboardingVC.label.case№", comment: "")
        static let onboardingVCLabelCasePin = NSLocalizedString("onboardingVC.label.casePin", comment: "")
        static let onboardingVCLabelCases = NSLocalizedString("onboardingVC.label.Cases", comment: "")
        static let onboardingVCPlaceholderName = NSLocalizedString("onboardingVC.placeholder.enterName", comment: "")
        static let onboardingVCPlaceholderNumber = NSLocalizedString("onboardingVC.placeholder.enterNumber", comment: "")
        static let onboardingVCPlaceholderPin = NSLocalizedString("onboardingVC.placeholder.enterPin", comment: "")

        static let notificationPermissionAlertButtonCancel = NSLocalizedString(
            "notificationPermissionAlert.button.cancel",
            comment: ""
        )
        static let notificationPermissionAlertButtonSettings = NSLocalizedString(
            "notificationPermissionAlert.button.settings",
            comment: ""
        )
        static let notificationPermissionAlertMessage = NSLocalizedString(
            "notificationPermissionAlert.message",
            comment: ""
        )
        static let notificationPermissionAlertTitle = NSLocalizedString(
            "notificationPermissionAlert.title",
            comment: ""
        )

        static let reminderMessage = NSLocalizedString("reminder.message", comment: "")
        static let reminderViewButtonSave = NSLocalizedString("reminderView.button.save", comment: "")
        static let reminderViewLabelEnabled = NSLocalizedString("reminderView.label.enabled", comment: "")
        static let reminderViewLabelSetDayOfMonth = NSLocalizedString("reminderView.label.setDayOfMonth", comment: "")
        static let reminderViewLabelSetDayOfWeek = NSLocalizedString("reminderView.label.setDayOfWeek", comment: "")
        static let reminderViewLabelSetFrequency = NSLocalizedString("reminderView.label.setFrequency", comment: "")
        static let reminderViewLabelSetTime = NSLocalizedString("reminderView.label.setTime", comment: "")
        static let reminderViewFrequencyOptions: [String] = [
            NSLocalizedString("reminderView.segmentedControl.day", comment: ""),
            NSLocalizedString("reminderView.segmentedControl.week", comment: ""),
            NSLocalizedString("reminderView.segmentedControl.2week", comment: ""),
            NSLocalizedString("reminderView.segmentedControl.month", comment: "")
        ]
        static let reminderViewTitle = NSLocalizedString("reminderView.title", comment: "")

        static let webViewVCButtonReload = NSLocalizedString("webViewVC.button.reload", comment: "")
        static let webViewVCLabelCase = NSLocalizedString("webViewVC.label.case", comment: "")
    }
}
