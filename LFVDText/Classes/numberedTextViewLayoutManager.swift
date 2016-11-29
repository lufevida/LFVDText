//
//  numberedTextViewLayoutManager.swift
//
//  Courtesy of https://github.com/alldritt/TextKit_LineNumbers
//

import UIKit

class numberedTextViewLayoutManager : NSLayoutManager {
    
    var lastParagraphLocation = 0
    var lastParagraphNumber = 0
    
    func paragraphNumberForRange (characterRange : NSRange) -> (Int) {
        if characterRange.location == self.lastParagraphLocation {
            return self.lastParagraphNumber
        } else if characterRange.location < self.lastParagraphLocation {
            let string = (self.textStorage?.string)! as NSString
            var paragraphNumber = self.lastParagraphNumber as Int
            let range = NSMakeRange(characterRange.location, self.lastParagraphLocation - characterRange.location)
            string.enumerateSubstringsInRange(range, options: [.ByParagraphs, .SubstringNotRequired, .Reverse], usingBlock: { (substring, substringRange, enclosingRange, stop) in
                if enclosingRange.location <= characterRange.location {
                    stop
                }
                paragraphNumber -= 1
            })
            self.lastParagraphLocation = characterRange.location
            self.lastParagraphNumber = paragraphNumber
            return paragraphNumber
        } else {
            let string = (self.textStorage?.string)! as NSString
            var paragraphNumber = self.lastParagraphNumber as Int
            let range = NSMakeRange(self.lastParagraphLocation, characterRange.location - self.lastParagraphLocation)
            string.enumerateSubstringsInRange(range, options: [.ByParagraphs, .SubstringNotRequired], usingBlock: { (substring, substringRange, enclosingRange, stop) in
                if enclosingRange.location >= characterRange.location {
                    stop
                }
                paragraphNumber += 1
            })
            self.lastParagraphLocation = characterRange.location
            self.lastParagraphNumber = paragraphNumber
            return paragraphNumber
        }
    }
    
    override func processEditingForTextStorage(textStorage: NSTextStorage, edited editMask: NSTextStorageEditActions, range newCharRange: NSRange, changeInLength delta: Int, invalidatedRange invalidatedCharRange: NSRange) {
        super.processEditingForTextStorage(textStorage, edited: editMask, range: newCharRange, changeInLength: delta, invalidatedRange: invalidatedCharRange)
        if invalidatedCharRange.location < self.lastParagraphLocation {
            self.lastParagraphLocation = 0
            self.lastParagraphNumber = 0
        }
    }
    
    override func drawBackgroundForGlyphRange(glyphsToShow: NSRange, atPoint origin: CGPoint) {
        super.drawBackgroundForGlyphRange(glyphsToShow, atPoint: origin)
        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(10), NSForegroundColorAttributeName : UIColor.lightGrayColor()]
        var gutterRect = CGRectZero
        var paragraphNumber : Int!
        self.enumerateLineFragmentsForGlyphRange(glyphsToShow) { (rect, usedRect, textContainer, glyphRange, stop) in
            let characterRange = self.characterRangeForGlyphRange(glyphRange, actualGlyphRange: nil)
            let string = (self.textStorage?.string)! as NSString
            let paragraphRange = string.paragraphRangeForRange(characterRange)
            if characterRange.location == paragraphRange.location {
                gutterRect = CGRectOffset(CGRectMake(0, rect.origin.y, 40, rect.size.height), origin.x, origin.y)
                paragraphNumber = self.paragraphNumberForRange(characterRange)
                let line = NSString.init(format: "%ld", paragraphNumber + 1)
                let size = line.sizeWithAttributes(attributes)
                line.drawInRect(CGRectOffset(gutterRect, CGRectGetWidth(gutterRect) - 4 - size.width, (CGRectGetHeight(gutterRect) - size.height) * 0.5), withAttributes: attributes)
            }
        }
        if NSMaxRange(glyphsToShow) > self.numberOfGlyphs {
            let line = NSString.init(format: "%ld", paragraphNumber + 2)
            let size = line.sizeWithAttributes(attributes)
            gutterRect = CGRectOffset(gutterRect, 0, CGRectGetHeight(gutterRect))
            line.drawInRect(CGRectOffset(gutterRect, CGRectGetWidth(gutterRect) - 4 - size.width, (CGRectGetHeight(gutterRect) - size.height) * 0.5), withAttributes: attributes)
        }
    }
    
}