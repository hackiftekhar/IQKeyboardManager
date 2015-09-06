//
//  DemoObjCUITests.m
//  DemoObjCUITests
//
//  Created by IEMacBook01 on 03/09/15.
//  Copyright © 2015 Iftekhar. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface DemoObjCUITests : XCTestCase

@end

@implementation DemoObjCUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


///--------------------------
/// @name UIKeyboard handling
///--------------------------

/**
 Enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
 */
- (void)testEnableDisable {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *window = [app.windows elementBoundByIndex:0];
    XCUIElement *rootViewController = [[window childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:0];
    XCUIElementQuery *tablesQuery = app.tables;
    XCUIElement *doneButton = app.toolbars.buttons[@"Done"];
    
    [tablesQuery.staticTexts[@"UITextField/UITextView example"] tap];

    XCUIElement *textView = [[[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"TextField Demo"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeTextView] elementBoundByIndex:2];
    [textView tap];
    
    //Should move up
    XCTAssertLessThan(rootViewController.frame.origin.y, 0);

    [doneButton tap];

    //Should back to normal
    XCTAssertEqual(rootViewController.frame.origin.y, 0);

    XCUIElement *textfieldDemoNavigationBar = app.navigationBars[@"TextField Demo"];
    [textfieldDemoNavigationBar.buttons[@"Disable"] tap];
    [textView tap];
    
    //Should not move, because it is disabled now
    XCTAssertEqual(rootViewController.frame.origin.y, 0);

    [textfieldDemoNavigationBar.buttons[@"Enable"] tap];

    //Should move up
    XCTAssertLessThan(rootViewController.frame.origin.y, 0);

    [doneButton tap];

    //Should back to normal
    XCTAssertEqual(rootViewController.frame.origin.y, 0);

    [[[[textfieldDemoNavigationBar childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    [app.navigationBars[@"IQKeyboardManager"].buttons[@"settings"] tap];
    [tablesQuery.switches[@"Enable, Enable/Disable IQKeyboardManager"] tap];
    [app.navigationBars[@"Settings"].buttons[@"Done"] tap];
    [tablesQuery.staticTexts[@"enable, shouldToolbarUsesTextFieldTintColor"] tap];
    [textView tap];
    
    //Should not move, because it is disabled now
    XCTAssertEqual(rootViewController.frame.origin.y, 0);
    
    [doneButton tap];
}

///**
// To set keyboard distance from textField. can't be less than zero. Default is 10.0.
// */
//- (void)testKeyboardDistanceFromTextField {
//    
//}

///**
// Prevent keyboard manager to slide up the rootView to more than keyboard height. Default is YES.
// */
//- (void)testPreventShowingBottomBlankSpace {
//    
//}


///-------------------------
/// @name IQToolbar handling
///-------------------------

/**
 enableAutoToolbar  Automatic add the IQToolbar functionality. Default is YES.
 toolbarManageBehaviour AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.
 */
- (void)testAutoToolbarAndManageBehaviour {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElementQuery *tablesQuery = app.tables;
    
    XCUIElement *textFieldTextViewExample = tablesQuery.staticTexts[@"UITextField/UITextView example"];
    XCUIElement *textFieldDemoBackButton = [[[app.navigationBars[@"TextField Demo"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0];
    
    XCUIElement *easiestIntegrationTextField = app.textFields[@"Easiest integration"];
    XCUIElement *easiestIntegrationNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"Easiest integration"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *deviceOrientationNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"Device Orientation support"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *categoryForKeyboardNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"UITextField Category for Keyboard"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *enableDisableKeyboardNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"Enable/Desable Keyboard Manager"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *customizeInputViewNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"Customize InputView support"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *textViewPlaceholderNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"IQTextView for placeholder support"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *lastTextView = [[[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"TextField Demo"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeTextView] elementBoundByIndex:4];

    XCUIElement *keyboardDoneButton = app.toolbars.buttons[@"Done"];
    
    XCUIElement *settingsButton = app.navigationBars[@"IQKeyboardManager"].buttons[@"settings"];
    XCUIElement *settingsDoneButton = app.navigationBars[@"Settings"].buttons[@"Done"];
    XCUIElement *switchEnableAutoToolbar = tablesQuery.switches[@"Enable AutoToolbar, Automatic add the IQToolbar on UIKeyboard"];
    
    XCUIElement *toolbarManageBehaviourSettings = tablesQuery.staticTexts[@"Toolbar Manage Behaviour"];
    XCUIElement *toolbarManageBehaviourBack = app.navigationBars[@"Toolbar Manage Behaviour"].buttons[@"Settings"];
    XCUIElement *autoToolbarByTag = tablesQuery.staticTexts[@"IQAutoToolbar By Tag"];
    XCUIElement *autoToolbarBySubviews = tablesQuery.staticTexts[@"IQAutoToolbar By Subviews"];
    
    
    [textFieldTextViewExample tap];
    
    [easiestIntegrationTextField tap];
    
    XCTAssertTrue(keyboardDoneButton.exists);
    
    [keyboardDoneButton tap];
    
    [textFieldDemoBackButton tap];

    [settingsButton tap];

    [switchEnableAutoToolbar tap];
    [settingsDoneButton tap];

    [textFieldTextViewExample tap];
    [lastTextView tap];

    XCTAssertFalse(keyboardDoneButton.exists);

    [app typeText:@"\n"];
    
    XCTAssertFalse(keyboardDoneButton.exists);

    [textFieldDemoBackButton tap];
    
    [settingsButton tap];
    
    [switchEnableAutoToolbar tap];
    [settingsDoneButton tap];
    
    [textFieldTextViewExample tap];

    [easiestIntegrationTextField tap];
    
    XCTAssertTrue(keyboardDoneButton.exists);

    [easiestIntegrationNext tap];
    [deviceOrientationNext tap];
    [categoryForKeyboardNext tap];
    [enableDisableKeyboardNext tap];
    [customizeInputViewNext tap];
    [textViewPlaceholderNext tap];
    [keyboardDoneButton tap];
    
    [textFieldDemoBackButton tap];
    
    [settingsButton tap];
    
    [toolbarManageBehaviourSettings tap];
    [autoToolbarByTag tap];
    
    [toolbarManageBehaviourBack tap];
    
    [settingsDoneButton tap];
    
    
    [textFieldTextViewExample tap];
    [easiestIntegrationTextField tap];
    [easiestIntegrationNext tap];
    [textViewPlaceholderNext tap];
    [categoryForKeyboardNext tap];
    [customizeInputViewNext tap];
    [keyboardDoneButton tap];
    
    [textFieldDemoBackButton tap];
    
    [settingsButton tap];
    [toolbarManageBehaviourSettings tap];
    [autoToolbarBySubviews tap];
    [toolbarManageBehaviourBack tap];
    [settingsDoneButton tap];
    [textFieldTextViewExample tap];
    [easiestIntegrationTextField tap];
    [easiestIntegrationNext tap];
    [categoryForKeyboardNext tap];
    [customizeInputViewNext tap];
    
    [keyboardDoneButton tap];
}

/**
 shouldShowTextFieldPlaceholder   If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.
 ShouldToolbarUsesTextFieldTintColor    If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO.
 placeholderFont    Placeholder Font. Default is nil.
 */
//- (void)testTextFieldPlaceholder {
//    
//}
//
//
/////--------------------------
///// @name UITextView handling
/////--------------------------
//
///**
// canAdjustTextView  Adjust textView's frame when it is too big in height. Default is NO.
// shouldFixTextViewClip  Adjust textView's contentInset to fix a bug. for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string Default is YES.
// */
//- (void)testTextView {
//    
//}
//
//
/////---------------------------------------
///// @name UIKeyboard appearance overriding
/////---------------------------------------
//
///**
// overrideKeyboardAppearance Override the keyboardAppearance for all textField/textView. Default is NO.
// keyboardAppearance If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.
// 
// */
//- (void)testKeyboardAppearance {
//    
//}
//
//
/////---------------------------------------------
///// @name UITextField/UITextView Next/Previous/Resign handling
/////---------------------------------------------
//
///**
// shouldResignOnTouchOutside Resigns Keyboard on touching outside of UITextField/View. Default is NO.
// resignFirstResponder   Resigns currently first responder field.
// canGoPrevious  Returns YES if can navigate to previous responder textField/textView, otherwise NO.
// canGoNext  Returns YES if can navigate to next responder textField/textView, otherwise NO.
// goPrevious Navigate to previous responder textField/textView.
// goNext Navigate to next responder textField/textView.
// */
//- (void)testPreviousNextResign {
//    
//}
//
//
/////----------------------------
///// @name UIScrollView handling
/////----------------------------
//
///**
// Restore scrollViewContentOffset when resigning from scrollView. Default is NO.
// */
//- (void)testShouldRestoreScrollViewContentOffset {
//    
//}
//
//
/////------------------------------------
///// @name Class Level disabling methods
/////------------------------------------
//
///**
// @method disableInViewControllerClass: Disable adjusting view in disabledClass
// @method removeDisableInViewControllerClass: Re-enable adjusting textField in disabledClass
// @method disableToolbarInViewControllerClass: Disable automatic toolbar creation in in toolbarDisabledClass
// @method removeDisableToolbarInViewControllerClass: Re-enable automatic toolbar creation in in toolbarDisabledClass
// @method considerToolbarPreviousNextInViewClass: Consider provided customView class as superView of all inner textField for calculating next/previous button logic.
// @method disableInViewControllerClass: Remove Consideration for provided customView class as superView of all inner textField for calculating next/previous button logic.
// */
//- (void)testClassLevelEnableDisable {
//    
//}

@end
