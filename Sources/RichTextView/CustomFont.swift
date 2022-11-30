//
//  File.swift
//
//
//  Created by Lee Yen Lin on 2022/11/30.
//

import UIKit

let fontName = "NotoSansTC"

enum CustomFont: String {
    case regular = "Regular"
    case bold = "Bold"
    case unknown

    /// Get UIFont by UIFont.TextStyle
    func getFont(textStyle type: UIFont.TextStyle) -> UIFont {
        switch type {
        case .largeTitle:
            return getFont(fontSize: CustomFontSize.largeTitle)
        case .title1:
            return getFont(fontSize: CustomFontSize.title)
        case .title3:
            return getFont(fontSize: CustomFontSize.subtitle)
        case .body:
            return getFont(fontSize: CustomFontSize.body)
        default:
            return UIFont.preferredFont(forTextStyle: .body)
        }
    }

    /// Get UIFont by CustomFontSize
    func getFont(fontSize type: CustomFontSize) -> UIFont {
        let fallback = UIFont.preferredFont(forTextStyle: .body)
        let originFont = UIFont(name: "\(fontName)-\(rawValue)", size: type.rawValue) ?? fallback
        return UIFontMetrics(forTextStyle: type.transToTextStyle()).scaledFont(for: originFont)
    }

    /// Get scaled font size
    static func getScaledSize(style: UIFont.TextStyle) -> CGFloat {
        let font = UIFont(name: "\(fontName)-\(CustomFont.regular.rawValue)",
                          size: CustomFontSize.getSizeByStyle(style: style)) ?? .preferredFont(forTextStyle: .body)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font).pointSize
    }
}

enum CustomFontSize: CGFloat {
    case largeTitle = 32
    case title = 28
    case subtitle = 24
    case body = 18

    static func getSizeByStyle(style: UIFont.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle:
            return largeTitle.rawValue
        case .title1:
            return title.rawValue
        case .title3:
            return subtitle.rawValue
        default:
            return body.rawValue
        }
    }

    func transToTextStyle() -> UIFont.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title1
        case .subtitle:
            return .title3
        case .body:
            return .body
        }
    }
}
