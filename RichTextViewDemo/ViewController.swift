//
//  ViewController.swift
//  RichTextViewDemo
//
//  Created by Lee Yen Lin on 2022/11/7.
//

import UIKit
import RichTextView

class ViewController: UIViewController {
    @IBOutlet weak var textView: RichTextView!
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
    }

    deinit {
        print(#fileID)
    }

    /**
     ui initial
     */
    private func uiInit() {
        segFont.addAction(.init { [self] _ in
            let sel = segFont.selectedSegmentIndex
            let font: [UIFont.TextStyle] = [.largeTitle, .title2, .body]
            textView.setFont(fontStyle: font[sel])
        }, for: .valueChanged)

        btnStyleList[0].addAction(.init { [self] _ in
            textView.setBold()
        }, for: .touchUpInside)

        btnStyleList[1].addAction(.init { [self] _ in
            textView.setItalic()
        }, for: .touchUpInside)

        btnStyleList[2].addAction(.init { [self] _ in
            textView.setDeleteline()
        }, for: .touchUpInside)

        btnStyleList[3].addAction(.init { [self] _ in
            textView.setUnderline()
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

    /**
     data initial
     */
    private func dataInit() {}
}

