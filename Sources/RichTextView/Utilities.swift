//
//  Utilities.swift
//
//
//  Created by Lee Yen Lin on 2022/11/7.
//

import UIKit

extension UIFont {
    /// Bold
    func setBold(_ enable: Bool) -> UIFont {
        if enable {
            return withTraits(traits: .traitBold)
        } else {
            return withoutTraits(traits: .traitBold)
        }
    }

    var isBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    /// get font's textStyle
    func getTextStyle() -> UIFont.TextStyle? {
        // 16以下會讀不到字體 導致大小重設, 故直接參照原始大小做比較
        if #available(iOS 16.0, *) {
            guard let style = fontDescriptor.object(forKey: .textStyle) as? UIFont.TextStyle else {
                return nil
            }
            return getTextStyleByName(style.rawValue)
        } else {
            return getTextStyleBySize(fontDescriptor.pointSize)
        }
    }

    private func getTextStyleByName(_ rawName: String) -> UIFont.TextStyle? {
        switch rawName {
        case let name where name.contains("Title0"):
            return .largeTitle
        case let name where name.contains("Title1"):
            return .title1
        case let name where name.contains("Title2"):
            return .title2
        case let name where name.contains("Title3"):
            return .title3
        case let name where name.contains("Body"):
            return .body
        default:
            return nil
        }
    }

    private func getTextStyleBySize(_ rawValue: CGFloat) -> UIFont.TextStyle? {
        switch rawValue {
        case 34:
            return .largeTitle
        case 28:
            return .title1
        case 22:
            return .title2
        case 20:
            return .title3
        case 17:
            return .body
        default:
            return nil
        }
    }

    /// combine symbolic traits on it
    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        let size = fontDescriptor.pointSize
        return UIFont(descriptor: descriptor!, size: size) // size 0 means keep the size as it is
    }

    /// remove symbolic from original font
    private func withoutTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let traitList = fontDescriptor.symbolicTraits
        let descriptor = fontDescriptor.withSymbolicTraits(traitList.subtracting(traits))
        return UIFont(descriptor: descriptor!, size: 0) // size 0 means keep the size as it is
    }
}
