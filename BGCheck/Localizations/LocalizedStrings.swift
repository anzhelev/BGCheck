import Foundation

extension String {
    enum Localized {
        static let appName = NSLocalizedString("app.name", comment: "")
        static let localeIdentifier = NSLocalizedString("locale.identifier", comment: "")
        
        static let historyVCDateFormat = NSLocalizedString("historyVC.formatter.dateFormat", comment: "")
        static let historyVCMessageStartMonitoring = NSLocalizedString("historyVC.message.startMonitoring", comment: "")
        
        static let onboardingVCButtonAddNewCase = NSLocalizedString("onboardingVC.button.addNewCase", comment: "")
        static let onboardingVCButtonDelete = NSLocalizedString("onboardingVC.button.delete", comment: "")
        static let onboardingVCButtonDone = NSLocalizedString("onboardingVC.button.done", comment: "")

        static let onboardingVCLabelCases = NSLocalizedString("onboardingVC.label.Cases", comment: "")
        static let onboardingVCLabelCaseName = NSLocalizedString("onboardingVC.label.caseName", comment: "")
        static let onboardingVCLabelCasePin = NSLocalizedString("onboardingVC.label.casePin", comment: "")
        static let onboardingVCLabelCaseNumber = NSLocalizedString("onboardingVC.label.case№", comment: "")
        static let onboardingVCPlaceholderName: String = "Enter name"
        static let onboardingVCPlaceholderNumber: String = "Enter number"
        static let onboardingVCPlaceholderPin: String = "Enter pin"
        
        static let reminderMessage = NSLocalizedString("reminder.message", comment: "")
        
        static let reminderViewButtonSave = NSLocalizedString("reminderView.button.save", comment: "")
        static let reminderViewLabelEnabled = NSLocalizedString("reminderView.label.enabled", comment: "")
        static let reminderViewLabelSetDay = NSLocalizedString("reminderView.label.setDay", comment: "")
        static let reminderViewLabelSetFrequency = NSLocalizedString("reminderView.label.setFrequency", comment: "")
        static let reminderViewLabelSetTime = NSLocalizedString("reminderView.label.setTime", comment: "")
        static let reminderViewFrequencyOptions: [String] = [
            NSLocalizedString("reminderView.segmentedControl.day", comment: ""),
            NSLocalizedString("reminderView.segmentedControl.week", comment: ""),
            NSLocalizedString("reminderView.segmentedControl.2week", comment: ""),
            NSLocalizedString("reminderView.segmentedControl.month", comment: "")
        ]
        static let reminderViewTitle = NSLocalizedString("reminderView.title", comment: "")
        
        static let webViewControllerButtonReload = NSLocalizedString("webViewController.button.reload", comment: "")
    }
}
