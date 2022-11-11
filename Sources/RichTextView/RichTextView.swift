//
//  RichTextView.swift
//
//
//  Created by Lee Yen Lin on 2022/11/4.
//
// swiftlint:disable opening_brace
import UIKit

public class RichTextView: UITextView {
    /// config
    public let obliquenessVal = 0.3
    public let indentVal = CGFloat(32)
    var isDelete = false

    public func initTypingStatus() {
        typingAttributes[.font] = UIFont.preferredFont(forTextStyle: .body)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        typingAttributes[.paragraphStyle] = paragraphStyle
    }

    /* Fonts*/
    /// set font style
    public func setFont(fontStyle: UIFont.TextStyle) {
        // define target font, this will erase `bold` attribute
        var font = UIFont.preferredFont(forTextStyle: fontStyle)
        if fontStyle == .largeTitle {
            font = font.setBold(true)
        }

        // changing attribute
        let targetRange = selectedRange
        if targetRange.length == 0 {
            typingAttributes[.font] = font
        } else {
            setAttrWithKeepingPos { [weak self] in
                self?.setAttribute(.font, value: font, range: targetRange)
                self?.fixListPrefix()
            }
        }
    }

    /* Text Style*/
    /// set bold
    public func setBold() {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            // set typing font bold
            var font = typingAttributes[.font] as? UIFont
            let isBold = font?.isBold ?? false
            font = font?.setBold(!isBold)
            typingAttributes[.font] = font
        } else {
            if let attrList = getAttribute(targetRange, type: .font) as? [FontRange] {
                setAttrWithKeepingPos { [weak self] in
                    let allBold = !attrList.contains(where: { !$0.font.isBold })
                    for (font, range) in attrList {
                        let font = font.setBold(!allBold)
                        self?.setAttribute(.font, value: font, range: range)
                    }
                }
            }
        }
    }

    /// set textStyle to Italic
    public func setItalic() {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            let attr = typingAttributes[.obliqueness] as? Double ?? 0
            typingAttributes[.obliqueness] = attr == 0 ? obliquenessVal : nil
        } else {
            if let attrList = getAttribute(targetRange, type: .obliqueness) as? [DoubleRange] {
                setAttrWithKeepingPos { [weak self] in
                    guard let self else {
                        return
                    }
                    let length = attrList.reduce(0) { $0 + $1.range.length }
                    let allItalic = length == targetRange.length
                    self.setAttribute(.obliqueness,
                                      value: allItalic ? nil : self.obliquenessVal,
                                      range: targetRange)
                }
            }
        }
    }

    /// set textStyle with delete line
    public func setDeleteline() {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            let attr = typingAttributes[.strikethroughStyle] as? Int ?? 0
            typingAttributes[.strikethroughStyle] = attr == 0 ? 1 : nil
        } else {
            if let attrList = getAttribute(targetRange, type: .strikethroughStyle) as? [IntRange] {
                setAttrWithKeepingPos { [weak self] in
                    let length = attrList.reduce(0) { $0 + $1.range.length }
                    let allDeletion = length == targetRange.length
                    self?.setAttribute(.strikethroughStyle,
                                       value: allDeletion ? nil : 1,
                                       range: targetRange)
                }
            }
        }
    }

    /// set textStyle with underline
    public func setUnderline() {
        let targetRange = selectedRange
        if targetRange.length == 0 {
            let attr = typingAttributes[.underlineStyle] as? Int ?? 0
            typingAttributes[.underlineStyle] = attr == 0 ? 1 : nil
        } else {
            if let attrList = getAttribute(targetRange, type: .underlineStyle) as? [IntRange] {
                setAttrWithKeepingPos { [weak self] in
                    let length = attrList.reduce(0) { $0 + $1.range.length }
                    let allUnderLine = length == targetRange.length
                    self?.setAttribute(.underlineStyle,
                                       value: allUnderLine ? nil : 1,
                                       range: targetRange)
                }
            }
        }
    }

    /* Paragraph*/
    /// alignment
    ///
    /// This style will erase indent value
    public func setAlignment(_ align: NSTextAlignment) {
        let range = paragraphRange
        let newStyle = NSMutableParagraphStyle()
        newStyle.alignment = align
        if range.length == 0 {
            typingAttributes[.paragraphStyle] = newStyle
        } else {
            setAttrWithKeepingPos { [weak self] in
                self?.setAttribute(.paragraphStyle,
                                   value: newStyle,
                                   range: range)
            }
        }
    }

    /// set left indent
    public func leftIndent() {
        indentMove(-indentVal)
    }

    /// set right indent
    public func rightIndent() {
        indentMove(indentVal)
    }

    /// calculate indent
    private func indentMove(_ value: CGFloat) {
        let targetRange = paragraphRange

        // get current position
        var firstLine = CGFloat(0)
        var headLine = CGFloat(0)
        var tailLine = CGFloat(0) // This will less or equal 0
        var alignment = NSTextAlignment.natural
        if targetRange.length == 0 {
            let style = typingAttributes[.paragraphStyle] as? NSParagraphStyle
            firstLine = style?.firstLineHeadIndent ?? 0
            headLine = style?.headIndent ?? 0
            tailLine = style?.tailIndent ?? 0
            alignment = style?.alignment ?? .natural
        } else {
            if let styles = getAttribute(targetRange, type: .paragraphStyle) as? [ParagraphRange] {
                for style in styles {
                    firstLine = max(firstLine, style.paragraph.firstLineHeadIndent)
                    headLine = max(headLine, style.paragraph.headIndent)
                    tailLine = min(tailLine, style.paragraph.tailIndent)
                }
                alignment = styles.last?.paragraph.alignment ?? .natural
            }
        }

        // create new Style and set indent
        let newStyle = NSMutableParagraphStyle()
        newStyle.alignment = alignment
        let isNegIndent = tailLine < 0 || (headLine == 0 && value < 0)
        newStyle.headIndent = isNegIndent ? 0 : headLine + value
        newStyle.tailIndent = isNegIndent ? tailLine + value : 0
        newStyle.firstLineHeadIndent = isNegIndent ? newStyle.tailIndent : newStyle.headIndent

        // set back
        if paragraphRange.length == 0 {
            typingAttributes[.paragraphStyle] = newStyle
        } else {
            setAttrWithKeepingPos { [weak self] in
                self?.setAttribute(.paragraphStyle,
                                   value: newStyle,
                                   range: targetRange)
            }
        }
    }

    // List
    // bullet List
    /** set bullet list */
    /// 針對換行
    public func fixListPrefix() {
        let range = (text as NSString).paragraphRange(for: selectedRange)
        if isDelete {
            isDelete = false
            return
        }
        if range.length == 0 {
            let paragraphStyle = typingAttributes[.paragraphStyle] as? NSParagraphStyle
            if paragraphStyle?.firstLineHeadIndent != paragraphStyle?.headIndent {
                setBulletList(range)
            }
        }
    }

    public func setBulletList(_ range: NSRange? = nil, forceSetMode: Bool? = nil) {
        let targetRange = range == nil ? paragraphRange : range!

        // get current position and data
        let indicator = NSMutableAttributedString(string: "•")
        let originAttrStr = attributedText.mutableCopy() as? NSMutableAttributedString

        if targetRange.length == 0 {
            // get current paragraph style
            let style = typingAttributes[.paragraphStyle] as? NSParagraphStyle
            let firstIndent = style?.firstLineHeadIndent ?? 0

            // set enable
            // for calculate size
            indicator.addAttributes(typingAttributes,
                                    range: .init(location: 0, length: indicator.length))
            let newParagraph = NSMutableParagraphStyle()
            newParagraph.alignment = style?.alignment ?? .left
            newParagraph.firstLineHeadIndent = firstIndent
            newParagraph.headIndent = firstIndent + indicator.size().width
            typingAttributes[.paragraphStyle] = newParagraph

            // dot
            indicator.addAttributes(typingAttributes,
                                    range: .init(location: 0, length: indicator.length))

            // insert to original text
            originAttrStr?.insert(indicator, at: selectedRange.location)
            attributedText = originAttrStr
        } else {
            // separate paragraph
            let targetRange = selectedRange.length == 0 ? paragraphRange : selectedRange
            let targetStr = originAttrStr?.attributedSubstring(from: targetRange).string ?? ""

            // create paragraph range list
            var rangeList = [NSRange]()
            let strLenList = (targetStr.split(separator: "\n")).map(\.count)
            var start = targetRange.location
            for len in strLenList {
                let range = (text as NSString).paragraphRange(for: .init(location: start, length: len))
                rangeList.append(range)
                start += len + 1
            }

            var shift = 0 // for delete/insert icon
            for range in rangeList {
                let shiftRange = NSRange(location: range.location + shift, length: range.length)
                if let result = setSingleParagraph(range: shiftRange,
                                                   indicator: indicator,
                                                   enable: forceSetMode)
                {
                    shift += indicator.length * (result ? 1 : -1)
                }
            }
        }
    }

    private func setSingleParagraph(range: NSRange,
                                    indicator: NSMutableAttributedString,
                                    enable: Bool? = nil) -> Bool?
    {
        guard let originAttrStr = attributedText.mutableCopy() as? NSMutableAttributedString else {
            return nil
        }
        var attrList = typingAttributes
        if range.length != 0 {
            attrList = attributedText.attributes(at: range.location, effectiveRange: nil)
        }
        indicator.addAttributes(attrList, range: NSRange(location: 0, length: indicator.length))
        let paragrapghStyle = (getAttribute(range, type: .paragraphStyle) as? [ParagraphRange])?.last
        let newParagraphStyle = NSMutableParagraphStyle()
        let firstIndent = paragrapghStyle?.paragraph.firstLineHeadIndent ?? 0
        let headIndent = paragrapghStyle?.paragraph.headIndent ?? 0
        newParagraphStyle.alignment = paragrapghStyle?.paragraph.alignment ?? .left

        let enable = enable == nil ? firstIndent == headIndent : enable!

        if enable { // add icon
            originAttrStr.insert(indicator, at: range.location)
            newParagraphStyle.firstLineHeadIndent = firstIndent
            newParagraphStyle.headIndent = firstIndent + indicator.size().width
            originAttrStr.addAttribute(.paragraphStyle,
                                       value: newParagraphStyle,
                                       range: .init(location: range.location,
                                                    length: range.length + indicator.length))
        } else {
            newParagraphStyle.firstLineHeadIndent = firstIndent
            newParagraphStyle.headIndent = firstIndent
            originAttrStr.addAttribute(.paragraphStyle,
                                       value: newParagraphStyle,
                                       range: range)
            originAttrStr.deleteCharacters(in: .init(location: range.location,
                                                     length: indicator.length))

            isDelete = true
        }
        attributedText = originAttrStr
        typingAttributes[.paragraphStyle] = newParagraphStyle
        return enable
    }
}

extension RichTextView {
    typealias FontRange = (font: UIFont, range: NSRange)
    typealias DoubleRange = (val: Double?, range: NSRange)
    typealias IntRange = (val: Int?, range: NSRange)
    typealias ParagraphRange = (paragraph: NSMutableParagraphStyle, range: NSRange)

    /// paragraph of selectedRange
    public var paragraphRange: NSRange {
        (text as NSString).paragraphRange(for: selectedRange)
    }

    /* Attributes*/
    /// get attribure list
    func getAttribute(_ range: NSRange, type: NSAttributedString.Key) -> [(Any, NSRange)] {
        var list = [(Any, NSRange)]()
        attributedText.enumerateAttributes(in: range) { attrs, range, _ in
            if let attr = attrs[type] {
                list.append((attr, range))
            }
        }
        return list
    }

    /// set attribute
    func setAttribute(_ attribute: NSAttributedString.Key, value: Any?, range: NSRange? = nil) {
        let targetRange = range ?? selectedRange

        let origin = NSMutableAttributedString(attributedString: attributedText)
        origin.removeAttribute(attribute, range: targetRange)
        if let value {
            origin.addAttribute(attribute, value: value, range: targetRange)
        }
        attributedText = origin
    }

    /* others*/
    /// Keep scrollview after set selected
    func setAttrWithKeepingPos(_ todo: (() -> Void)?) {
        let tmpSelect = selectedRange

        todo?()

        selectedRange = tmpSelect
        scrollRangeToVisible(tmpSelect)
    }
}
