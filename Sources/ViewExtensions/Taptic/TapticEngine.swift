import Foundation
import UIKit

public class TapticEngine {
    
    public enum TapticType : Int {
        
        case success = 0

        case warning = 1

        case error = 2
    }
    
    public class func activate(type: TapticType) {
        if #available(iOS 10.0, *) {
            guard let feedbackType = UINotificationFeedbackGenerator.FeedbackType(rawValue: type.rawValue) else { return }
            
            let taptic = UINotificationFeedbackGenerator()
            taptic.prepare()
            taptic.notificationOccurred(feedbackType)
            taptic.prepare()
        }
    }
}
