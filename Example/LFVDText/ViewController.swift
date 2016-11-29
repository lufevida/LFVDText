//
//  ViewController.swift
//  LFVDText
//
//  Created by lufevida on 11/29/2016.
//  Copyright (c) 2016 lufevida. All rights reserved.
//

import UIKit
import LFVDText

class ViewController: UIViewController, UITextViewDelegate {
    
    var textViewOutlet: UITextView!
    var thisSyntaxHighlighter : syntaxHighlighter!
    var shouldHighlight = false
    var shouldReload = false

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewOutlet = numberedTextView(frame: view.frame)
        view = textViewOutlet
        textViewOutlet.delegate = self
        textViewOutlet.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textViewOutlet.autocapitalizationType = .None
        textViewOutlet.autocorrectionType = .No
        textViewOutlet.spellCheckingType = .No
        thisSyntaxHighlighter = syntaxHighlighter(fileExtension: "html")
    }
    
    func textViewDidChange(textView: UITextView) {
        if shouldHighlight == true {
            thisSyntaxHighlighter.updateHighlights(textViewOutlet)
        } else if shouldReload == true {
            thisSyntaxHighlighter.highlightText(textViewOutlet)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 1 {
            shouldHighlight = true
            shouldReload = false
        } else if text.characters.count > 1 {
            shouldHighlight = false
            shouldReload = true
        } else {
            shouldHighlight = false
            shouldReload = false
        }
        return true
    }
    
}