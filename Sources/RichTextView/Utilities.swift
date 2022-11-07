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
        let style = fontDescriptor.object(forKey: .textStyle) as? UIFont.TextStyle
        guard let style else {
            return nil
        }
        switch style.rawValue {
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

    /// combine symbolic traits on it
    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) // size 0 means keep the size as it is
    }

    /// remove symbolic from original font
    private func withoutTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traitList = fontDescriptor.symbolicTraits
        traitList.remove(traits)
        let descriptor = fontDescriptor.withSymbolicTraits(traitList)
        return UIFont(descriptor: descriptor!, size: 0) // size 0 means keep the size as it is
    }
}
