import SwiftUI
import UIKit

struct AppTheme {
    static let backgroundColor = Color(uiColor: UIKit.backgroundColor)
    static let headerColor = Color(uiColor: UIKit.headerColor)
    static let textColor = Color(uiColor: UIKit.textColor)
    static let notAvailableColor = Color(uiColor: UIKit.notAvailableColor)
    static let shadowColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let headerFont = Font.system(size: 10).monospacedDigit().bold()
    static let textFont = Font.system(.body).monospacedDigit().bold()
    static let screenPadding: CGFloat = 4
    static let panelPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 8

    struct UIKit {
        static let backgroundColor = UIColor(red: 0.109, green: 0.109, blue: 0.117, alpha: 1.0)
        static let headerColor = UIColor.white
        static let textColor = UIColor.white
        static let notAvailableColor = UIColor.clear
    }
}
