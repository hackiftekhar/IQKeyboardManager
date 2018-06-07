//
//  IQToolbar.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit

/** @abstract   IQToolbar for IQKeyboardManager.    */
open class IQToolbar: UIToolbar , UIInputViewAudioFeedback {

    private static var _classInitialize: Void = classInitialize()
    
    private class func classInitialize() {
        
        let  appearanceProxy = self.appearance()

        appearanceProxy.barTintColor = nil
        
        let positions : [UIBarPosition] = [.any,.bottom,.top,.topAttached]

        for position in positions {

            appearanceProxy.setBackgroundImage(nil, forToolbarPosition: position, barMetrics: .default)
            appearanceProxy.setShadowImage(nil, forToolbarPosition: .any)
        }

        //Background color
        appearanceProxy.backgroundColor = nil
    }
    
    /**
     Previous bar button of toolbar.
     */
    private var privatePreviousBarButton: IQBarButtonItem?
    @objc open var previousBarButton : IQBarButtonItem {
        get {
            if privatePreviousBarButton == nil {
                privatePreviousBarButton = IQBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
                privatePreviousBarButton?.accessibilityLabel = "Toolbar Previous Button"
            }
            return privatePreviousBarButton!
        }
        
        set (newValue) {
            privatePreviousBarButton = newValue
        }
    }
    
    /**
     Next bar button of toolbar.
     */
    private var privateNextBarButton: IQBarButtonItem?
    @objc open var nextBarButton : IQBarButtonItem {
        get {
            if privateNextBarButton == nil {
                privateNextBarButton = IQBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
                privateNextBarButton?.accessibilityLabel = "Toolbar Next Button"
            }
            return privateNextBarButton!
        }
        
        set (newValue) {
            privateNextBarButton = newValue
        }
    }
    
    /**
     Title bar button of toolbar.
     */
    private var privateTitleBarButton: IQTitleBarButtonItem?
    @objc open var titleBarButton : IQTitleBarButtonItem {
        get {
            if privateTitleBarButton == nil {
                privateTitleBarButton = IQTitleBarButtonItem(title: nil)
                privateTitleBarButton?.accessibilityLabel = "Toolbar Title Button"
            }
            return privateTitleBarButton!
        }
        
        set (newValue) {
            privateTitleBarButton = newValue
        }
    }
    
    /**
     Done bar button of toolbar.
     */
    private var privateDoneBarButton: IQBarButtonItem?
    @objc open var doneBarButton : IQBarButtonItem {
        get {
            if privateDoneBarButton == nil {
                privateDoneBarButton = IQBarButtonItem(title: nil, style: .done, target: nil, action: nil)
                privateDoneBarButton?.accessibilityLabel = "Toolbar Done Button"
            }
            return privateDoneBarButton!
        }
        
        set (newValue) {
            privateDoneBarButton = newValue
        }
    }

    /**
     Fixed space bar button of toolbar.
     */
    private var privateFixedSpaceBarButton: IQBarButtonItem?
    @objc open var fixedSpaceBarButton : IQBarButtonItem {
        get {
            if privateFixedSpaceBarButton == nil {
                privateFixedSpaceBarButton = IQBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            }
            privateFixedSpaceBarButton!.isSystemItem = true
            return privateFixedSpaceBarButton!
        }
        
        set (newValue) {
            privateFixedSpaceBarButton = newValue
        }
    }

    override init(frame: CGRect) {
        _ = IQToolbar._classInitialize
        super.init(frame: frame)
        
        sizeToFit()
        autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        self.isTranslucent = true
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        _ = IQToolbar._classInitialize
        super.init(coder: aDecoder)

        sizeToFit()
        autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        self.isTranslucent = true
    }

    @objc override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFit = super.sizeThatFits(size)
        sizeThatFit.height = 44
        return sizeThatFit
    }

    @objc override open var tintColor: UIColor! {
        
        didSet {
            if let unwrappedItems = items {
                for item in unwrappedItems {
                    item.tintColor = tintColor
                }
            }
        }
    }
    
    @objc override open var barStyle: UIBarStyle {
        didSet {
            
            if titleBarButton.selectableTitleColor == nil {
                if barStyle == .default {
                    titleBarButton.titleButton?.setTitleColor(UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), for: .normal)
                } else {
                    titleBarButton.titleButton?.setTitleColor(UIColor.yellow, for: .normal)
                }
            }
        }
    }
    
    @objc override open func layoutSubviews() {

        super.layoutSubviews()

        //If running on Xcode9 (iOS11) only then we'll validate for iOS version, otherwise for older versions of Xcode (iOS10 and below) we'll just execute the tweak
#if swift(>=3.2)

        if #available(iOS 11, *) {
            return
        } else if let customTitleView = titleBarButton.customView {
            var leftRect = CGRect.null
            var rightRect = CGRect.null
            var isTitleBarButtonFound = false
            
            let sortedSubviews = self.subviews.sorted(by: { (view1 : UIView, view2 : UIView) -> Bool in
                
                let x1 = view1.frame.minX
                let y1 = view1.frame.minY
                let x2 = view2.frame.minX
                let y2 = view2.frame.minY
                
                if x1 != x2 {
                    return x1 < x2
                } else {
                    return y1 < y2
                }
            })
            
            for barButtonItemView in sortedSubviews {
                
                if isTitleBarButtonFound == true {
                    rightRect = barButtonItemView.frame
                    break
                } else if barButtonItemView === customTitleView {
                    isTitleBarButtonFound = true
                    //If it's UIToolbarButton or UIToolbarTextButton (which actually UIBarButtonItem)
                } else if barButtonItemView.isKind(of: UIControl.self) == true {
                    leftRect = barButtonItemView.frame
                }
            }
            
            let titleMargin : CGFloat = 16

            let maxWidth : CGFloat = self.frame.width - titleMargin*2 - (leftRect.isNull ? 0 : leftRect.maxX) - (rightRect.isNull ? 0 : self.frame.width - rightRect.minX)
            let maxHeight = self.frame.height
            
            let sizeThatFits = customTitleView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
            
            var titleRect : CGRect
            
            if sizeThatFits.width > 0 && sizeThatFits.height > 0 {
                let width = min(sizeThatFits.width, maxWidth)
                let height = min(sizeThatFits.height, maxHeight)
                
                var x : CGFloat

                if (leftRect.isNull == false) {
                    x = titleMargin + leftRect.maxX + ((maxWidth - width)/2)
                } else {
                    x = titleMargin
                }
                
                let y = (maxHeight - height)/2
                
                titleRect = CGRect(x: x, y: y, width: width, height: height)
            } else {
                
                var x : CGFloat
                
                if (leftRect.isNull == false) {
                    x = titleMargin + leftRect.maxX
                } else {
                    x = titleMargin
                }

                let width : CGFloat = self.frame.width - titleMargin*2 - (leftRect.isNull ? 0 : leftRect.maxX) - (rightRect.isNull ? 0 : self.frame.width - rightRect.minX)
                
                titleRect = CGRect(x: x, y: 0, width: width, height: maxHeight)
            }
            
            customTitleView.frame = titleRect
        }
    
#else
        if let customTitleView = titleBarButton.customView {
            var leftRect = CGRect.null
            var rightRect = CGRect.null
            var isTitleBarButtonFound = false
            
            let sortedSubviews = self.subviews.sorted(by: { (view1 : UIView, view2 : UIView) -> Bool in
                
                let x1 = view1.frame.minX
                let y1 = view1.frame.minY
                let x2 = view2.frame.minX
                let y2 = view2.frame.minY
                
                if x1 != x2 {
                    return x1 < x2
                } else {
                    return y1 < y2
                }
            })
            
            for barButtonItemView in sortedSubviews {
                
                if isTitleBarButtonFound == true {
                    rightRect = barButtonItemView.frame
                    break
                } else if barButtonItemView === titleBarButton.customView {
                    isTitleBarButtonFound = true
                    //If it's UIToolbarButton or UIToolbarTextButton (which actually UIBarButtonItem)
                } else if barButtonItemView.isKind(of: UIControl.self) == true {
                    leftRect = barButtonItemView.frame
                }
            }
            
            let titleMargin : CGFloat = 16
            let maxWidth : CGFloat = self.frame.width - titleMargin*2 - (leftRect.isNull ? 0 : leftRect.maxX) - (rightRect.isNull ? 0 : self.frame.width - rightRect.minX)
            let maxHeight = self.frame.height
            
            let sizeThatFits = customTitleView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
            
            var titleRect : CGRect

            if sizeThatFits.width > 0 && sizeThatFits.height > 0 {
                let width = min(sizeThatFits.width, maxWidth)
                let height = min(sizeThatFits.height, maxHeight)
                
                var x : CGFloat
                
                if (leftRect.isNull == false) {
                    x = titleMargin + leftRect.maxX + ((maxWidth - width)/2)
                } else {
                    x = titleMargin
                }

                let y = (maxHeight - height)/2
                
                titleRect = CGRect(x: x, y: y, width: width, height: height)
            } else {
                
                var x : CGFloat
                
                if (leftRect.isNull == false) {
                    x = titleMargin + leftRect.maxX
                } else {
                    x = titleMargin
                }

                let width : CGFloat = self.frame.width - titleMargin*2 - (leftRect.isNull ? 0 : leftRect.maxX) - (rightRect.isNull ? 0 : self.frame.width - rightRect.minX)
                
                titleRect = CGRect(x: x, y: 0, width: width, height: maxHeight)
            }
            
            customTitleView.frame = titleRect
        }
#endif
    }
    
    @objc open var enableInputClicksWhenVisible: Bool {
        return true
    }
    
    deinit {

        items = nil
        privatePreviousBarButton = nil
        privateNextBarButton = nil
        privateTitleBarButton = nil
        privateDoneBarButton = nil
        privateFixedSpaceBarButton = nil
    }
}
