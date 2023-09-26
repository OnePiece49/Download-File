import UIKit

let urlString = "https://www.youtube.com/watch?v=zX0D7a9LCsM&list=RDzX0D7"

func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}

print("DEBUG: \(verifyUrl(urlString: urlString))")

