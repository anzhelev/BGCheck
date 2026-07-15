enum JSConstants {
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
