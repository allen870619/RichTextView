//
//  RichTextViewGetter.swift
//
//
//  Created by Lee Yen Lin on 2022/11/7.
//

import UIKit

protocol RichTextViewGetter {
    var fontStyle: UIFont.TextStyle? { get }
    var isBold: Bool { get }
    var isItalic: Bool { get }
    var hasDeleteLine: Bool { get }
    var hasUnderLine: Bool { get }
    var alignment: NSTextAlignment? { get }
}

/// Getter
///
/// Instance method for getting attribute status.
/// Return `false` or `nil` if there're multiple status exist.
extension RichTextView: RichTextViewGetter {
    /// Get font style
    public var fontStyle: UIFont.TextStyle? {
        let targetRange = selectedRange
        if targetRange.length == 0 { // typingAttr
            let font = typingAttributes[.font] as? UIFont
            return font?.getTextStyle()
        } else {
            let fontList = getAttribute(targetRange, type: .font) as? [FontRange] ?? []
            if fontList.isEmpty {
                return nil
            }
            let style = fontList.first?.font
            for font in fontList where font.font != style {
                return nil
            }
            return font?.getTextStyle()
        }
    }

    /// Get bold
    public var isBold: Bool {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            let font = typingAttributes[.font] as? UIFont
            return font?.isBold ?? false
        } else {
            let attrList = getAttribute(targetRange, type: .font) as? [FontRange] ?? []
            return !attrList.contains(where: { !$0.font.isBold })
        }
    }

    /// Get italic
    public var isItalic: Bool {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            let obliqueness = typingAttributes[.obliqueness] as? Double ?? 0
            return obliqueness != 0
        } else {
            let attrList = getAttribute(targetRange, type: .obliqueness) as? [DoubleRange] ?? []
            if attrList.isEmpty {
                return false
            }
            let totalLen = attrList.reduce(0) { $0 + $1.range.length }
            return totalLen == targetRange.length
        }
    }

    /// Get hasDeleteLine
    public var hasDeleteLine: Bool {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            let strikethroughStyle = typingAttributes[.strikethroughStyle] as? Int ?? 0
            return strikethroughStyle != 0
        } else {
            let attrList = getAttribute(targetRange, type: .strikethroughStyle) as? [IntRange] ?? []
            if attrList.isEmpty {
                return false
            }
            let totalLen = attrList.reduce(0) { $0 + $1.range.length }
            return totalLen == targetRange.length
        }
    }

    /// Get italic
    public var hasUnderLine: Bool {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            let underlineStyle = typingAttributes[.underlineStyle] as? Int ?? 0
            return underlineStyle != 0
        } else {
            let attrList = getAttribute(targetRange, type: .underlineStyle) as? [IntRange] ?? []
            if attrList.isEmpty {
                return false
            }
            let totalLen = attrList.reduce(0) { $0 + $1.range.length }
            return totalLen == targetRange.length
        }
    }

    /// Get paragraph alignment
    public var alignment: NSTextAlignment? {
        let range = paragraphRange
        if range.length == 0 {
            let style = typingAttributes[.paragraphStyle] as? NSParagraphStyle
            return style?.alignment
        } else {
            let attrList = getAttribute(range, type: .paragraphStyle) as? [ParagraphRange] ?? []
            if attrList.isEmpty {
                return nil
            }
            let alignment = attrList.first?.paragraph.alignment
            for attr in attrList where attr.paragraph.alignment != alignment {
                return nil
            }
            return alignment
        }
    }
}
