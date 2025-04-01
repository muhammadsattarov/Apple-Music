

import UIKit
import SwiftUICore

extension UIColor {
  static var accentColor: UIColor {
    return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
  }
}


extension Color {
  static let redColor = Color("redColor") // Asset Catalog-dagi rang
  static let buttonFonColor = Color("buttonFonColor")
  static let customRed = Color(hex: "#FF5733") // Hex dan foydalanish
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: Double
        switch hex.count {
        case 6: // RGB (ff0000)
            (a, r, g, b) = (1, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        case 8: // ARGB (ffff0000)
            (a, r, g, b) = (Double((int >> 24) & 0xFF) / 255, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        default:
            (a, r, g, b) = (1, 0, 0, 0)
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
