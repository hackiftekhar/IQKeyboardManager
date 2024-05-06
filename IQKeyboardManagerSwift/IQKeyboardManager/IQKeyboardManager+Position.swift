//
//  IQKeyboardManager+Position.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
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

// swiftlint:disable file_length
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    @MainActor
    private struct AssociatedKeys {
        static var movedDistance: Int = 0
        static var movedDistanceChanged: Int = 0
        static var lastScrollViewConfiguration: Int = 0
        static var startingTextViewConfiguration: Int = 0
        static var activeConfiguration: Int = 0
    }

    /**
     moved distance to the top used to maintain distance between keyboard and textField.
     Most of the time this will be a positive value.
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
            objc_setAssociatedObject(self, &AssociatedKeys.movedDistanceChanged,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            movedDistanceChanged?(movedDistance)
        }
    }

    /** Variable to save lastScrollView that was scrolled. */
    internal var lastScrollViewConfiguration: IQScrollViewConfiguration? {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedKeys.lastScrollViewConfiguration) as? IQScrollViewConfiguration
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.lastScrollViewConfiguration,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** used to adjust contentInset of UITextView. */
    internal var startingTextViewConfiguration: IQScrollViewConfiguration? {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedKeys.startingTextViewConfiguration) as? IQScrollViewConfiguration
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startingTextViewConfiguration,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal func addActiveConfigurationObserver() {
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

    @objc internal func applicationDidBecomeActive(_ notification: Notification) {

        guard privateIsEnabled(),
              activeConfiguration.keyboardInfo.keyboardShowing,
              activeConfiguration.isReady else {
            return
        }
        adjustPosition()
    }

    /* Adjusting RootViewController's frame according to interface orientation. */
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    internal func adjustPosition() {

        //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
        guard UIApplication.shared.applicationState == .active,
              let textFieldView: UIView = activeConfiguration.textFieldViewInfo?.textFieldView,
              let superview: UIView = textFieldView.superview,
              let rootConfiguration = activeConfiguration.rootControllerConfiguration,
              let window: UIWindow = rootConfiguration.rootController.view.window else {
            return
        }

        showLog(">>>>> \(#function) started >>>>>", indentation: 1)
        let startTime: CFTimeInterval = CACurrentMediaTime()

        let rootController: UIViewController = rootConfiguration.rootController
        let textFieldViewRectInWindow: CGRect = superview.convert(textFieldView.frame, to: window)
        let textFieldViewRectInRootSuperview: CGRect = superview.convert(textFieldView.frame,
                                                                         to: rootController.view.superview)

        //  Getting RootViewOrigin.
        var rootViewOrigin: CGPoint = rootController.view.frame.origin

        let keyboardDistance: CGFloat

        do {
            // Maintain keyboardDistanceFromTextField
            let specialKeyboardDistanceFromTextField: CGFloat

            if let searchBar: UIView = textFieldView.iq.textFieldSearchBar() {
                specialKeyboardDistanceFromTextField = searchBar.iq.distanceFromKeyboard
            } else {
                specialKeyboardDistanceFromTextField = textFieldView.iq.distanceFromKeyboard
            }

            if specialKeyboardDistanceFromTextField == UIView.defaultKeyboardDistance {
                keyboardDistance = keyboardDistanceFromTextField
            } else {
                keyboardDistance = specialKeyboardDistanceFromTextField
            }
        }

        let kbSize: CGSize
        let originalKbSize: CGSize = activeConfiguration.keyboardInfo.frame.size

        do {
            var kbFrame: CGRect = activeConfiguration.keyboardInfo.frame

            kbFrame.origin.y -= keyboardDistance
            kbFrame.size.height += keyboardDistance

            kbFrame.origin.y -= rootConfiguration.beginSafeAreaInsets.bottom
            kbFrame.size.height += rootConfiguration.beginSafeAreaInsets.bottom

            // (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
            // Calculating actual keyboard covered size respect to window,
            // keyboard frame may be different when hardware keyboard is attached
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
            statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            navigationBarAreaHeight = statusBarHeight
        }

        let isScrollableTextView: Bool

        if let textView: UIScrollView = textFieldView as? UIScrollView,
           textFieldView.responds(to: #selector(getter: UITextView.isEditable)) {
            isScrollableTextView = textView.isScrollEnabled
        } else {
            isScrollableTextView = false
        }

        let directionalLayoutMargin: NSDirectionalEdgeInsets = rootController.view.directionalLayoutMargins
        let topLayoutGuide: CGFloat = CGFloat.maximum(navigationBarAreaHeight, directionalLayoutMargin.top)

        // Validation of textView for case where there is a tab bar
        // at the bottom or running on iPhone X and textView is at the bottom.
        let bottomLayoutGuide: CGFloat = isScrollableTextView ? 0 : directionalLayoutMargin.bottom

        //  Move positive = textField is hidden.
        //  Move negative = textField is showing.
        //  Calculating move position.
        var moveUp: CGFloat

        do {
            let visibleHeight: CGFloat = window.frame.height-kbSize.height

            let topMovement: CGFloat = textFieldViewRectInRootSuperview.minY-topLayoutGuide
            let bottomMovement: CGFloat = textFieldViewRectInWindow.maxY - visibleHeight + bottomLayoutGuide
            moveUp = CGFloat.minimum(topMovement, bottomMovement)
            moveUp = CGFloat(Int(moveUp))
        }

        showLog("Need to move: \(moveUp), will be moving \(moveUp < 0 ? "down" : "up")")

        var superScrollView: UIScrollView?
        var superView: UIScrollView? = textFieldView.iq.superviewOf(type: UIScrollView.self)

        // Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
        while let view: UIScrollView = superView {

            if view.isScrollEnabled, !view.iq.ignoreScrollingAdjustment {
                superScrollView = view
                break
            } else {
                //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
                superView = view.iq.superviewOf(type: UIScrollView.self)
            }
        }

        // If there was a lastScrollView.    //  (Bug ID: #34)
        if let lastConfiguration: IQScrollViewConfiguration = lastScrollViewConfiguration {
            // If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if superScrollView == nil {

                if lastConfiguration.hasChanged {
                    if lastConfiguration.scrollView.contentInset != lastConfiguration.startingContentInset {
                        showLog("Restoring contentInset to: \(lastConfiguration.startingContentInset)")
                    }

                    if lastConfiguration.scrollView.iq.restoreContentOffset,
                       !lastConfiguration.scrollView.contentOffset.equalTo(lastConfiguration.startingContentOffset) {
                        showLog("Restoring contentOffset to: \(lastConfiguration.startingContentOffset)")
                    }

                    activeConfiguration.animate(alongsideTransition: {
                        lastConfiguration.restore(for: textFieldView)
                    })
                }

                self.lastScrollViewConfiguration = nil
            } else if superScrollView != lastConfiguration.scrollView {
                // If both scrollView's are different,
                // then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
                if lastConfiguration.hasChanged {
                    if lastConfiguration.scrollView.contentInset != lastConfiguration.startingContentInset {
                        showLog("Restoring contentInset to: \(lastConfiguration.startingContentInset)")
                    }

                    if lastConfiguration.scrollView.iq.restoreContentOffset,
                       !lastConfiguration.scrollView.contentOffset.equalTo(lastConfiguration.startingContentOffset) {
                        showLog("Restoring contentOffset to: \(lastConfiguration.startingContentOffset)")
                    }

                    activeConfiguration.animate(alongsideTransition: {
                        lastConfiguration.restore(for: textFieldView)
                    })
                }

                if let superScrollView = superScrollView {
                    let configuration = IQScrollViewConfiguration(scrollView: superScrollView,
                                                                  canRestoreContentOffset: true)
                    self.lastScrollViewConfiguration = configuration
                    showLog("""
                            Saving ScrollView New contentInset: \(configuration.startingContentInset)
                            and contentOffset: \(configuration.startingContentOffset)
                            """)
                } else {
                    self.lastScrollViewConfiguration = nil
                }
            }
            // Else the case where superScrollView == lastScrollView means we are on same scrollView
            // after switching to different textField. So doing nothing, going ahead
        } else if let superScrollView: UIScrollView = superScrollView {
            // If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.

            let configuration = IQScrollViewConfiguration(scrollView: superScrollView, canRestoreContentOffset: true)
            self.lastScrollViewConfiguration = configuration
            showLog("""
                    Saving ScrollView New contentInset: \(configuration.startingContentInset)
                    and contentOffset: \(configuration.startingContentOffset)
                    """)
        }

        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if let lastScrollViewConfiguration: IQScrollViewConfiguration  = lastScrollViewConfiguration {
            // Saving
            var lastView: UIView = textFieldView
            var superScrollView: UIScrollView? = lastScrollViewConfiguration.scrollView

            while let scrollView: UIScrollView = superScrollView {

                var isContinue: Bool = false

                if moveUp > 0 {
                    isContinue = moveUp > (-scrollView.contentOffset.y - scrollView.contentInset.top)

                } else if let tableView: UITableView = scrollView.iq.superviewOf(type: UITableView.self) {
                    // Special treatment for UITableView due to their cell reusing logic

                    isContinue = scrollView.contentOffset.y > 0

                    if isContinue,
                       let tableCell: UITableViewCell = textFieldView.iq.superviewOf(type: UITableViewCell.self),
                       let indexPath: IndexPath = tableView.indexPath(for: tableCell),
                       let previousIndexPath: IndexPath = tableView.previousIndexPath(of: indexPath) {

                        let previousCellRect: CGRect = tableView.rectForRow(at: previousIndexPath)
                        if !previousCellRect.isEmpty {
                            let superview: UIView? = rootController.view.superview
                            let previousCellRectInRootSuperview: CGRect = tableView.convert(previousCellRect,
                                                                                            to: superview)

                            moveUp = CGFloat.minimum(0, previousCellRectInRootSuperview.maxY - topLayoutGuide)
                        }
                    }
                } else if let collectionView = scrollView.iq.superviewOf(type: UICollectionView.self) {
                    // Special treatment for UICollectionView due to their cell reusing logic

                    isContinue = scrollView.contentOffset.y > 0

                    if isContinue,
                       let collectionCell = textFieldView.iq.superviewOf(type: UICollectionViewCell.self),
                       let indexPath: IndexPath = collectionView.indexPath(for: collectionCell),
                       let previousIndexPath: IndexPath = collectionView.previousIndexPath(of: indexPath),
                       let attributes = collectionView.layoutAttributesForItem(at: previousIndexPath) {

                        let previousCellRect: CGRect = attributes.frame
                        if !previousCellRect.isEmpty {
                            let superview: UIView? = rootController.view.superview
                            let previousCellRectInRootSuperview: CGRect = collectionView.convert(previousCellRect,
                                                                                                 to: superview)

                            moveUp = CGFloat.minimum(0, previousCellRectInRootSuperview.maxY - topLayoutGuide)
                        }
                    }
                } else {
                    isContinue = textFieldViewRectInRootSuperview.minY < topLayoutGuide

                    if isContinue {
                        moveUp = CGFloat.minimum(0, textFieldViewRectInRootSuperview.minY - topLayoutGuide)
                    }
                }

                // Looping in upper hierarchy until we don't found any scrollView then
                // in it's upper hierarchy till UIWindow object.
                if isContinue {

                    var tempScrollView: UIScrollView? = scrollView.iq.superviewOf(type: UIScrollView.self)
                    var nextScrollView: UIScrollView?
                    while let view: UIScrollView = tempScrollView {

                        if view.isScrollEnabled, !view.iq.ignoreScrollingAdjustment {
                            nextScrollView = view
                            break
                        } else {
                            tempScrollView = view.iq.superviewOf(type: UIScrollView.self)
                        }
                    }

                    // Getting lastViewRect.
                    if let lastViewRect: CGRect = lastView.superview?.convert(lastView.frame, to: scrollView) {

                        // Calculating the expected Y offset from move and scrollView's contentOffset.
                        let minimumMovement: CGFloat = CGFloat.minimum(scrollView.contentOffset.y, -moveUp)
                        var suggestedOffsetY: CGFloat = scrollView.contentOffset.y - minimumMovement

                        // Rearranging the expected Y offset according to the view.
                        suggestedOffsetY = CGFloat.minimum(suggestedOffsetY, lastViewRect.minY)

                        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        // nextScrollView == nil    If processing scrollView is last scrollView in
                        // upper hierarchy (there is no other scrollView upper hierarchy.)
                        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        // suggestedOffsetY >= 0     suggestedOffsetY must be greater than in 
                        // order to keep distance from navigationBar (Bug ID: #92)
                        if isScrollableTextView,
                            nextScrollView == nil,
                            suggestedOffsetY >= 0 {

                            // Converting Rectangle according to window bounds.
                            if let superview: UIView = textFieldView.superview {

                                let currentTextFieldViewRect: CGRect = superview.convert(textFieldView.frame,
                                                                                         to: window)

                                // Calculating expected fix distance which needs to be managed from navigation bar
                                let expectedFixDistance: CGFloat = currentTextFieldViewRect.minY - topLayoutGuide

                                // Now if expectedOffsetY (scrollView.contentOffset.y + expectedFixDistance)
                                // is lower than current suggestedOffsetY, which means we're in a position where
                                // navigationBar up and hide, then reducing suggestedOffsetY with expectedOffsetY
                                // (scrollView.contentOffset.y + expectedFixDistance)
                                let expectedOffsetY: CGFloat = scrollView.contentOffset.y + expectedFixDistance
                                suggestedOffsetY = CGFloat.minimum(suggestedOffsetY, expectedOffsetY)

                                // Setting move to 0 because now we don't want to move any view anymore
                                // (All will be managed by our contentInset logic.
                                moveUp = 0
                            } else {
                                // Subtracting the Y offset from the move variable,
                                // because we are going to change scrollView's contentOffset.y to suggestedOffsetY.
                                moveUp -= (suggestedOffsetY-scrollView.contentOffset.y)
                            }
                        } else {
                            // Subtracting the Y offset from the move variable,
                            // because we are going to change scrollView's contentOffset.y to suggestedOffsetY.
                            moveUp -= (suggestedOffsetY-scrollView.contentOffset.y)
                        }

                        let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: suggestedOffsetY)

                        if !scrollView.contentOffset.equalTo(newContentOffset) {

                            showLog("""
                                    old contentOffset: \(scrollView.contentOffset)
                                    new contentOffset: \(newContentOffset)
                                    """)
                            self.showLog("Remaining Move: \(moveUp)")

                            // Getting problem while using `setContentOffset:animated:`, So I used animation API.
                            activeConfiguration.animate(alongsideTransition: {

                                //  (Bug ID: #1365, #1508, #1541)
                                let stackView: UIStackView? = textFieldView.iq.superviewOf(type: UIStackView.self,
                                                                                           belowView: scrollView)
                                // (Bug ID: #1901, #1996)
                                let animatedContentOffset: Bool = stackView != nil ||
                                scrollView is UICollectionView ||
                                scrollView is UITableView

                                if animatedContentOffset {
                                    scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                                } else {
                                    scrollView.contentOffset = newContentOffset
                                }
                            }, completion: {

                                if scrollView is UITableView || scrollView is UICollectionView {
                                    // This will update the next/previous states
                                    self.reloadInputViews()
                                }
                            })
                        }
                    }

                    // Getting next lastView & superScrollView.
                    lastView = scrollView
                    superScrollView = nextScrollView
                } else {
                    moveUp = 0
                    break
                }
            }

            // Updating contentInset
            let lastScrollView = lastScrollViewConfiguration.scrollView
            if let lastScrollViewRect: CGRect = lastScrollView.superview?.convert(lastScrollView.frame, to: window),
                !lastScrollView.iq.ignoreContentInsetAdjustment {

                var bottomInset: CGFloat = (kbSize.height)-(window.frame.height-lastScrollViewRect.maxY)
                let keyboardAndSafeArea: CGFloat = keyboardDistance + rootConfiguration.beginSafeAreaInsets.bottom
                var bottomScrollIndicatorInset: CGFloat = bottomInset - keyboardAndSafeArea

                // Update the insets so that the scrollView doesn't shift incorrectly
                // when the offset is near the bottom of the scroll view.
                bottomInset = CGFloat.maximum(lastScrollViewConfiguration.startingContentInset.bottom, bottomInset)
                let startingScrollInset: UIEdgeInsets = lastScrollViewConfiguration.startingScrollIndicatorInsets
                bottomScrollIndicatorInset = CGFloat.maximum(startingScrollInset.bottom,
                                                             bottomScrollIndicatorInset)

                bottomInset -= lastScrollView.safeAreaInsets.bottom
                bottomScrollIndicatorInset -= lastScrollView.safeAreaInsets.bottom

                var movedInsets: UIEdgeInsets = lastScrollView.contentInset
                movedInsets.bottom = bottomInset

                if lastScrollView.contentInset != movedInsets {
                    showLog("old ContentInset: \(lastScrollView.contentInset) new ContentInset: \(movedInsets)")

                    activeConfiguration.animate(alongsideTransition: {
                        lastScrollView.contentInset = movedInsets
                        lastScrollView.layoutIfNeeded() // (Bug ID: #1996)

                        var newScrollIndicatorInset: UIEdgeInsets = lastScrollView.verticalScrollIndicatorInsets

                        newScrollIndicatorInset.bottom = bottomScrollIndicatorInset
                        lastScrollView.scrollIndicatorInsets = newScrollIndicatorInset
                    })
                }
            }
        }
        // Going ahead. No else if.

        // Special case for UITextView
        // (Readjusting textView.contentInset when textView hight is too big to fit on screen)
        // _lastScrollView If not having inside any scrollView, now contentInset manages the full screen textView.
        // [_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        if isScrollableTextView, let textView = textFieldView as? UIScrollView {

            let keyboardYPosition: CGFloat = window.frame.height - originalKbSize.height
            var rootSuperViewFrameInWindow: CGRect = window.frame
            if let rootSuperview: UIView = rootController.view.superview {
                rootSuperViewFrameInWindow = rootSuperview.convert(rootSuperview.bounds, to: window)
            }

            let keyboardOverlapping: CGFloat = rootSuperViewFrameInWindow.maxY - keyboardYPosition

            let availableHeight: CGFloat = rootSuperViewFrameInWindow.height-topLayoutGuide-keyboardOverlapping
            let textViewHeight: CGFloat = CGFloat.minimum(textView.frame.height, availableHeight)

            if textView.frame.size.height-textView.contentInset.bottom>textViewHeight {
                // If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                if startingTextViewConfiguration == nil {
                    startingTextViewConfiguration = IQScrollViewConfiguration(scrollView: textView,
                                                                              canRestoreContentOffset: false)
                }

                var newContentInset: UIEdgeInsets = textView.contentInset
                newContentInset.bottom = textView.frame.size.height-textViewHeight
                newContentInset.bottom -= textView.safeAreaInsets.bottom

                if textView.contentInset != newContentInset {
                    self.showLog("""
                                \(textFieldView) Old UITextView.contentInset: \(textView.contentInset)
                                 New UITextView.contentInset: \(newContentInset)
                                """)

                    activeConfiguration.animate(alongsideTransition: {

                        textView.contentInset = newContentInset
                        textView.layoutIfNeeded() // (Bug ID: #1996)
                        textView.scrollIndicatorInsets = newContentInset
                    })
                }
            }
        }

        // +Positive or zero.
        if moveUp >= 0 {

            rootViewOrigin.y = CGFloat.maximum(rootViewOrigin.y - moveUp, CGFloat.minimum(0, -originalKbSize.height))

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

            movedDistance = (rootConfiguration.beginOrigin.y-rootViewOrigin.y)
        } else {  //  -Negative
            let disturbDistance: CGFloat = rootViewOrigin.y-rootConfiguration.beginOrigin.y

            //  disturbDistance Negative = frame disturbed.
            //  disturbDistance positive = frame not disturbed.
            if disturbDistance <= 0 {

                rootViewOrigin.y -= CGFloat.maximum(moveUp, disturbDistance)

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

                movedDistance = (rootConfiguration.beginOrigin.y-rootViewOrigin.y)
            }
        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    internal func restorePosition() {

        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        guard let configuration: IQRootControllerConfiguration = activeConfiguration.rootControllerConfiguration else {
            return
        }
        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        activeConfiguration.animate(alongsideTransition: {
            if configuration.hasChanged {
                let classNameString: String = "\(type(of: configuration.rootController.self))"
                self.showLog("Restoring \(classNameString) origin to: \(configuration.beginOrigin)")
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
           let lastConfiguration: IQScrollViewConfiguration = lastScrollViewConfiguration {

            activeConfiguration.animate(alongsideTransition: {

                if lastConfiguration.hasChanged {
                    if lastConfiguration.scrollView.contentInset != lastConfiguration.startingContentInset {
                        self.showLog("Restoring contentInset to: \(lastConfiguration.startingContentInset)")
                    }

                    if lastConfiguration.scrollView.iq.restoreContentOffset,
                       !lastConfiguration.scrollView.contentOffset.equalTo(lastConfiguration.startingContentOffset) {
                        self.showLog("Restoring contentOffset to: \(lastConfiguration.startingContentOffset)")
                    }

                    lastConfiguration.restore(for: textFieldView)
                }

                // This is temporary solution. Have to implement the save and restore scrollView state
                var superScrollView: UIScrollView? = lastConfiguration.scrollView

                while let scrollView: UIScrollView = superScrollView {

                    let width: CGFloat = CGFloat.maximum(scrollView.contentSize.width, scrollView.frame.width)
                    let height: CGFloat = CGFloat.maximum(scrollView.contentSize.height, scrollView.frame.height)
                    let contentSize: CGSize = CGSize(width: width, height: height)

                    let minimumY: CGFloat = contentSize.height - scrollView.frame.height

                    if minimumY < scrollView.contentOffset.y {

                        let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: minimumY)
                        if !scrollView.contentOffset.equalTo(newContentOffset) {

                            //  (Bug ID: #1365, #1508, #1541)
                            let stackView: UIStackView? = textFieldView.iq.superviewOf(type: UIStackView.self,
                                                                                       belowView: scrollView)

                            // (Bug ID: #1901, #1996)
                            let animatedContentOffset: Bool = stackView != nil ||
                            scrollView is UICollectionView ||
                            scrollView is UITableView

                            if animatedContentOffset {
                                scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                            } else {
                                scrollView.contentOffset = newContentOffset
                            }

                            self.showLog("Restoring contentOffset to: \(newContentOffset)")
                        }
                    }

                    superScrollView = scrollView.iq.superviewOf(type: UIScrollView.self)
                }
            })
        }

        self.movedDistance = 0
        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}
