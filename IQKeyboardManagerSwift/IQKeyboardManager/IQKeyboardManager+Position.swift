//
//  IQKeyboardManager+Position.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import IQKeyboardCore

// swiftlint:disable file_length
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardManager {

    private typealias IQLayoutGuide = (top: CGFloat, bottom: CGFloat)

    @MainActor
    private struct AssociatedKeys {
        static var movedDistance: Int = 0
        static var movedDistanceChanged: Int = 0
        static var lastScrollViewConfiguration: Int = 0
        static var startingTextViewConfiguration: Int = 0
        static var activeConfiguration: Int = 0
    }

    /**
     moved distance to the top used to maintain distance between keyboard and textInputView.
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
    var movedDistanceChanged: ((CGFloat) -> Void)? {
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
    @nonobjc
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
    @nonobjc
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

    internal func applicationDidBecomeActive(_ notification: Notification) {

        guard privateIsEnabled(),
              activeConfiguration.keyboardInfo.isVisible,
              activeConfiguration.isReady else {
            return
        }
        adjustPosition()
    }

    /* Adjusting RootViewController's frame according to interface orientation. */
    // swiftlint:disable function_body_length
    internal func adjustPosition() {

        guard UIApplication.shared.applicationState == .active,
              let textInputView: any IQTextInputView = activeConfiguration.textInputView,
              let superview: UIView = textInputView.superview,
              let rootConfiguration = activeConfiguration.rootConfiguration,
              let rootController: UIViewController = rootConfiguration.rootController,
              let window: UIWindow = rootController.view.window else {
            return
        }

        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        defer {
            showLog("<<<<< \(#function) ended <<<<<", indentation: -1)
        }

        let textInputViewRectInWindow: CGRect = superview.convert(textInputView.frame, to: window)
        let textInputViewRectInRootSuperview: CGRect = superview.convert(textInputView.frame,
                                                                         to: rootController.view.superview)

        //  Getting RootViewOrigin.
        let rootViewOrigin: CGPoint = rootController.view.frame.origin

        let keyboardDistance: CGFloat = getSpecialTextInputViewDistance(textInputView: textInputView)

        let kbSize: CGSize = Self.getKeyboardSize(keyboardDistance: keyboardDistance,
                                                  keyboardFrame: activeConfiguration.keyboardInfo.endFrame,
                                                  safeAreaInsets: rootConfiguration.beginSafeAreaInsets,
                                                  windowFrame: window.frame)
        let originalKbSize: CGSize = activeConfiguration.keyboardInfo.endFrame.size

        let isScrollableTextInputView: Bool

        if let textInputView: UIScrollView = textInputView as? UITextView {
            isScrollableTextInputView = textInputView.isScrollEnabled
        } else {
            isScrollableTextInputView = false
        }

        let layoutGuide: IQLayoutGuide = Self.getLayoutGuides(rootController: rootController, window: window,
                                                              isScrollableTextInputView: isScrollableTextInputView)

        //  Move positive = textInputView is hidden.
        //  Move negative = textInputView is showing.
        //  Calculating move position.
        var moveUp: CGFloat = Self.getMoveUpDistance(keyboardSize: kbSize,
                                                     layoutGuide: layoutGuide,
                                                     textInputViewRectInRootSuperview: textInputViewRectInRootSuperview,
                                                     textInputViewRectInWindow: textInputViewRectInWindow,
                                                     windowFrame: window.frame)

        showLog("Need to move: \(moveUp), will be moving \(moveUp < 0 ? "down" : "up")")

        var superScrollView: UIScrollView?
        var superView: UIScrollView? = (textInputView as UIView).iq.superviewOf(type: UIScrollView.self)

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

        setupActiveScrollViewConfiguration(superScrollView: superScrollView, textInputView: textInputView)

        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textInputView.
        if let lastScrollViewConfiguration: IQScrollViewConfiguration  = lastScrollViewConfiguration {
            adjustScrollViewContentOffsets(moveUp: &moveUp, textInputView: textInputView,
                                           lastScrollViewConfiguration: lastScrollViewConfiguration,
                                           rootSuperview: rootController.view.superview, layoutGuide: layoutGuide,
                                           textInputViewRectInRootSuperview: textInputViewRectInRootSuperview,
                                           isScrollableTextInputView: isScrollableTextInputView, window: window,
                                           kbSize: kbSize, keyboardDistance: keyboardDistance,
                                           rootBeginSafeAreaInsets: rootConfiguration.beginSafeAreaInsets)
        }

        // Special case for UITextView
        // (Readjusting textInputView.contentInset when textInputView hight is too big to fit on screen)
        // _lastScrollView If not having inside any scrollView, now contentInset manages the full screen textInputView.
        // If is a UITextView type
        if isScrollableTextInputView, let textInputView = textInputView as? UITextView {

            adjustTextInputViewContentInset(window: window, originalKbSize: originalKbSize,
                                            rootSuperview: rootController.view.superview,
                                            layoutGuide: layoutGuide,
                                            textInputView: textInputView)
        }

        adjustRootController(moveUp: moveUp, rootViewOrigin: rootViewOrigin, originalKbSize: originalKbSize,
                             rootController: rootController, rootBeginOrigin: rootConfiguration.beginOrigin)
    }
    // swiftlint:enable function_body_length

    internal func restorePosition() {

        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        guard let configuration: IQRootControllerConfiguration = activeConfiguration.rootConfiguration else {
            return
        }
        showLog(">>>>> \(#function) started >>>>>", indentation: 1)

        defer {
            showLog("<<<<< \(#function) ended <<<<<", indentation: -1)
        }

        activeConfiguration.animate(alongsideTransition: {
            if configuration.hasChanged {
                let classNameString: String = "\(type(of: configuration.rootController.self))"
                self.showLog("Restoring \(classNameString) origin to: \(configuration.beginOrigin)")
            }
            configuration.restore()

            // Animating content if needed (Bug ID: #204)
            if self.layoutIfNeededOnUpdate {
                // Animating content (Bug ID: #160)
                configuration.rootController?.view.setNeedsLayout()
                configuration.rootController?.view.layoutIfNeeded()
            }
        })
        // Restoring the contentOffset of the lastScrollView
        if let lastConfiguration: IQScrollViewConfiguration = lastScrollViewConfiguration {
            let textInputView: (any IQTextInputView)? = activeConfiguration.textInputView

            restoreScrollViewConfigurationIfChanged(configuration: lastConfiguration, textInputView: textInputView)

            activeConfiguration.animate(alongsideTransition: {
                // This is temporary solution. Have to implement the save and restore scrollView state
                self.restoreScrollViewContentOffset(superScrollView: lastConfiguration.scrollView,
                                                    textInputView: textInputView)
            })
        }

        self.movedDistance = 0
    }
}

// swiftlint:disable function_parameter_count
@available(iOSApplicationExtension, unavailable)
@MainActor
private extension IQKeyboardManager {

    func getSpecialTextInputViewDistance(textInputView: some IQTextInputView) -> CGFloat {
        // Maintain keyboardDistance
        let specialKeyboardDistance: CGFloat

        if let searchBar: UISearchBar = textInputView.iq.textFieldSearchBar() {
            specialKeyboardDistance = searchBar.iq.distanceFromKeyboard
        } else {
            specialKeyboardDistance = textInputView.iq.distanceFromKeyboard
        }

        if specialKeyboardDistance == UIView.defaultKeyboardDistance {
            return keyboardDistance
        } else {
            return specialKeyboardDistance
        }
    }

    static func getKeyboardSize(keyboardDistance: CGFloat, keyboardFrame: CGRect,
                                safeAreaInsets: UIEdgeInsets, windowFrame: CGRect) -> CGSize {
        let kbSize: CGSize
        var kbFrame: CGRect = keyboardFrame

        kbFrame.origin.y -= keyboardDistance
        kbFrame.size.height += keyboardDistance

        kbFrame.origin.y -= safeAreaInsets.bottom
        kbFrame.size.height += safeAreaInsets.bottom

        // (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
        // Calculating actual keyboard covered size respect to window,
        // keyboard frame may be different when hardware keyboard is attached
        let intersectRect: CGRect = kbFrame.intersection(windowFrame)

        if intersectRect.isNull {
            kbSize = CGSize(width: kbFrame.size.width, height: 0)
        } else {
            kbSize = intersectRect.size
        }
        return kbSize
    }

    static private func getLayoutGuides(rootController: UIViewController, window: UIWindow,
                                        isScrollableTextInputView: Bool) -> IQLayoutGuide {
        let navigationBarAreaHeight: CGFloat
        if let navigationController: UINavigationController = rootController.navigationController {
            navigationBarAreaHeight = navigationController.navigationBar.frame.maxY
        } else {
            let statusBarHeight: CGFloat = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            navigationBarAreaHeight = statusBarHeight
        }

        let directionalLayoutMargin: NSDirectionalEdgeInsets = rootController.view.directionalLayoutMargins
        let topLayoutGuide: CGFloat = CGFloat.maximum(navigationBarAreaHeight, directionalLayoutMargin.top)

        // Validation of textInputView for case where there is a tab bar
        // at the bottom or running on iPhone X and textInputView is at the bottom.
        let bottomLayoutGuide: CGFloat = isScrollableTextInputView ? 0 : directionalLayoutMargin.bottom
        return (topLayoutGuide, bottomLayoutGuide)
    }

    static private func getMoveUpDistance(keyboardSize: CGSize,
                                          layoutGuide: IQLayoutGuide,
                                          textInputViewRectInRootSuperview: CGRect,
                                          textInputViewRectInWindow: CGRect,
                                          windowFrame: CGRect) -> CGFloat {

        //  Move positive = textInputView is hidden.
        //  Move negative = textInputView is showing.
        //  Calculating move position.
        let visibleHeight: CGFloat = windowFrame.height-keyboardSize.height

        let topMovement: CGFloat = textInputViewRectInRootSuperview.minY-layoutGuide.top
        let bottomMovement: CGFloat = textInputViewRectInWindow.maxY - visibleHeight + layoutGuide.bottom
        var moveUp: CGFloat = CGFloat.minimum(topMovement, bottomMovement)
        moveUp = CGFloat(Int(moveUp))
        return moveUp
    }

    func setupActiveScrollViewConfiguration(superScrollView: UIScrollView?, textInputView: some IQTextInputView) {
        // If there was a lastScrollView.    //  (Bug ID: #34)
        guard let lastConfiguration: IQScrollViewConfiguration = lastScrollViewConfiguration else {
            if let superScrollView: UIScrollView = superScrollView {
                // If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
                let configuration = IQScrollViewConfiguration(scrollView: superScrollView,
                                                              canRestoreContentOffset: true)
                self.lastScrollViewConfiguration = configuration
                showLog("""
                        Saving ScrollView New contentInset: \(configuration.startingContentInset)
                        and contentOffset: \(configuration.startingContentOffset)
                        """)
            }
            return
        }

        // If we can't find current superScrollView, then setting lastScrollView to it's original form.
        if superScrollView == nil {
            restoreScrollViewConfigurationIfChanged(configuration: lastConfiguration,
                                                    textInputView: textInputView)
            self.lastScrollViewConfiguration = nil
        } else if superScrollView != lastConfiguration.scrollView {
            // If both scrollView's are different,
            // then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
            restoreScrollViewConfigurationIfChanged(configuration: lastConfiguration,
                                                    textInputView: textInputView)

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
        // after switching to different textInputView. So doing nothing, going ahead
    }

    func restoreScrollViewConfigurationIfChanged(configuration: IQScrollViewConfiguration,
                                                 textInputView: (some IQTextInputView)?) {
        guard configuration.hasChanged else { return }
        if configuration.scrollView.contentInset != configuration.startingContentInset {
            showLog("Restoring contentInset to: \(configuration.startingContentInset)")
        }

        if configuration.scrollView.iq.restoreContentOffset,
           !configuration.scrollView.contentOffset.equalTo(configuration.startingContentOffset) {
            showLog("Restoring contentOffset to: \(configuration.startingContentOffset)")
        }

        activeConfiguration.animate(alongsideTransition: {
            configuration.restore(for: textInputView)
        })
    }

    // swiftlint:disable function_body_length
    private func adjustScrollViewContentOffsets(moveUp: inout CGFloat, textInputView: some IQTextInputView,
                                                lastScrollViewConfiguration: IQScrollViewConfiguration,
                                                rootSuperview: UIView?,
                                                layoutGuide: IQLayoutGuide,
                                                textInputViewRectInRootSuperview: CGRect,
                                                isScrollableTextInputView: Bool, window: UIWindow,
                                                kbSize: CGSize, keyboardDistance: CGFloat,
                                                rootBeginSafeAreaInsets: UIEdgeInsets) {
        // Saving
        var lastView: UIView = textInputView
        var superScrollView: UIScrollView? = lastScrollViewConfiguration.scrollView

        while let scrollView: UIScrollView = superScrollView {

            var isContinue: Bool = false

            if moveUp > 0 {
                isContinue = moveUp > (-scrollView.contentOffset.y - scrollView.contentInset.top)

            } else if let tableView: UITableView = scrollView.iq.superviewOf(type: UITableView.self) {
                // Special treatment for UITableView due to their cell reusing logic

                isContinue = scrollView.contentOffset.y > 0

                Self.handleTableViewCase(moveUp: &moveUp, isContinue: isContinue, textInputView: textInputView,
                                         tableView: tableView, rootSuperview: rootSuperview, layoutGuide: layoutGuide)
            } else if let collectionView = scrollView.iq.superviewOf(type: UICollectionView.self) {
                // Special treatment for UICollectionView due to their cell reusing logic

                isContinue = scrollView.contentOffset.y > 0

                Self.handleCollectionViewCase(moveUp: &moveUp, isContinue: isContinue,
                                              textInputView: textInputView, collectionView: collectionView,
                                              rootSuperview: rootSuperview, layoutGuide: layoutGuide)
            } else {
                isContinue = textInputViewRectInRootSuperview.minY < layoutGuide.top

                if isContinue {
                    moveUp = CGFloat.minimum(0, textInputViewRectInRootSuperview.minY - layoutGuide.top)
                }
            }

            // Looping in upper hierarchy until we don't found any scrollView
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

                    updateSuggestedOffsetYAndMoveUp(suggestedOffsetY: &suggestedOffsetY, moveUp: &moveUp,
                                                    isScrollableTextInputView: isScrollableTextInputView,
                                                    nextScrollView: nextScrollView, textInputView: textInputView,
                                                    window: window, layoutGuide: layoutGuide,
                                                    scrollViewContentOffset: scrollView.contentOffset)

                    let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: suggestedOffsetY)

                    if !scrollView.contentOffset.equalTo(newContentOffset) {

                        updateScrollViewContentOffset(scrollView: scrollView, newContentOffset: newContentOffset,
                                                      moveUp: moveUp, textInputView: textInputView)
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

        adjustScrollViewContentInset(lastScrollViewConfiguration: lastScrollViewConfiguration, window: window,
                                     kbSize: kbSize, keyboardDistance: keyboardDistance,
                                     rootBeginSafeAreaInsets: rootBeginSafeAreaInsets)
    }
    // swiftlint:enable function_body_length

    private static func handleTableViewCase(moveUp: inout CGFloat, isContinue: Bool,
                                            textInputView: some IQTextInputView, tableView: UITableView,
                                            rootSuperview: UIView?, layoutGuide: IQLayoutGuide) {
        guard isContinue,
              let tableCell: UITableViewCell = textInputView.iq.superviewOf(type: UITableViewCell.self),
              let indexPath: IndexPath = tableView.indexPath(for: tableCell),
              let previousIndexPath: IndexPath = tableView.previousIndexPath(of: indexPath) else { return }

        let previousCellRect: CGRect = tableView.rectForRow(at: previousIndexPath)
        guard !previousCellRect.isEmpty else { return }

        let previousCellRectInRootSuperview: CGRect = tableView.convert(previousCellRect,
                                                                        to: rootSuperview)

        moveUp = CGFloat.minimum(0, previousCellRectInRootSuperview.maxY - layoutGuide.top)
    }

    private static func handleCollectionViewCase(moveUp: inout CGFloat, isContinue: Bool,
                                                 textInputView: some IQTextInputView, collectionView: UICollectionView,
                                                 rootSuperview: UIView?,
                                                 layoutGuide: IQLayoutGuide) {
        guard isContinue,
              let collectionCell = textInputView.iq.superviewOf(type: UICollectionViewCell.self),
              let indexPath: IndexPath = collectionView.indexPath(for: collectionCell),
              let previousIndexPath: IndexPath = collectionView.previousIndexPath(of: indexPath),
              let attributes = collectionView.layoutAttributesForItem(at: previousIndexPath) else { return }

        let previousCellRect: CGRect = attributes.frame
        guard !previousCellRect.isEmpty else { return }
        let previousCellRectInRootSuperview: CGRect = collectionView.convert(previousCellRect,
                                                                             to: rootSuperview)

        moveUp = CGFloat.minimum(0, previousCellRectInRootSuperview.maxY - layoutGuide.top)
    }

    private func updateSuggestedOffsetYAndMoveUp(suggestedOffsetY: inout CGFloat, moveUp: inout CGFloat,
                                                 isScrollableTextInputView: Bool, nextScrollView: UIScrollView?,
                                                 textInputView: some IQTextInputView, window: UIWindow,
                                                 layoutGuide: IQLayoutGuide,
                                                 scrollViewContentOffset: CGPoint) {
        // If is a UITextView type
        // nextScrollView == nil
        // If processing scrollView is last scrollView in upper hierarchy
        // (there is no other scrollView in upper hierarchy.)
        //
        // suggestedOffsetY >= 0
        // suggestedOffsetY must be >= 0 in order to keep distance from navigationBar (Bug ID: #92)
        guard isScrollableTextInputView,
              nextScrollView == nil,
              suggestedOffsetY >= 0,
              let superview: UIView = textInputView.superview else {
            // Subtracting the Y offset from the move variable,
            // because we are going to change scrollView's contentOffset.y to suggestedOffsetY.
            moveUp -= (suggestedOffsetY-scrollViewContentOffset.y)
            return
        }

        let currentTextInputViewRect: CGRect = superview.convert(textInputView.frame,
                                                                 to: window)

        // Calculating expected fix distance which needs to be managed from navigation bar
        let expectedFixDistance: CGFloat = currentTextInputViewRect.minY - layoutGuide.top

        // Now if expectedOffsetY (scrollView.contentOffset.y + expectedFixDistance)
        // is lower than current suggestedOffsetY, which means we're in a position where
        // navigationBar up and hide, then reducing suggestedOffsetY with expectedOffsetY
        // (scrollView.contentOffset.y + expectedFixDistance)
        let expectedOffsetY: CGFloat = scrollViewContentOffset.y + expectedFixDistance
        suggestedOffsetY = CGFloat.minimum(suggestedOffsetY, expectedOffsetY)

        // Setting move to 0 because now we don't want to move any view anymore
        // (All will be managed by our contentInset logic.
        moveUp = 0
    }

    func updateScrollViewContentOffset(scrollView: UIScrollView, newContentOffset: CGPoint,
                                       moveUp: CGFloat, textInputView: some IQTextInputView) {
        showLog("""
                                    old contentOffset: \(scrollView.contentOffset)
                                    new contentOffset: \(newContentOffset)
                                    """)
        showLog("Remaining Move: \(moveUp)")

        // Getting problem while using `setContentOffset:animated:`, So I used animation API.
        activeConfiguration.animate(alongsideTransition: {

            //  (Bug ID: #1365, #1508, #1541)
            let stackView: UIStackView? = textInputView.iq.superviewOf(type: UIStackView.self,
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
                textInputView.reloadInputViews()
            }
        })
    }

    func adjustScrollViewContentInset(lastScrollViewConfiguration: IQScrollViewConfiguration,
                                      window: UIWindow, kbSize: CGSize, keyboardDistance: CGFloat,
                                      rootBeginSafeAreaInsets: UIEdgeInsets) {

        let lastScrollView = lastScrollViewConfiguration.scrollView

        guard let lastScrollViewRect: CGRect = lastScrollView.superview?.convert(lastScrollView.frame, to: window),
              !lastScrollView.iq.ignoreContentInsetAdjustment else { return }

        // Updating contentInset
        var bottomInset: CGFloat = (kbSize.height)-(window.frame.height-lastScrollViewRect.maxY)
        let keyboardAndSafeArea: CGFloat = keyboardDistance + rootBeginSafeAreaInsets.bottom
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

        guard lastScrollView.contentInset != movedInsets else { return }
        showLog("""
                old ContentInset: \(lastScrollView.contentInset) new ContentInset: \(movedInsets)
                """)

        activeConfiguration.animate(alongsideTransition: {
            lastScrollView.contentInset = movedInsets
            lastScrollView.layoutIfNeeded() // (Bug ID: #1996)

            var newScrollIndicatorInset: UIEdgeInsets = lastScrollView.verticalScrollIndicatorInsets

            newScrollIndicatorInset.bottom = bottomScrollIndicatorInset
            lastScrollView.scrollIndicatorInsets = newScrollIndicatorInset
        })
    }

    private func adjustTextInputViewContentInset(window: UIWindow, originalKbSize: CGSize,
                                                 rootSuperview: UIView?,
                                                 layoutGuide: IQLayoutGuide,
                                                 textInputView: UIScrollView) {
        let keyboardYPosition: CGFloat = window.frame.height - originalKbSize.height
        var rootSuperViewFrameInWindow: CGRect = window.frame
        if let rootSuperview: UIView = rootSuperview {
            rootSuperViewFrameInWindow = rootSuperview.convert(rootSuperview.bounds, to: window)
        }

        let keyboardOverlapping: CGFloat = rootSuperViewFrameInWindow.maxY - keyboardYPosition

        let availableHeight: CGFloat = rootSuperViewFrameInWindow.height-layoutGuide.top-keyboardOverlapping
        let textInputViewHeight: CGFloat = CGFloat.minimum(textInputView.frame.height, availableHeight)

        guard textInputView.frame.size.height-textInputView.contentInset.bottom>textInputViewHeight else { return }
        // If frame is not change by library in past, then saving user textInputView properties  (Bug ID: #92)
        if startingTextViewConfiguration == nil {
            startingTextViewConfiguration = IQScrollViewConfiguration(scrollView: textInputView,
                                                                      canRestoreContentOffset: false)
        }

        var newContentInset: UIEdgeInsets = textInputView.contentInset
        newContentInset.bottom = textInputView.frame.size.height-textInputViewHeight
        newContentInset.bottom -= textInputView.safeAreaInsets.bottom

        guard textInputView.contentInset != newContentInset else { return }
        showLog("""
                                \(textInputView) Old textInputView.contentInset: \(textInputView.contentInset)
                                 New textInputView.contentInset: \(newContentInset)
                                """)

        activeConfiguration.animate(alongsideTransition: {

            textInputView.contentInset = newContentInset
            textInputView.layoutIfNeeded() // (Bug ID: #1996)
            textInputView.scrollIndicatorInsets = newContentInset
        })
    }

    func adjustRootController(moveUp: CGFloat, rootViewOrigin: CGPoint, originalKbSize: CGSize,
                              rootController: UIViewController, rootBeginOrigin: CGPoint) {
        // +Positive or zero.
        var rootViewOrigin: CGPoint = rootViewOrigin
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

            movedDistance = rootBeginOrigin.y-rootViewOrigin.y
        } else {  //  -Negative
            let disturbDistance: CGFloat = rootViewOrigin.y-rootBeginOrigin.y

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

                movedDistance = rootBeginOrigin.y-rootViewOrigin.y
            }
        }
    }

    func restoreScrollViewContentOffset(superScrollView: UIScrollView, textInputView: (some IQTextInputView)?) {
        var superScrollView: UIScrollView? = superScrollView
        while let scrollView: UIScrollView = superScrollView {

            let width: CGFloat = CGFloat.maximum(scrollView.contentSize.width, scrollView.frame.width)
            let height: CGFloat = CGFloat.maximum(scrollView.contentSize.height, scrollView.frame.height)
            let contentSize: CGSize = CGSize(width: width, height: height)

            let minimumY: CGFloat = contentSize.height - scrollView.frame.height

            if minimumY < scrollView.contentOffset.y {

                let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: minimumY)
                if !scrollView.contentOffset.equalTo(newContentOffset) {

                    //  (Bug ID: #1365, #1508, #1541)
                    let stackView: UIStackView?
                    if let textInputView: UIView = textInputView {
                        stackView = textInputView.iq.superviewOf(type: UIStackView.self,
                                                                 belowView: scrollView)
                    } else {
                        stackView = nil
                    }

                    // (Bug ID: #1901, #1996)
                    let animatedContentOffset: Bool = stackView != nil ||
                    scrollView is UICollectionView ||
                    scrollView is UITableView

                    if animatedContentOffset {
                        scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                    } else {
                        scrollView.contentOffset = newContentOffset
                    }

                    showLog("Restoring contentOffset to: \(newContentOffset)")
                }
            }

            superScrollView = scrollView.iq.superviewOf(type: UIScrollView.self)
        }
    }
}
// swiftlint:enable function_parameter_count
