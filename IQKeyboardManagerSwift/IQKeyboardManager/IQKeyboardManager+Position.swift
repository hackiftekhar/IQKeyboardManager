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
        static var lastScrollViewConfiguration: Int = 0
        static var startingTextViewConfiguration: Int = 0
        static var activeConfiguration: Int = 0
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
    internal var lastScrollViewConfiguration: IQScrollViewConfiguration? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lastScrollViewConfiguration) as? IQScrollViewConfiguration
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.lastScrollViewConfiguration, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** used to adjust contentInset of UITextView. */
    internal var startingTextViewConfiguration: IQScrollViewConfiguration? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startingTextViewConfiguration) as? IQScrollViewConfiguration
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startingTextViewConfiguration, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal func addActiveConfiguratinObserver() {
        activeConfiguration.registerChange(identifier: UUID().uuidString, changeHandler: { event, _, _ in
            switch event {
            case .show:
                self.handleKeyboardTextFieldViewVisible()
            case .change:
                self.handleKeyboardTextFieldViewChanged()
            case .hide:
                self.handleKeyboardTextFieldViewHide()
            }
        })
    }

    internal func optimizedAdjustPosition() {
//        OperationQueue.main.addOperation {
            self.adjustPosition()
//        }
    }

    /* Adjusting RootViewController's frame according to interface orientation. */
    private func adjustPosition() {

        //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
        guard let textFieldView: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
              let superview: UIView = textFieldView.superview,
              let rootControllerConfiguration = activeConfiguration.rootControllerConfiguration,
              let window: UIWindow = keyWindow() else {
            return
        }

        let rootController: UIViewController = rootControllerConfiguration.rootController
        let textFieldViewRectInWindow: CGRect = superview.convert(textFieldView.frame, to: window)
        let textFieldViewRectInRootSuperview: CGRect = superview.convert(textFieldView.frame, to: rootController.view.superview)

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        //  Getting RootViewOrigin.
        var rootViewOrigin: CGPoint = rootController.view.frame.origin

        // Maintain keyboardDistanceFromTextField
        var specialKeyboardDistanceFromTextField: CGFloat = textFieldView.iq.distanceFromKeyboard

        if let searchBar: UIView = textFieldView.iq.textFieldSearchBar() {
            specialKeyboardDistanceFromTextField = searchBar.iq.distanceFromKeyboard
        }

        let newKeyboardDistanceFromTextField: CGFloat = (specialKeyboardDistanceFromTextField == UIView.defaultKeyboardDistance) ? keyboardDistanceFromTextField : specialKeyboardDistanceFromTextField

        var kbSize: CGSize =  activeConfiguration.keyboardInfo.frame.size

        do {
            var kbFrame: CGRect =  activeConfiguration.keyboardInfo.frame

            kbFrame.origin.y -= newKeyboardDistanceFromTextField
            kbFrame.size.height += newKeyboardDistanceFromTextField

            kbFrame.origin.y -= rootControllerConfiguration.beginSafeAreaInsets.bottom
            kbFrame.size.height += rootControllerConfiguration.beginSafeAreaInsets.bottom

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

        let topLayoutGuide: CGFloat = max(navigationBarAreaHeight, rootController.view.layoutMargins.top) + 5

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

        move = CGFloat(Int(move))
        showLog("Need to move: \(move)")

        var superScrollView: UIScrollView?
        var superView: UIScrollView? = textFieldView.iq.superviewOf(type: UIScrollView.self) as? UIScrollView

        // Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
        while let view: UIScrollView = superView {

            if view.isScrollEnabled, !view.iq.ignoreScrollingAdjustment {
                superScrollView = view
                break
            } else {
                //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
                superView = view.iq.superviewOf(type: UIScrollView.self) as? UIScrollView
            }
        }

        // If there was a lastScrollView.    //  (Bug ID: #34)
        if let lastScrollViewConfiguration: IQScrollViewConfiguration = lastScrollViewConfiguration {
            // If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if superScrollView == nil {

                if lastScrollViewConfiguration.hasChanged {
                    if lastScrollViewConfiguration.scrollView.contentInset != lastScrollViewConfiguration.startingContentInsets {
                        showLog("Restoring contentInset to: \(lastScrollViewConfiguration.startingContentInsets)")
                    }

                    if lastScrollViewConfiguration.scrollView.iq.restoreContentOffset,
                       !lastScrollViewConfiguration.scrollView.contentOffset.equalTo(lastScrollViewConfiguration.startingContentOffset) {
                        showLog("Restoring contentOffset to: \(lastScrollViewConfiguration.startingContentOffset)")
                    }

                    activeConfiguration.animate(alongsideTransition: {
                        lastScrollViewConfiguration.restore(for: textFieldView)
                    })
                }

                self.lastScrollViewConfiguration = nil
            } else if superScrollView != lastScrollViewConfiguration.scrollView {     // If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.

                if lastScrollViewConfiguration.hasChanged {
                    if lastScrollViewConfiguration.scrollView.contentInset != lastScrollViewConfiguration.startingContentInsets {
                        showLog("Restoring contentInset to: \(lastScrollViewConfiguration.startingContentInsets)")
                    }

                    if lastScrollViewConfiguration.scrollView.iq.restoreContentOffset,
                       !lastScrollViewConfiguration.scrollView.contentOffset.equalTo(lastScrollViewConfiguration.startingContentOffset) {
                        showLog("Restoring contentOffset to: \(lastScrollViewConfiguration.startingContentOffset)")
                    }

                    activeConfiguration.animate(alongsideTransition: {
                        lastScrollViewConfiguration.restore(for: textFieldView)
                    })
                }

                if let superScrollView = superScrollView {
                    let configuration = IQScrollViewConfiguration(scrollView: superScrollView, canRestoreContentOffset: true)
                    self.lastScrollViewConfiguration = configuration
                    showLog("Saving ScrollView New contentInset: \(configuration.startingContentInsets) and contentOffset: \(configuration.startingContentOffset)")
                } else {
                    self.lastScrollViewConfiguration = nil
                }
            }
            // Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing, going ahead
        } else if let superScrollView: UIScrollView = superScrollView {    // If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.

            let configuration = IQScrollViewConfiguration(scrollView: superScrollView, canRestoreContentOffset: true)
            self.lastScrollViewConfiguration = configuration
            showLog("Saving ScrollView New contentInset: \(configuration.startingContentInsets) and contentOffset: \(configuration.startingContentOffset)")
        }

        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if let lastScrollViewConfiguration: IQScrollViewConfiguration  = lastScrollViewConfiguration {
            // Saving
            var lastView: UIView = textFieldView
            var superScrollView: UIScrollView? = lastScrollViewConfiguration.scrollView

            while let scrollView: UIScrollView = superScrollView {

                var isContinue: Bool = false

                if move > 0 {
                    isContinue = move > (-scrollView.contentOffset.y - scrollView.contentInset.top)

                } else if let tableView: UITableView = scrollView.iq.superviewOf(type: UITableView.self) as? UITableView {

                    isContinue = scrollView.contentOffset.y > 0

                    if isContinue,
                       let tableCell: UITableViewCell = textFieldView.iq.superviewOf(type: UITableViewCell.self) as? UITableViewCell,
                       let indexPath: IndexPath = tableView.indexPath(for: tableCell),
                       let previousIndexPath: IndexPath = tableView.previousIndexPath(of: indexPath) {

                        let previousCellRect: CGRect = tableView.rectForRow(at: previousIndexPath)
                        if !previousCellRect.isEmpty {
                            let previousCellRectInRootSuperview: CGRect = tableView.convert(previousCellRect, to: rootController.view.superview)

                            move = min(0, previousCellRectInRootSuperview.maxY - topLayoutGuide)
                        }
                    }
                } else if let collectionView: UICollectionView = scrollView.iq.superviewOf(type: UICollectionView.self) as? UICollectionView {

                    isContinue = scrollView.contentOffset.y > 0

                    if isContinue,
                       let collectionCell: UICollectionViewCell = textFieldView.iq.superviewOf(type: UICollectionViewCell.self) as? UICollectionViewCell,
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
                        isContinue = textFieldViewRectInWindow.maxY < visibleHeight + bottomLayoutGuide

                        if isContinue {
                            move = min(0, textFieldViewRectInWindow.maxY - visibleHeight + bottomLayoutGuide)
                        }
                    } else {
                        isContinue = textFieldViewRectInRootSuperview.minY < topLayoutGuide

                        if isContinue {
                            move = min(0, textFieldViewRectInRootSuperview.minY - topLayoutGuide)
                        }
                    }
                }

                // Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
                if isContinue {

                    var tempScrollView: UIScrollView? = scrollView.iq.superviewOf(type: UIScrollView.self) as? UIScrollView
                    var nextScrollView: UIScrollView?
                    while let view: UIScrollView = tempScrollView {

                        if view.isScrollEnabled, !view.iq.ignoreScrollingAdjustment {
                            nextScrollView = view
                            break
                        } else {
                            tempScrollView = view.iq.superviewOf(type: UIScrollView.self) as? UIScrollView
                        }
                    }

                    // Getting lastViewRect.
                    if let lastViewRect: CGRect = lastView.superview?.convert(lastView.frame, to: scrollView) {

                        // Calculating the expected Y offset from move and scrollView's contentOffset.
                        var suggestedOffsetY: CGFloat = scrollView.contentOffset.y - min(scrollView.contentOffset.y, -move)

                        // Rearranging the expected Y offset according to the view.

                        if isNonScrollableTextView {
                            suggestedOffsetY = min(suggestedOffsetY, lastViewRect.maxY - visibleHeight + bottomLayoutGuide)
                        } else {
                            suggestedOffsetY = min(suggestedOffsetY, lastViewRect.minY)
                        }

                        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        // nextScrollView == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierrchy.)
                        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        // suggestedOffsetY >= 0     suggestedOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                        if isTextView, !isNonScrollableTextView,
                            nextScrollView == nil,
                            suggestedOffsetY >= 0 {

                            // Converting Rectangle according to window bounds.
                            if let currentTextFieldViewRect: CGRect = textFieldView.superview?.convert(textFieldView.frame, to: window) {

                                // Calculating expected fix distance which needs to be managed from navigation bar
                                let expectedFixDistance: CGFloat = currentTextFieldViewRect.minY - topLayoutGuide

                                // Now if expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance) is lower than current suggestedOffsetY, which means we're in a position where navigationBar up and hide, then reducing suggestedOffsetY with expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance)
                                suggestedOffsetY = min(suggestedOffsetY, scrollView.contentOffset.y + expectedFixDistance)

                                // Setting move to 0 because now we don't want to move any view anymore (All will be managed by our contentInset logic.
                                move = 0
                            } else {
                                // Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to suggestedOffsetY.
                                move -= (suggestedOffsetY-scrollView.contentOffset.y)
                            }
                        } else {
                            // Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to suggestedOffsetY.
                            move -= (suggestedOffsetY-scrollView.contentOffset.y)
                        }

                        let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: suggestedOffsetY)

                        if !scrollView.contentOffset.equalTo(newContentOffset) {

                            showLog("old contentOffset: \(scrollView.contentOffset) new contentOffset: \(newContentOffset)")
                            self.showLog("Remaining Move: \(move)")

                            // Getting problem while using `setContentOffset:animated:`, So I used animation API.
                            activeConfiguration.animate(alongsideTransition: {

                                let animatedContentOffset: Bool = textFieldView.iq.superviewOf(type: UIStackView.self, belowView: scrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

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
            let lastScrollView = lastScrollViewConfiguration.scrollView
            if let lastScrollViewRect: CGRect = lastScrollView.superview?.convert(lastScrollView.frame, to: window),
                !lastScrollView.iq.ignoreContentInsetAdjustment {

                var bottomInset: CGFloat = (kbSize.height)-(window.frame.height-lastScrollViewRect.maxY)
                var bottomScrollIndicatorInset: CGFloat = bottomInset - newKeyboardDistanceFromTextField

                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                bottomInset = max(lastScrollViewConfiguration.startingContentInsets.bottom, bottomInset)
                bottomScrollIndicatorInset = max(lastScrollViewConfiguration.startingScrollIndicatorInsets.bottom, bottomScrollIndicatorInset)

                bottomInset -= lastScrollView.safeAreaInsets.bottom
                bottomScrollIndicatorInset -= lastScrollView.safeAreaInsets.bottom

                var movedInsets: UIEdgeInsets = lastScrollView.contentInset
                movedInsets.bottom = bottomInset

                if lastScrollView.contentInset != movedInsets {
                    showLog("old ContentInset: \(lastScrollView.contentInset) new ContentInset: \(movedInsets)")

                    activeConfiguration.animate(alongsideTransition: {
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
                // If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                if startingTextViewConfiguration == nil {
                    startingTextViewConfiguration = IQScrollViewConfiguration(scrollView: textView, canRestoreContentOffset: false)
                }

                var newContentInset: UIEdgeInsets = textView.contentInset
                newContentInset.bottom = textView.frame.size.height-textViewHeight
                newContentInset.bottom -= textView.safeAreaInsets.bottom

                if textView.contentInset != newContentInset {
                    self.showLog("\(textFieldView) Old UITextView.contentInset: \(textView.contentInset) New UITextView.contentInset: \(newContentInset)")

                    activeConfiguration.animate(alongsideTransition: {

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

                activeConfiguration.animate(alongsideTransition: {

                    var rect: CGRect = rootController.view.frame
                    rect.origin = rootViewOrigin
                    rootController.view.frame = rect

                    // Animating content if needed (Bug ID: #204)
                    if self.layoutIfNeededOnUpdate {
                        // Animating content (Bug ID: #160)
                        rootController.view.setNeedsLayout()
                        rootController.view.layoutIfNeeded()
                    }

                    let classNameString: String = "\(type(of: rootController.self))"
                    self.showLog("Set \(classNameString) origin to: \(rootViewOrigin)")
                })
            }

            movedDistance = (rootControllerConfiguration.beginOrigin.y-rootViewOrigin.y)
        } else {  //  -Negative
            let disturbDistance: CGFloat = rootViewOrigin.y-rootControllerConfiguration.beginOrigin.y

            //  disturbDistance Negative = frame disturbed.
            //  disturbDistance positive = frame not disturbed.
            if disturbDistance <= 0 {

                rootViewOrigin.y -= max(move, disturbDistance)

                if !rootController.view.frame.origin.equalTo(rootViewOrigin) {
                    showLog("Moving Downward")
                    //  Setting adjusted rootViewRect
                    //  Setting adjusted rootViewRect

                    activeConfiguration.animate(alongsideTransition: {

                        var rect: CGRect = rootController.view.frame
                        rect.origin = rootViewOrigin
                        rootController.view.frame = rect

                        // Animating content if needed (Bug ID: #204)
                        if self.layoutIfNeededOnUpdate {
                            // Animating content (Bug ID: #160)
                            rootController.view.setNeedsLayout()
                            rootController.view.layoutIfNeeded()
                        }

                        let classNameString: String = "\(type(of: rootController.self))"
                        self.showLog("Set \(classNameString) origin to: \(rootViewOrigin)")
                    })
                }

                movedDistance = (rootControllerConfiguration.beginOrigin.y-rootViewOrigin.y)
            }
        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    internal func restorePosition() {

        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        guard let configuration: IQRootControllerConfiguration = activeConfiguration.rootControllerConfiguration else {
            return
        }

        activeConfiguration.animate(alongsideTransition: {
            if configuration.hasChanged {
                self.showLog("Restoring \(configuration.rootController) origin to: \(configuration.beginOrigin)")
            }
            configuration.restore()

            // Animating content if needed (Bug ID: #204)
            if self.layoutIfNeededOnUpdate {
                // Animating content (Bug ID: #160)
                configuration.rootController.view.setNeedsLayout()
                configuration.rootController.view.layoutIfNeeded()
            }
        })

        // Restoring the contentOffset of the lastScrollView
        if let textFieldView: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
           let lastScrollViewConfiguration: IQScrollViewConfiguration = lastScrollViewConfiguration {

            activeConfiguration.animate(alongsideTransition: {

                if lastScrollViewConfiguration.hasChanged {
                    if lastScrollViewConfiguration.scrollView.contentInset != lastScrollViewConfiguration.startingContentInsets {
                        self.showLog("Restoring contentInset to: \(lastScrollViewConfiguration.startingContentInsets)")
                    }

                    if lastScrollViewConfiguration.scrollView.iq.restoreContentOffset,
                       !lastScrollViewConfiguration.scrollView.contentOffset.equalTo(lastScrollViewConfiguration.startingContentOffset) {
                        self.showLog("Restoring contentOffset to: \(lastScrollViewConfiguration.startingContentOffset)")
                    }

                    lastScrollViewConfiguration.restore(for: textFieldView)
                }

                // TODO: restore scrollView state
                // This is temporary solution. Have to implement the save and restore scrollView state
                var superScrollView: UIScrollView? = lastScrollViewConfiguration.scrollView

                while let scrollView: UIScrollView = superScrollView {

                    let contentSize: CGSize = CGSize(width: max(scrollView.contentSize.width, scrollView.frame.width), height: max(scrollView.contentSize.height, scrollView.frame.height))

                    let minimumY: CGFloat = contentSize.height - scrollView.frame.height

                    if minimumY < scrollView.contentOffset.y {

                        let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: minimumY)
                        if !scrollView.contentOffset.equalTo(newContentOffset) {

                            let animatedContentOffset: Bool = textFieldView.iq.superviewOf(type: UIStackView.self, belowView: scrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

                            if animatedContentOffset {
                                scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                            } else {
                                scrollView.contentOffset = newContentOffset
                            }

                            self.showLog("Restoring contentOffset to: \(newContentOffset)")
                        }
                    }

                    superScrollView = scrollView.iq.superviewOf(type: UIScrollView.self) as? UIScrollView
                }
            })
        }

        self.movedDistance = 0
    }
}
