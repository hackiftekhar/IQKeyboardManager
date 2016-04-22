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
    
    XCUIElement *textFieldTextViewExample = tablesQuery.staticTexts[@"UITextField/UITextView example"];
    XCUIElement *textFieldDemoBackButton = [[[app.navigationBars[@"TextField Demo"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0];
    XCUIElement *textfieldDemoNavigationBarEnableButton = app.navigationBars[@"TextField Demo"].buttons[@"Enable"];
    XCUIElement *textfieldDemoNavigationBarDisableButton = app.navigationBars[@"TextField Demo"].buttons[@"Disable"];

    XCUIElement *textView = [[[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"TextField Demo"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeTextView] elementBoundByIndex:4];
    XCUIElement *keyboardDoneButton = app.toolbars.buttons[@"Done"];
    
    XCUIElement *settingsButton = app.navigationBars[@"IQKeyboardManager"].buttons[@"settings"];
    XCUIElement *switchEnable = tablesQuery.switches[@"Enable, Enable/Disable IQKeyboardManager"];
    XCUIElement *settingsDoneButton = app.navigationBars[@"Settings"].buttons[@"Done"];

    
    [textFieldTextViewExample tap];

    [textView tap];
    
    //Should move up
    XCTAssertLessThan(rootViewController.frame.origin.y, 0);

    [keyboardDoneButton tap];

    //Should back to normal
    XCTAssertEqual(rootViewController.frame.origin.y, 0);

    [textfieldDemoNavigationBarDisableButton tap];
    [textView tap];
    
    //Should not move, because it is disabled now
    XCTAssertEqual(rootViewController.frame.origin.y, 0);

    [textfieldDemoNavigationBarEnableButton tap];

    //Should move up
    XCTAssertLessThan(rootViewController.frame.origin.y, 0);

    [keyboardDoneButton tap];

    //Should back to normal
    XCTAssertEqual(rootViewController.frame.origin.y, 0);

    [textFieldDemoBackButton tap];
    [settingsButton tap];
    [switchEnable tap];
    [settingsDoneButton tap];
    [textFieldTextViewExample tap];
    [textView tap];
    
    //Should not move, because it is disabled now
    XCTAssertEqual(rootViewController.frame.origin.y, 0);
    
    [keyboardDoneButton tap];
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
- (void)testTextFieldPlaceholder {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElementQuery *tablesQuery = app.tables;
    
    XCUIElement *textFieldTextViewExample = tablesQuery.staticTexts[@"UITextField/UITextView example"];
    XCUIElement *specialCasesExample = tablesQuery.staticTexts[@"Special Cases"];

    XCUIElement *textFieldDemoBackButton = [[[app.navigationBars[@"TextField Demo"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0];
    XCUIElement *specialCaseDemoBackButton = [[[app.navigationBars[@"Special Cases"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0];

    XCUIElement *enableDisableTextField = app.textFields[@"Enable/Desable Keyboard Manager"];
    XCUIElement *enableDisableKeyboardNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"Enable/Desable Keyboard Manager"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *customizeInputViewNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"Customize InputView support"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *textViewPlaceholderNext = [[[app.toolbars containingType:XCUIElementTypeOther identifier:@"IQTextView for placeholder support"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];

    XCUIElement *specialCaseTextField = app.textFields[@"TextField 3"];
    XCUIElement *specialCaseToolbar = [app.toolbars containingType:XCUIElementTypeOther identifier:@"TextField 3"].element;

    XCUIElement *keyboardNextButton = [[[app.toolbars containingType:XCUIElementTypeButton identifier:@"Done"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    XCUIElement *keyboardDoneButton = app.toolbars.buttons[@"Done"];
    
    XCUIElement *settingsButton = app.navigationBars[@"IQKeyboardManager"].buttons[@"settings"];
    XCUIElement *settingsDoneButton = app.navigationBars[@"Settings"].buttons[@"Done"];
    XCUIElement *switchShouldShowTextfieldPlaceholder = tablesQuery.switches[@"Should Show TextField Placeholder, Add the textField's placeholder text on IQToolbar"];
    XCUIElement *switchShouldToolbarUsesTextFieldTintColor = tablesQuery.switches[@"Should Toolbar Uses TextField TintColor, Uses textField's tintColor property for IQToolbar"];
    XCUIElement *placeholderFont = tablesQuery.staticTexts[@"Placeholder Font"];
    XCUIElement *italicSystemFont = tablesQuery.staticTexts[@"Italic system font"];
    
    XCUIElement *fontsBack = app.navigationBars[@"Fonts"].buttons[@"Settings"];

    [settingsButton tap];
    [switchShouldShowTextfieldPlaceholder tap];
    [settingsDoneButton tap];
    
    [textFieldTextViewExample tap];
    
    [enableDisableTextField tap];
    XCTAssertFalse(enableDisableKeyboardNext.exists);
    [keyboardNextButton tap];
    XCTAssertFalse(customizeInputViewNext.exists);
    [keyboardNextButton tap];
    XCTAssertFalse(textViewPlaceholderNext.exists);
    [keyboardDoneButton tap];
    [textFieldDemoBackButton tap];

    [specialCasesExample tap];
    [specialCaseTextField tap];
    XCTAssertFalse(specialCaseToolbar.exists);
    [keyboardDoneButton tap];
    [specialCaseDemoBackButton tap];
    
    [settingsButton tap];
    [switchShouldShowTextfieldPlaceholder tap];
    [settingsDoneButton tap];
    
    [textFieldTextViewExample tap];
    
    [enableDisableTextField tap];
    XCTAssertTrue(enableDisableKeyboardNext.exists);
    [keyboardNextButton tap];
    XCTAssertTrue(customizeInputViewNext.exists);
    [keyboardNextButton tap];
    XCTAssertTrue(textViewPlaceholderNext.exists);
    [keyboardDoneButton tap];
    [textFieldDemoBackButton tap];

    [specialCasesExample tap];
    [specialCaseTextField tap];
    XCTAssertTrue(specialCaseToolbar.exists);
    [keyboardDoneButton tap];
    [specialCaseDemoBackButton tap];

    [settingsButton tap];
    [placeholderFont tap];
    [italicSystemFont tap];
    [fontsBack tap];
    [settingsDoneButton tap];
    
    [textFieldTextViewExample tap];
    
    [enableDisableTextField tap];
    [keyboardNextButton tap];
    [keyboardNextButton tap];
    [keyboardDoneButton tap];
    
    [textFieldDemoBackButton tap];
    [settingsButton tap];
    [switchShouldToolbarUsesTextFieldTintColor tap];
    [settingsDoneButton tap];
    
    [textFieldTextViewExample tap];
    
    [enableDisableTextField tap];
    [keyboardNextButton tap];
    [keyboardNextButton tap];
    [keyboardDoneButton tap];
}

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
// @method disableDistanceHandlingInViewControllerClass: Disable adjusting view in disabledClass
// @method removeDisableInViewControllerClass: Re-enable adjusting textField in disabledClass
// @method disableToolbarInViewControllerClass: Disable automatic toolbar creation in in toolbarDisabledClass
// @method removeDisableToolbarInViewControllerClass: Re-enable automatic toolbar creation in in toolbarDisabledClass
// @method considerToolbarPreviousNextInViewClass: Consider provided customView class as superView of all inner textField for calculating next/previous button logic.
// @method disableDistanceHandlingInViewControllerClass: Remove Consideration for provided customView class as superView of all inner textField for calculating next/previous button logic.
// */
//- (void)testClassLevelEnableDisable {
//    
//}

@end
