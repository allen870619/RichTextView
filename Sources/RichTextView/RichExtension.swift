//
//  RichExtension.swift
//
//
//  Created by Lee Yen Lin on 2022/11/4.
//

import UIKit

/// Edit
///
/// Override copy paste method for image files
public extension RichTextView {
    internal typealias AttachmentRange = (attachment: NSTextAttachment, range: NSRange)

    // Edit
    /** copy and paste */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return UIPasteboard.general.hasImages || super.canPerformAction(action, withSender: sender)
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    override func cut(_ sender: Any?) {
        let attrList = getAttribute(selectedRange, type: .attachment) as? [AttachmentRange]
        if let attrList, !attrList.isEmpty {
            // original String
            let oriAttrString = attributedText.mutableCopy() as? NSMutableAttributedString

            // get image files from attachment
            let startLoc = attrList.first?.range.location
            var imgList = [UIImage]()
            var deleteList = [NSRange]()
            for attr in attrList {
                if let image = attr.attachment.image {
                    imgList.append(image)
                    deleteList.append(attr.range)
                }
            }

            // delete attachment string
            deleteList.reverse()
            for item in deleteList {
                oriAttrString?.deleteCharacters(in: item)
            }

            // copy image to clipboard
            if imgList.count == 1 {
                UIPasteboard.general.image = imgList.first
            } else {
                UIPasteboard.general.images = imgList
            }

            // set back to textView
            attributedText = oriAttrString
            if let startLoc {
                selectedRange = .init(location: startLoc, length: 0)
            }
        } else {
            super.cut(sender)
        }
    }

    override func copy(_ sender: Any?) {
        if let attrList = getAttribute(selectedRange, type: .attachment) as? [AttachmentRange] {
            // get images
            var imgList = [UIImage]()
            for attr in attrList {
                if let image = attr.attachment.image {
                    imgList.append(image)
                }
            }

            // copy to clipboard
            if imgList.count == 1 {
                UIPasteboard.general.image = imgList.first
            } else {
                UIPasteboard.general.images = imgList
            }
        } else {
            super.copy(sender)
        }
    }

    override func paste(_ sender: Any?) {
        if UIPasteboard.general.hasImages {
            if let imageList = UIPasteboard.general.images {
                for image in imageList {
                    insertImage(image)
                }
            } else if let image = UIPasteboard.general.image {
                insertImage(image)
            }
        } else {
            super.paste(sender)
        }
    }

    /// Insert text
    func insertAttrText(_ attrText: NSAttributedString) {
        let location = selectedRange.location
        let originText = attributedText.mutableCopy() as? NSMutableAttributedString
        originText?.insert(attrText, at: location)
        attributedText = originText
        selectedRange.location += attrText.length
    }

    /// Insert Image to TextView
    func insertImage(_ image: UIImage?) {
        guard let image else {
            return
        }

        let width = min(414, frame.width - 32)

        // image
        let attachment = NSTextAttachment()
        attachment.image = image
        let resizeHeight = image.size.height * width / image.size.width
        attachment.bounds = CGRect(origin: .init(x: 0, y: 0),
                                   size: .init(width: width,
                                               height: resizeHeight))
        let attachString = NSMutableAttributedString(attachment: attachment)

        // next line
        let enterString = NSMutableAttributedString(string: "\n")

        // adding attribute
        let attrList = typingAttributes
        attachString.addAttributes(attrList, range: NSRange(location: 0, length: attachString.length))
        enterString.addAttributes(attrList, range: NSRange(location: 0, length: enterString.length))

        // insert
        insertAttrText(enterString)
        insertAttrText(attachString)
        insertAttrText(enterString)
    }
}
