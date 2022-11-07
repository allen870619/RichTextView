//
//  ViewController.swift
//  RichTextViewDemo
//
//  Created by Lee Yen Lin on 2022/11/7.
//

import RichTextView
import UIKit

class ViewController: UIViewController {
    @IBOutlet var textView: RichTextView!
    @IBOutlet var segFont: UISegmentedControl!
    @IBOutlet var segAlign: UISegmentedControl!
    @IBOutlet var btnStyleList: [UIButton]!
    @IBOutlet var paragraphList: [UIButton]!

    /**
     view lifecycle
     */
    override func viewDidLoad() {
        uiInit()
        dataInit()

        textView.initTypingStatus()
        textView.delegate = self
    }

    deinit {
        print(#fileID)
    }

    /**
     ui initial
     */
    private func uiInit() {
        segFont.addAction(.init { [self] _ in
            let selIndex = segFont.selectedSegmentIndex
            let font: [UIFont.TextStyle] = [.largeTitle, .title2, .body]
            textView.setFont(fontStyle: font[selIndex])
        }, for: .valueChanged)

        btnStyleList[0].addAction(.init { [self] _ in
            textView.setBold()
            setBtnStyle(btnStyleList[0], textView.isBold)
        }, for: .touchUpInside)

        btnStyleList[1].addAction(.init { [self] _ in
            textView.setItalic()
            setBtnStyle(btnStyleList[1], textView.isItalic)
        }, for: .touchUpInside)

        btnStyleList[2].addAction(.init { [self] _ in
            textView.setDeleteline()
            setBtnStyle(btnStyleList[2], textView.hasDeleteLine)
        }, for: .touchUpInside)

        btnStyleList[3].addAction(.init { [self] _ in
            textView.setUnderline()
            setBtnStyle(btnStyleList[3], textView.hasUnderLine)
        }, for: .touchUpInside)

        // paragraph
        paragraphList[0].addAction(.init { [self] _ in
            textView.leftIndent()
        }, for: .touchUpInside)

        paragraphList[1].addAction(.init { [self] _ in
            textView.rightIndent()
        }, for: .touchUpInside)

        // align
        segAlign.addAction(.init { [self] _ in
            let index = segAlign.selectedSegmentIndex
            let align: [NSTextAlignment] = [.left, .center, .right]
            textView.setAlignment(align[index])
        }, for: .valueChanged)
    }

    private func setBtnStyle(_ btn: UIButton, _ avbl: Bool) {
        if avbl {
            btn.tintColor = .white
            btn.backgroundColor = UIColor.systemBlue

        } else {
            btn.tintColor = .systemBlue
            btn.backgroundColor = UIColor.systemBackground
        }
    }

    /**
     data initial
     */
    private func dataInit() {}
}

extension ViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_: UITextView) {
        // font
        if let fontStyle = textView.fontStyle {
            let list: [UIFont.TextStyle] = [.largeTitle, .title2, .body]
            segFont.selectedSegmentIndex = list.firstIndex(of: fontStyle) ?? -1
        } else {
            segFont.selectedSegmentIndex = -1
        }

        // alignment
        setBtnStyle(btnStyleList[0], textView.isBold)
        setBtnStyle(btnStyleList[1], textView.isItalic)
        setBtnStyle(btnStyleList[2], textView.hasDeleteLine)
        setBtnStyle(btnStyleList[3], textView.hasUnderLine)

        // alignment
        if let alignment = textView.alignment {
            let list: [NSTextAlignment] = [.left, .center, .right]
            segAlign.selectedSegmentIndex = list.firstIndex(of: alignment) ?? -1
        } else {
            segAlign.selectedSegmentIndex = -1
        }
    }
}
