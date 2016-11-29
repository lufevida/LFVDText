//
//  numberedTextView.swift
//
//  Courtesy of https://github.com/alldritt/TextKit_LineNumbers
//

import UIKit

public class numberedTextView: UITextView {
    
    let kLineNumberGutterWidth = CGFloat(40)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        let textStorage = NSTextStorage()
        let layoutManager = numberedTextViewLayoutManager()
        let newTextContainer = NSTextContainer.init(size: CGSizeMake(CGFloat.max, CGFloat.max))
        newTextContainer.widthTracksTextView = true
        newTextContainer.exclusionPaths = [UIBezierPath.init(rect: CGRectMake(0, 0, 40, CGFloat.max))]
        layoutManager.addTextContainer(newTextContainer)
        textStorage.addLayoutManager(layoutManager)
        super.init(frame: frame, textContainer: newTextContainer)
        self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.contentMode = UIViewContentMode.Redraw
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let bounds = self.bounds
        CGContextSetFillColorWithColor(context, self.backgroundColor!.CGColor)
        CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y, kLineNumberGutterWidth, bounds.size.height))
        CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextStrokeRect(context, CGRectMake(bounds.origin.x + 39.5, bounds.origin.y, 0.5, CGRectGetHeight(bounds)))
        super.drawRect(rect)
    }

}
