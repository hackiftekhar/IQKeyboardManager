//
//  IQKeyboardManager+Position.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-20 Iftekhar Qurashi.
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

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    private struct AssociatedKeys {
        static var movedDistance: Int = 0
        static var movedDistanceChanged: Int = 0
        static var lastScrollView: Int = 0
        static var startingContentOffset: Int = 0
        static var startingScrollIndicatorInsets: Int = 0
        static var startingContentInsets: Int = 0
        static var startingTextViewContentInsets: Int = 0
        static var startingTextViewScrollIndicatorInsets: Int = 0
        static var isTextViewContentInsetChanged: Int = 0
        static var hasPendingAdjustRequest: Int = 0
    }

    /**
     moved distance to the top used to maintain distance between keyboard and textField. Most of the time this will be a positive value.
     */
    private(set) var movedDistance: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.movedDistance) as? CGFloat ?? 0.0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.movedDistance, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            movedDistanceChanged?(movedDistance)
        }
    }

    /**
    Will be called then movedDistance will be changed
     */
    @objc var movedDistanceChanged: ((CGFloat) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.movedDistanceChanged) as? ((CGFloat) -> Void)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.movedDistanceChanged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            movedDistanceChanged?(movedDistance)
        }
    }

    /** Variable to save lastScrollView that was scrolled. */
    internal weak var lastScrollView: UIScrollView? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.lastScrollView) as? WeakObjectContainer)?.object as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.lastScrollView, WeakObjectContainer(object: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** LastScrollView's initial contentOffset. */
    internal var startingContentOffset: CGPoint {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startingContentOffset) as? CGPoint ?? IQKeyboardManager.kIQCGPointInvalid
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startingContentOffset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** LastScrollView's initial scrollIndicatorInsets. */
    internal var startingScrollIndicatorInsets: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startingScrollIndicatorInsets) as? UIEdgeInsets ?? .init()
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startingScrollIndicatorInsets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** LastScrollView's initial contentInsets. */
    internal var startingContentInsets: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startingContentInsets) as? UIEdgeInsets ?? .init()
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startingContentInsets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** used to adjust contentInset of UITextView. */
    internal var startingTextViewContentInsets: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startingTextViewContentInsets) as? UIEdgeInsets ?? .init()
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startingTextViewContentInsets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** used to adjust scrollIndicatorInsets of UITextView. */
    internal var startingTextViewScrollIndicatorInsets: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startingTextViewScrollIndicatorInsets) as? UIEdgeInsets ?? .init()
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startingTextViewScrollIndicatorInsets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** used with textView to detect a textFieldView contentInset is changed or not. (Bug ID: #92)*/
    internal var isTextViewContentInsetChanged: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isTextViewContentInsetChanged) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.isTextViewContentInsetChanged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To know if we have any pending request to adjust view position. */
    private var hasPendingAdjustRequest: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.hasPendingAdjustRequest) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.hasPendingAdjustRequest, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal func optimizedAdjustPosition() {
        if !hasPendingAdjustRequest {
            hasPendingAdjustRequest = true
            OperationQueue.main.addOperation {
                self.adjustPosition()
                self.hasPendingAdjustRequest = false
            }
        }
    }

    /* Adjusting RootViewController's frame according to interface orientation. */
    private func adjustPosition() {

        //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
        guard hasPendingAdjustRequest,
              let textFieldView: UIView = textFieldView,
              let rootController: UIViewController = textFieldView.parentContainerViewController(),
              let window: UIWindow = keyWindow(),
              let textFieldViewRectInWindow: CGRect = textFieldView.superview?.convert(textFieldView.frame, to: window),
              let textFieldViewRectInRootSuperview: CGRect = textFieldView.superview?.convert(textFieldView.frame, to: rootController.view?.superview) else {
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        //  Getting RootViewOrigin.
        var rootViewOrigin: CGPoint = rootController.view.frame.origin

        // Maintain keyboardDistanceFromTextField
        var specialKeyboardDistanceFromTextField: CGFloat = textFieldView.keyboardDistanceFromTextField

        if let searchBar: UISearchBar = textFieldView.textFieldSearchBar() {
            specialKeyboardDistanceFromTextField = searchBar.keyboardDistanceFromTextField
        }

        let newKeyboardDistanceFromTextField: CGFloat = (specialKeyboardDistanceFromTextField == kIQUseDefaultKeyboardDistance) ? keyboardDistanceFromTextField : specialKeyboardDistanceFromTextField

        var kbSize: CGSize = keyboardInfo.frame.size

        do {
            var kbFrame: CGRect = keyboardInfo.frame

            kbFrame.origin.y -= newKeyboardDistanceFromTextField
            kbFrame.size.height += newKeyboardDistanceFromTextField

            // Calculating actual keyboard covered size respect to window, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
            let intersectRect: CGRect = kbFrame.intersection(window.frame)

            if intersectRect.isNull {
                kbSize = CGSize(width: kbFrame.size.width, height: 0)
            } else {
                kbSize = intersectRect.size
            }
        }

        let statusBarHeight: CGFloat

        let navigationBarAreaHeight: CGFloat
        if let navigationController: UINavigationController = rootController.navigationController {
            navigationBarAreaHeight = navigationController.navigationBar.frame.maxY
        } else {
#if swift(>=5.1)
            if #available(iOS 13, *) {
                statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }
#else
            statusBarHeight = UIApplication.shared.statusBarFrame.height
#endif
            navigationBarAreaHeight = statusBarHeight
        }

        let layoutAreaHeight: CGFloat = rootController.view.layoutMargins.bottom

        let isTextView: Bool
        let isNonScrollableTextView: Bool

        if let textView: UIScrollView = textFieldView as? UIScrollView,
           textFieldView.responds(to: #selector(getter: UITextView.isEditable)) {

            isTextView = true
            isNonScrollableTextView = !textView.isScrollEnabled
        } else {
            isTextView = false
            isNonScrollableTextView = false
        }

        let topLayoutGuide: CGFloat = max(navigationBarAreaHeight, layoutAreaHeight) + 5

        // Validation of textView for case where there is a tab bar at the bottom or running on iPhone X and textView is at the bottom.
        let bottomLayoutGuide: CGFloat = (isTextView && !isNonScrollableTextView) ? 0 : rootController.view.layoutMargins.bottom
        let visibleHeight: CGFloat = window.frame.height-kbSize.height

        //  Move positive = textField is hidden.
        //  Move negative = textField is showing.
        //  Calculating move position.
        var move: CGFloat

        // Special case: when the textView is not scrollable, then we'll be scrolling to the bottom part and let hide the top part above
        if isNonScrollableTextView {
            move = textFieldViewRectInWindow.maxY - visibleHeight + bottomLayoutGuide
        } else {
            move = min(textFieldViewRectInRootSuperview.minY-(topLayoutGuide), textFieldViewRectInWindow.maxY - visibleHeight + bottomLayoutGuide)
        }

        showLog("Need to move: \(move)")

        var superScrollView: UIScrollView?
        var superView: UIScrollView? = textFieldView.superviewOfClassType(UIScrollView.self) as? UIScrollView

        // Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
        while let view: UIScrollView = superView {

            if view.isScrollEnabled, !view.shouldIgnoreScrollingAdjustment {
                superScrollView = view
                break
            } else {
                //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
                superView = view.superviewOfClassType(UIScrollView.self) as? UIScrollView
            }
        }

        // If there was a lastScrollView.    //  (Bug ID: #34)
        if let lastScrollView: UIScrollView = lastScrollView {
            // If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if superScrollView == nil {

                if lastScrollView.contentInset != self.startingContentInsets {
                    showLog("Restoring contentInset to: \(startingContentInsets)")
                    keyboardInfo.animate(alongsideTransition: {

                        lastScrollView.contentInset = self.startingContentInsets
                        lastScrollView.scrollIndicatorInsets = self.startingScrollIndicatorInsets
                    })
                }

                if lastScrollView.shouldRestoreScrollViewContentOffset, !lastScrollView.contentOffset.equalTo(startingContentOffset) {
                    showLog("Restoring contentOffset to: \(startingContentOffset)")

                    let animatedContentOffset: Bool = textFieldView.superviewOfClassType(UIStackView.self, belowView: lastScrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

                    if animatedContentOffset {
                        lastScrollView.setContentOffset(startingContentOffset, animated: UIView.areAnimationsEnabled)
                    } else {
                        lastScrollView.contentOffset = startingContentOffset
                    }
                }

                startingContentInsets = UIEdgeInsets()
                startingScrollIndicatorInsets = UIEdgeInsets()
                startingContentOffset = CGPoint.zero
                self.lastScrollView = nil
            } else if superScrollView != lastScrollView {     // If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.

                if lastScrollView.contentInset != self.startingContentInsets {
                    showLog("Restoring contentInset to: \(startingContentInsets)")
                    keyboardInfo.animate(alongsideTransition: {

                        lastScrollView.contentInset = self.startingContentInsets
                        lastScrollView.scrollIndicatorInsets = self.startingScrollIndicatorInsets
                    })
                }

                if lastScrollView.shouldRestoreScrollViewContentOffset, !lastScrollView.contentOffset.equalTo(startingContentOffset) {
                    showLog("Restoring contentOffset to: \(startingContentOffset)")

                    let animatedContentOffset: Bool = textFieldView.superviewOfClassType(UIStackView.self, belowView: lastScrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

                    if animatedContentOffset {
                        lastScrollView.setContentOffset(startingContentOffset, animated: UIView.areAnimationsEnabled)
                    } else {
                        lastScrollView.contentOffset = startingContentOffset
                    }
                }

                self.lastScrollView = superScrollView
                if let scrollView: UIScrollView = superScrollView {
                    startingContentInsets = scrollView.contentInset
                    startingContentOffset = scrollView.contentOffset

                    #if swift(>=5.1)
                    if #available(iOS 11.1, *) {
                        startingScrollIndicatorInsets = scrollView.verticalScrollIndicatorInsets
                    } else {
                        startingScrollIndicatorInsets = scrollView.scrollIndicatorInsets
                    }
                    #else
                    startingScrollIndicatorInsets = scrollView.scrollIndicatorInsets
                    #endif
                }

                showLog("Saving ScrollView New contentInset: \(startingContentInsets) and contentOffset: \(startingContentOffset)")
            }
            // Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing, going ahead
        } else if let unwrappedSuperScrollView: UIScrollView = superScrollView {    // If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
            lastScrollView = unwrappedSuperScrollView
            startingContentInsets = unwrappedSuperScrollView.contentInset
            startingContentOffset = unwrappedSuperScrollView.contentOffset

            #if swift(>=5.1)
            if #available(iOS 11.1, *) {
                startingScrollIndicatorInsets = unwrappedSuperScrollView.verticalScrollIndicatorInsets
            } else {
                startingScrollIndicatorInsets = unwrappedSuperScrollView.scrollIndicatorInsets
            }
            #else
            startingScrollIndicatorInsets = unwrappedSuperScrollView.scrollIndicatorInsets
            #endif

            showLog("Saving ScrollView contentInset: \(startingContentInsets) and contentOffset: \(startingContentOffset)")
        }

        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if let lastScrollView: UIScrollView  = lastScrollView {
            // Saving
            var lastView: UIView = textFieldView
            var superScrollView: UIScrollView? = self.lastScrollView

            while let scrollView: UIScrollView = superScrollView {

                var shouldContinue: Bool = false

                if move > 0 {
                    shouldContinue = move > (-scrollView.contentOffset.y - scrollView.contentInset.top)

                } else if let tableView: UITableView = scrollView.superviewOfClassType(UITableView.self) as? UITableView {

                    shouldContinue = scrollView.contentOffset.y > 0

                    if shouldContinue,
                       let tableCell: UITableViewCell = textFieldView.superviewOfClassType(UITableViewCell.self) as? UITableViewCell,
                       let indexPath: IndexPath = tableView.indexPath(for: tableCell),
                       let previousIndexPath: IndexPath = tableView.previousIndexPath(of: indexPath) {

                        let previousCellRect: CGRect = tableView.rectForRow(at: previousIndexPath)
                        if !previousCellRect.isEmpty {
                            let previousCellRectInRootSuperview: CGRect = tableView.convert(previousCellRect, to: rootController.view.superview)

                            move = min(0, previousCellRectInRootSuperview.maxY - topLayoutGuide)
                        }
                    }
                } else if let collectionView: UICollectionView = scrollView.superviewOfClassType(UICollectionView.self) as? UICollectionView {

                    shouldContinue = scrollView.contentOffset.y > 0

                    if shouldContinue,
                       let collectionCell: UICollectionViewCell = textFieldView.superviewOfClassType(UICollectionViewCell.self) as? UICollectionViewCell,
                       let indexPath: IndexPath = collectionView.indexPath(for: collectionCell),
                       let previousIndexPath: IndexPath = collectionView.previousIndexPath(of: indexPath),
                       let attributes: UICollectionViewLayoutAttributes = collectionView.layoutAttributesForItem(at: previousIndexPath) {

                        let previousCellRect: CGRect = attributes.frame
                        if !previousCellRect.isEmpty {
                            let previousCellRectInRootSuperview: CGRect = collectionView.convert(previousCellRect, to: rootController.view.superview)

                            move = min(0, previousCellRectInRootSuperview.maxY - topLayoutGuide)
                        }
                    }
                } else {

                    if isNonScrollableTextView {
                        shouldContinue = textFieldViewRectInWindow.maxY < visibleHeight + bottomLayoutGuide

                        if shouldContinue {
                            move = min(0, textFieldViewRectInWindow.maxY - visibleHeight + bottomLayoutGuide)
                        }
                    } else {
                        shouldContinue = textFieldViewRectInRootSuperview.minY < topLayoutGuide

                        if shouldContinue {
                            move = min(0, textFieldViewRectInRootSuperview.minY - topLayoutGuide)
                        }
                    }
                }

                // Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
                if shouldContinue {

                    var tempScrollView: UIScrollView? = scrollView.superviewOfClassType(UIScrollView.self) as? UIScrollView
                    var nextScrollView: UIScrollView?
                    while let view: UIScrollView = tempScrollView {

                        if view.isScrollEnabled, !view.shouldIgnoreScrollingAdjustment {
                            nextScrollView = view
                            break
                        } else {
                            tempScrollView = view.superviewOfClassType(UIScrollView.self) as? UIScrollView
                        }
                    }

                    // Getting lastViewRect.
                    if let lastViewRect: CGRect = lastView.superview?.convert(lastView.frame, to: scrollView) {

                        // Calculating the expected Y offset from move and scrollView's contentOffset.
                        var shouldOffsetY: CGFloat = scrollView.contentOffset.y - min(scrollView.contentOffset.y, -move)

                        // Rearranging the expected Y offset according to the view.

                        if isNonScrollableTextView {
                            shouldOffsetY = min(shouldOffsetY, lastViewRect.maxY - visibleHeight + bottomLayoutGuide)
                        } else {
                            shouldOffsetY = min(shouldOffsetY, lastViewRect.minY)
                        }

                        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        // nextScrollView == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierrchy.)
                        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        // shouldOffsetY >= 0     shouldOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                        if isTextView, !isNonScrollableTextView,
                            nextScrollView == nil,
                            shouldOffsetY >= 0 {

                            // Converting Rectangle according to window bounds.
                            if let currentTextFieldViewRect: CGRect = textFieldView.superview?.convert(textFieldView.frame, to: window) {

                                // Calculating expected fix distance which needs to be managed from navigation bar
                                let expectedFixDistance: CGFloat = currentTextFieldViewRect.minY - topLayoutGuide

                                // Now if expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance) is lower than current shouldOffsetY, which means we're in a position where navigationBar up and hide, then reducing shouldOffsetY with expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance)
                                shouldOffsetY = min(shouldOffsetY, scrollView.contentOffset.y + expectedFixDistance)

                                // Setting move to 0 because now we don't want to move any view anymore (All will be managed by our contentInset logic.
                                move = 0
                            } else {
                                // Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                                move -= (shouldOffsetY-scrollView.contentOffset.y)
                            }
                        } else {
                            // Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                            move -= (shouldOffsetY-scrollView.contentOffset.y)
                        }

                        let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: shouldOffsetY)

                        if !scrollView.contentOffset.equalTo(newContentOffset) {

                            showLog("old contentOffset: \(scrollView.contentOffset) new contentOffset: \(newContentOffset)")
                            self.showLog("Remaining Move: \(move)")

                            // Getting problem while using `setContentOffset:animated:`, So I used animation API.
                            keyboardInfo.animate(alongsideTransition: {

                                let animatedContentOffset: Bool = textFieldView.superviewOfClassType(UIStackView.self, belowView: scrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

                                if animatedContentOffset {
                                    scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                                } else {
                                    scrollView.contentOffset = newContentOffset
                                }
                            }, completion: {

                                if scrollView is UITableView || scrollView is UICollectionView {
                                    // This will update the next/previous states
                                    self.addToolbarIfRequired()
                                }
                            })
                        }
                    }

                    // Getting next lastView & superScrollView.
                    lastView = scrollView
                    superScrollView = nextScrollView
                } else {
                    move = 0
                    break
                }
            }

            // Updating contentInset
            if let lastScrollViewRect: CGRect = lastScrollView.superview?.convert(lastScrollView.frame, to: window),
                !lastScrollView.shouldIgnoreContentInsetAdjustment {

                var bottomInset: CGFloat = (kbSize.height)-(window.frame.height-lastScrollViewRect.maxY)
                var bottomScrollIndicatorInset: CGFloat = bottomInset - newKeyboardDistanceFromTextField

                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                bottomInset = max(startingContentInsets.bottom, bottomInset)
                bottomScrollIndicatorInset = max(startingScrollIndicatorInsets.bottom, bottomScrollIndicatorInset)

                bottomInset -= lastScrollView.safeAreaInsets.bottom
                bottomScrollIndicatorInset -= lastScrollView.safeAreaInsets.bottom

                var movedInsets: UIEdgeInsets = lastScrollView.contentInset
                movedInsets.bottom = bottomInset

                if lastScrollView.contentInset != movedInsets {
                    showLog("old ContentInset: \(lastScrollView.contentInset) new ContentInset: \(movedInsets)")

                    keyboardInfo.animate(alongsideTransition: {
                        lastScrollView.contentInset = movedInsets

                        var newScrollIndicatorInset: UIEdgeInsets

                        #if swift(>=5.1)
                        if #available(iOS 11.1, *) {
                            newScrollIndicatorInset = lastScrollView.verticalScrollIndicatorInsets
                        } else {
                            newScrollIndicatorInset = lastScrollView.scrollIndicatorInsets
                        }
                        #else
                        newScrollIndicatorInset = lastScrollView.scrollIndicatorInsets
                        #endif

                        newScrollIndicatorInset.bottom = bottomScrollIndicatorInset
                        lastScrollView.scrollIndicatorInsets = newScrollIndicatorInset
                    })
                }
            }
        }
        // Going ahead. No else if.

        // Special case for UITextView(Readjusting textView.contentInset when textView hight is too big to fit on screen)
        // _lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        if let textView: UIScrollView = textFieldView as? UIScrollView,
           textView.isScrollEnabled,
           textFieldView.responds(to: #selector(getter: UITextView.isEditable)) {

            let keyboardYPosition: CGFloat = window.frame.height - (kbSize.height-newKeyboardDistanceFromTextField)
            var rootSuperViewFrameInWindow: CGRect = window.frame
            if let rootSuperview: UIView = rootController.view.superview {
                rootSuperViewFrameInWindow = rootSuperview.convert(rootSuperview.bounds, to: window)
            }

            let keyboardOverlapping: CGFloat = rootSuperViewFrameInWindow.maxY - keyboardYPosition

            let textViewHeight: CGFloat = min(textView.frame.height, rootSuperViewFrameInWindow.height-topLayoutGuide-keyboardOverlapping)

            if textView.frame.size.height-textView.contentInset.bottom>textViewHeight {
                // _isTextViewContentInsetChanged,  If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                if !self.isTextViewContentInsetChanged {
                    self.startingTextViewContentInsets = textView.contentInset

                    #if swift(>=5.1)
                    if #available(iOS 11.1, *) {
                        self.startingTextViewScrollIndicatorInsets = textView.verticalScrollIndicatorInsets
                    } else {
                        self.startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets
                    }
                    #else
                    self.startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets
                    #endif
                }

                self.isTextViewContentInsetChanged = true

                var newContentInset: UIEdgeInsets = textView.contentInset
                newContentInset.bottom = textView.frame.size.height-textViewHeight
                newContentInset.bottom -= textView.safeAreaInsets.bottom

                if textView.contentInset != newContentInset {
                    self.showLog("\(textFieldView) Old UITextView.contentInset: \(textView.contentInset) New UITextView.contentInset: \(newContentInset)")

                    keyboardInfo.animate(alongsideTransition: {

                        textView.contentInset = newContentInset
                        textView.scrollIndicatorInsets = newContentInset
                    })
                }
            }
        }

        // +Positive or zero.
        if move >= 0 {

            rootViewOrigin.y = max(rootViewOrigin.y - move, min(0, -(kbSize.height-newKeyboardDistanceFromTextField)))

            if !rootController.view.frame.origin.equalTo(rootViewOrigin) {
                showLog("Moving Upward")

                keyboardInfo.animate(alongsideTransition: {

                    var rect: CGRect = rootController.view.frame
                    rect.origin = rootViewOrigin
                    rootController.view.frame = rect

                    // Animating content if needed (Bug ID: #204)
                    if self.layoutIfNeededOnUpdate {
                        // Animating content (Bug ID: #160)
                        rootController.view.setNeedsLayout()
                        rootController.view.layoutIfNeeded()
                    }

                    self.showLog("Set \(rootController) origin to: \(rootViewOrigin)")
                })
            }

            movedDistance = (topViewBeginOrigin.y-rootViewOrigin.y)
        } else {  //  -Negative
            let disturbDistance: CGFloat = rootViewOrigin.y-topViewBeginOrigin.y

            //  disturbDistance Negative = frame disturbed.
            //  disturbDistance positive = frame not disturbed.
            if disturbDistance <= 0 {

                rootViewOrigin.y -= max(move, disturbDistance)

                if !rootController.view.frame.origin.equalTo(rootViewOrigin) {
                    showLog("Moving Downward")
                    //  Setting adjusted rootViewRect
                    //  Setting adjusted rootViewRect

                    keyboardInfo.animate(alongsideTransition: {

                        var rect: CGRect = rootController.view.frame
                        rect.origin = rootViewOrigin
                        rootController.view.frame = rect

                        // Animating content if needed (Bug ID: #204)
                        if self.layoutIfNeededOnUpdate {
                            // Animating content (Bug ID: #160)
                            rootController.view.setNeedsLayout()
                            rootController.view.layoutIfNeeded()
                        }

                        self.showLog("Set \(rootController) origin to: \(rootViewOrigin)")
                    })
                }

                movedDistance = (topViewBeginOrigin.y-rootViewOrigin.y)
            }
        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    internal func restorePosition() {

        hasPendingAdjustRequest = false

        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        guard !topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid),
              let rootViewController: UIViewController = rootViewController else {
            return
        }

        if !rootViewController.view.frame.origin.equalTo(self.topViewBeginOrigin) {
            // Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
            keyboardInfo.animate(alongsideTransition: {

                self.showLog("Restoring \(rootViewController) origin to: \(self.topViewBeginOrigin)")

                // Setting it's new frame
                var rect: CGRect = rootViewController.view.frame
                rect.origin = self.topViewBeginOrigin
                rootViewController.view.frame = rect

                // Animating content if needed (Bug ID: #204)
                if self.layoutIfNeededOnUpdate {
                    // Animating content (Bug ID: #160)
                    rootViewController.view.setNeedsLayout()
                    rootViewController.view.layoutIfNeeded()
                }
            })
        }

        self.movedDistance = 0

        if rootViewController.navigationController?.interactivePopGestureRecognizer?.state == .began {
            self.rootViewControllerWhilePopGestureRecognizerActive = rootViewController
            self.topViewBeginOriginWhilePopGestureRecognizerActive = self.topViewBeginOrigin
        }

        self.rootViewController = nil
    }
}
