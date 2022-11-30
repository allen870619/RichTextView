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
        guard let style = getTextStyle() else {
            return self
        }
        if enable {
            return CustomFont.bold.getFont(textStyle: style)
        } else {
            return CustomFont.regular.getFont(textStyle: style)
        }
    }

    var isBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    /// get font's textStyle
    func getTextStyle() -> UIFont.TextStyle? {
        switch pointSize {
        case CustomFont.getScaledSize(style: .largeTitle):
            return .largeTitle
        case CustomFont.getScaledSize(style: .title1):
            return .title1
        case CustomFont.getScaledSize(style: .title3):
            return .title3
        case CustomFont.getScaledSize(style: .body):
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
        let traitList = fontDescriptor.symbolicTraits
        let descriptor = fontDescriptor.withSymbolicTraits(traitList.subtracting(traits))
        return UIFont(descriptor: descriptor!, size: 0) // size 0 means keep the size as it is
    }
}
