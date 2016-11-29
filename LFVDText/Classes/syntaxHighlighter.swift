//
//  syntaxHighlighter.swift
//  Copyright © 2016 Luis Vieira Damiani. All rights reserved.
//

import UIKit

public class syntaxHighlighter {
    
//------------------------------------------------------------------------
// MARK: Properties
//------------------------------------------------------------------------
    
    enum Language {
        case css
        case html
        case javascript
        case markdown
        case yaml
        case plain
    }
    
    var definitionsArray : [String]!
    var colorArray : [UIColor]!
    var nightModeColorArray : [UIColor]!
    var currentLanguage : Language
    
    required public init (fileExtension : String) {
        switch fileExtension {
        case "css", "sass", "scss":
            currentLanguage = .css
        case "htm", "html", "xml":
            currentLanguage = .html
        case "js":
            currentLanguage = .javascript
        case "md", "markdown":
            currentLanguage = .markdown
        case "yml", "yaml":
            currentLanguage = .yaml
        default:
            currentLanguage = .plain
        }
        defineLanguage()
    }
    
//------------------------------------------------------------------------
// MARK: Methods
//------------------------------------------------------------------------
    
    public func highlightText (textViewOutlet : UITextView) {
        let inputString = textViewOutlet.text
        let attributedString = NSMutableAttributedString(string: inputString, attributes: [
            NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
            ])
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.performLoops(attributedString)
            dispatch_async(dispatch_get_main_queue(), {
                textViewOutlet.textStorage.setAttributedString(attributedString)
            })
        }
    }
    
    public func updateHighlights (textViewOutlet : UITextView) {
        let cursorPosition = textViewOutlet.offsetFromPosition(textViewOutlet.beginningOfDocument, toPosition: textViewOutlet.selectedTextRange!.start)
        let attributedString = NSMutableAttributedString(attributedString: textViewOutlet.attributedText)
        let range = NSRange(location: 0, length: attributedString.length)
        do {
            let regularExpression = try NSRegularExpression(pattern: "\n", options: [])
            let matches = regularExpression.matchesInString(attributedString.string, options: [], range: range) as [NSTextCheckingResult]
            if matches.first != nil {
                if cursorPosition <= matches.first!.range.location {
                    //print("cursor before first break")
                    let loopRange = NSRange(location: 0, length: matches.first!.range.location)
                    let loopString = NSMutableAttributedString(attributedString: attributedString.attributedSubstringFromRange(loopRange))
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                        self.performLoops(loopString)
                        attributedString.replaceCharactersInRange(loopRange, withAttributedString: loopString)
                        dispatch_async(dispatch_get_main_queue(), {
                            textViewOutlet.textStorage.setAttributedString(attributedString)
                        })
                    }
                } else {
                    var positionArray : [Int] = []
                    positionArray.append(cursorPosition)
                    for match in matches {
                        positionArray.append(match.range.location)
                    }
                    positionArray.sortInPlace()
                    let cursorIndex = positionArray.indexOf(cursorPosition)
                    if positionArray.last == cursorPosition {
                        //print("cursor after last break")
                        let loopRange = NSRange(location: positionArray[cursorIndex! - 1], length: attributedString.length - positionArray[cursorIndex! - 1])
                        let loopString = NSMutableAttributedString(attributedString: attributedString.attributedSubstringFromRange(loopRange))
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                            self.performLoops(loopString)
                            attributedString.replaceCharactersInRange(loopRange, withAttributedString: loopString)
                            dispatch_async(dispatch_get_main_queue(), {
                                textViewOutlet.textStorage.setAttributedString(attributedString)
                            })
                        }
                    } else {
                        //print("cursor in the middle")
                        let loopRange = NSRange(location: positionArray[cursorIndex! - 1], length: positionArray[cursorIndex! + 1] - positionArray[cursorIndex! - 1])
                        let loopString = NSMutableAttributedString(attributedString: attributedString.attributedSubstringFromRange(loopRange))
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                            self.performLoops(loopString)
                            attributedString.replaceCharactersInRange(loopRange, withAttributedString: loopString)
                            dispatch_async(dispatch_get_main_queue(), {
                                textViewOutlet.textStorage.setAttributedString(attributedString)
                            })
                        }
                    }
                }
            } else {
                highlightText(textViewOutlet)
            }
        } catch {}
    }
    
    func performLoops (attributedString : NSMutableAttributedString) {
        let range = NSRange(location: 0, length: attributedString.string.utf16.count)
        attributedString.removeAttribute(NSForegroundColorAttributeName, range: range)
        attributedString.removeAttribute(NSFontAttributeName, range: range)
        var colorDictionary : [String : UIColor] = [:]
        if NSUserDefaults.standardUserDefaults().boolForKey("nightMode") == true {
            attributedString.addAttributes([
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)], range: range)
            var index = 0
            for definition in definitionsArray {
                colorDictionary[definition] = colorArray[index]
                index += 1
            }
        } else {
            attributedString.addAttributes([
                NSForegroundColorAttributeName : UIColor.blackColor(),
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)], range: range)
            var index = 0
            for definition in definitionsArray {
                colorDictionary[definition] = nightModeColorArray[index]
                index += 1
            }
        }
        for definition in definitionsArray {
            var arrayOfMatches : [NSTextCheckingResult] = []
            do {
                let regularExpression = try NSRegularExpression(pattern: definition, options: [])
                let matches = regularExpression.matchesInString(attributedString.string, options: [], range: range) as [NSTextCheckingResult]
                if matches != [] {
                    arrayOfMatches += matches
                }
            } catch {}
            for match in arrayOfMatches {
                attributedString.addAttributes([NSForegroundColorAttributeName : colorDictionary[definition]!], range: match.range)
            }
        }
    }
    
//------------------------------------------------------------------------
// MARK: Syntax Definitions
//------------------------------------------------------------------------
    
    func defineLanguage () {
        colorArray = []
        nightModeColorArray = []
        switch currentLanguage {
        case .css:
            definitionsArray = ["@\\w*?\\s", "\\s-?[\\w|-]*?:\\s", "\".*?\"", "/\\*(.|\n)*?\\*/"]
        case .html:
            definitionsArray = ["</?.*?>", "\".*?\"", "<!--(.|\n)*?-->"]
        case .javascript:
            definitionsArray = ["\\b(break|continue|debugger|do|while|for|function|if|else|return|switch|try|catch)\\b", "\\b(var)\\b", "\".*?\"", "//.*", "/\\*(.|\n)*?\\*/"]
        case .markdown:
            definitionsArray = ["(#|##|###|####|#####|######)\\s.*", "\\*(.*?)\\*|\\*\\*(.*?)\\*\\*|_(.*?)_|__(.*?)__|~~(.*?)~~", "!?\\[.*?\\]\\(.*?\\)", "`(.*)`"]
        case .yaml:
            definitionsArray = ["\\s.*?:\\s", "\".*?\"", "#.*?"]
        case .plain:
            definitionsArray = []
        }
        for _ in definitionsArray {
            colorArray.append(generateRandomColor())
            nightModeColorArray.append(generateRandomColor())
        }
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // stay away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
//------------------------------------------------------------------------
} // End of Document
//------------------------------------------------------------------------