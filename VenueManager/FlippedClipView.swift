//
//  FlippedClipView.swift
//  SeatingSimulator
//
//  Created by Charles Billette on 2015-12-09.
//  Copyright © 2015 Charles Billette. All rights reserved.
//

import Foundation
import Cocoa


class FlippedClipView : NSClipView{

    
    override var flipped:Bool {
        get {
            return true
        }
    }
    
    override func constrainBoundsRect(proposedBounds: NSRect) -> NSRect {
        
        var rect = super.constrainBoundsRect(proposedBounds)
        if let containerView = self.documentView as? NSView {
            
            if (rect.size.width > containerView.frame.size.width) {
                rect.origin.x = (containerView.frame.width - rect.width ) / 2
            }
            
            if(rect.size.height > containerView.frame.size.height) {
                rect.origin.y = (containerView.frame.height - rect.height ) / 2
            }
        }
        
        return rect
    }
}
