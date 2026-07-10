import UIKit
import Foundation

enum UIConstants {
    static let buttonsCornerRadius: CGFloat = 16
    static let tableCellCornerRadius: CGFloat = 12
    static let reminderViewCornerRadius: CGFloat = 16
    static let buttonsBorderWidthPrimary: CGFloat = 2
    static let buttonsBorderWidthSecondary: CGFloat = 1
    static let titleFontPrimary: UIFont = .systemFont(ofSize: 17, weight: .semibold)
//    static let titleFontSecondary: UIFont = .systemFont(ofSize: 15, weight: .semibold)
    static let buttonsLabelFontPrimary: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let buttonsLabelFontSecondary: UIFont = .systemFont(ofSize: 15, weight: .semibold)
    static let buttonsLabelFontTertiary: UIFont = .systemFont(ofSize: 14, weight: .regular)
    static let buttonsHeight: CGFloat = 48
    static let buttonsHeightLarge: CGFloat = 52
    static let buttonsWidthPrimary: CGFloat = 240
    static let buttonsWidthSecondary: CGFloat = 120
    static let buttonsWidthTertiary: CGFloat = 60
    static let buttonsSpacing: CGFloat = 10
    static let buttonsSpacingSmall: CGFloat = 4
    static let textLabelSpacing: CGFloat = 8
    static let maxTextleLenght: Int = 20

    static let horizontalUIOffset: CGFloat = 20
    static let horizontalUIOffsetSecondary: CGFloat = 10
    static let topUIOffset: CGFloat = 10
    static let bottomUIOffset: CGFloat = 4
    static let verticalUIOffsetPrimary: CGFloat = 10
    static let verticalUIOffsetSecondary: CGFloat = 30
    static let verticalUIOffsetTertiary: CGFloat = 16
    static let verticalStackViewSpacing: CGFloat = 8
    
    static let coatOfArmsImageDimension: CGFloat = 180
    
    static let casesTableCellHeight: CGFloat = 85
    static let tableSeparatorInset: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
    static let cellsTextFieldsMaxTextLength: Int = 22
    

    
    static let addCasesLabelText: String = "Cases (up to 5):"
    static let addCasesButtonTitle: String = "Add new case"
    static let remindButtonImageNamePrimary: String = "bell.slash"
    static let remindButtonImageNameSecondary: String = "bell.and.waves.left.and.right.fill"
    static let reminderViewTitle: String = "Reminders"
    static let reminderViewLabelEnabled: String = "Enabled:"
    static let reminderViewLabelTime: String = "Remind me at:"
    static let reminderViewLabelDayOfWeek: String = "Day of week:"
    static let reminderViewLabelDayOfMonth: String = "Day of month:"
    static let reminderViewCloseButtonTitle: String = "xmark"
    static let menuButtonImageNamePrimary: String = "gearshape.fill" // line.horizontal.3 gearshape.fill
    static let menuButtonImageNameSecondary: String = "xmark.circle.fill"
    static let settingsButtonImageName: String = "gearshape.fill"
        
    static let doneButtonTitle: String = "Done"
    static let deleteButtonTitle: String = "Delete"
    static let reloadButtonTitle: String = "Reload page"
    static let caseNameLabelText: String = "Name:"
    static let caseNumberLabelText: String = "№:"
    static let pinLabelText: String = "Pin:"
    static let caseInitialStatusLabelText: String = "Start monitoring"
    static let frequencyOptions: [String] = ["Day", "Week", "2 Weeks", "Month"]
    static let weekDays: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
}

enum JavaScriptConstants {
    static let numberInputJavaScript = "document.getElementById('reqNun').value ="
    static let pinInputJavaScript = "document.getElementById('pin').value ="
    static let clickOnButtonJavaScript = "document.getElementsByTagName('button')[0].click();"
    static let checkMessagesScript = """
        function checkForErrors() {
            var errorItems = document.querySelectorAll('div.validation-summary-errors.text-danger ul li');
            var messages = Array.from(errorItems).map(item => item.textContent.trim());
        
            const searchText = "Резервиране на дата за получаване на удостоверение";
            const pageText = document.body.innerText; // document.documentElement.textContent

            if (pageText.includes(searchText)) {
                messages.push(searchText);
            } 

            if (messages.length > 0) {
                window.webkit.messageHandlers.checkMessagesHandler.postMessage({
                    messages: messages
                });
                return true;
            }
            return false;
        }
        
        var checkInterval = setInterval(function() {
            if (checkForErrors()) {
                clearInterval(checkInterval);
            }
        }, 300);
        """
    static let loadCompleteScript = """
        if (document.readyState === 'complete') {
            window.webkit.messageHandlers.pageLoadHandler.postMessage({});
        } else {
            window.addEventListener('load', function() {
                const checkInterval = setInterval(() => {
                    if (document.readyState === 'complete') {
                        clearInterval(checkInterval);
                        window.webkit.messageHandlers.pageLoadHandler.postMessage({ });
                    }
                }, 100);
            });
        }
        """
}

enum WebConstants {
    static let mjcUrl = "https://publicbg.mjs.bg/BgInfo"
    static let finalPageName: String = "Дирекция 'Българско гражданство'"
}
