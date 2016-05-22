Manual Management:-
---

#### UINavigationBar:-

  If you don't want to hide the default UINavigationBar of UINavigationController when keyboardManager slides up the view, then just change the UIView class to UIScrollView from the storyboard  or xib. Make sure that scrollView is able to get it's contentSize from constraints.([#21](https://github.com/hackiftekhar/IQKeyboardManager/issues/21), [#24](https://github.com/hackiftekhar/IQKeyboardManager/issues/24))

![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/UINavigationBarExample.jpg)


  If you are not using storyboard or xib and creating your view programmatically. Then you need to override '-(void)loadView' method of UIViewController, and need to set an UIScrollView instance to self.view.

```objc
    -(void)loadView
    {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        scrollView.contentSize = CGSizeMake(CONTENT_WIDTH, CONTENT_HEIGHT); //You may not need this code if you are working with Autolayout and scrollView is able to get it's contentSize from constraints.
        self.view = scrollView;
    }
```

#### Working with TopLayoutGuide and BottomLayoutGuide:-

 Technically IQKeyboardManager moves upwards/downwards of currently presentedViewController's view. So if you're pinning your UITextfield/UITextView with TopLayoutGuide/BottomLayoutGuide then you're saying **Keep x distance from screen top(I don't care about where is self.view)**'. In this case your view is moved upwards but textField remains at same position and keeping x distance from screen top.

 To fix it, just let IQKeyboardManager know the constraint which is pinned with **TopLayoutGuide/BottomLayoutGuide**, just map **TopLayoutGuide/BottomLayoutGuide** constraint with **IQLayoutGuideConstraint**. Here is the screenshot:-
![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/TopLayoutGuideDirectMapping.jpg)

 If your textFields are inside any UIView and your UIView is pinned with **TopLayoutGuide/BotomLayoutGuide** then also you can map **TopLayoutGuide/BottomLayoutGuide** constraint with **IQLayoutGuideConstraint**. here are the screenshots:-
![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/TopLayoutGuideIndirectMapping.jpg)
![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/BottomLayoutGuideIndirectMapping.jpg)


#### Working with Full Screen UITextView:-

 Often we have a situation where a **full screen UITextView** need to show in full screen mode with keyboard handling. To deal with this kind of situation, here is an easy workaround.

 Assuming that `UITextView` needs to be displayed in full screen within a ViewController View and default UINavigationBar of UINavigationController is displaying at at the top of ViewController. Assuming that `Adjust Sroll View Insets` checkmark is ticked. Add these constraint to UITextView:-

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/FullScreenTextView.jpeg)

 - Top Space to SuperView
 - Leading Space to SuperView
 - Trailing Space to SuperView
 - Bottom Space to Bottom Layout Guide (Important)

 Connect bottom layout guide constraint with `IQLayoutGuideConstraint` and that's all. You have a full working **UITextViewController**.

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/FullScreenTextViewStoryboard.jpeg)


#### Working with Chat Screen UITableView:-

 Often we have another situation where we have to implement our own **Chat Style Screen** with keyboard handling. To deal with this kind of situation, here is an easy workaround.

 Assuming that `ChatViewController` is subclass of `UIViewController` not `UITableViewController`. Assuming that `ChatViewController` has `UITableView` at top and `UIView` at bottom. Bottom UIView contains a `UITextField/UITextView` with a `Send` button. Assuming that default UINavigationBar of UINavigationController is displaying at at the top of `ChatViewController`. Assuming that `Adjust Sroll View Insets` checkmark is ticked. Add these constraint to UITableView:-

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/ChatScreenTableView.jpg)

 - Top Space to SuperView
 - Leading Space to SuperView
 - Trailing Space to SuperView
 - Bottom Space to bottom UIView

Add thse constraint to bottom UIView
 - Leading Space to SuperView
 - Trailing Space to SuperView
 - Bottom Space to Bottom Layout Guide (Important)

 Connect bottom layout guide constraint with `IQLayoutGuideConstraint`.

 Map UITextField/UITextView Outlet with a textField object in `ChatViewController`.

 Add this two line in viewDidLoad
 
```objc
    self.textField.inputAccessoryView = [[UIView alloc] init];  //This will remove toolbar which have done button.
    self.textField.keyboardDistanceFromTextField = 8; //This will modify default distance between textField and keyboard. For exact value, please manually check how far your textField from the bottom of the page. Mine was 8pt.
```

That's all. You have a working keyboard handling with **ChatViewController**.

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/ChatScreenTableView.jpg)


#### Disable for a ViewController:-

 If you would like to disable `IQKeyboardManager` for a particular ViewController then register ViewController with `-(void)disableDistanceHandlingInViewControllerClass:(Class)disabledClass` method in AppDelegate.([#117](https://github.com/hackiftekhar/IQKeyboardManager/issues/117),[#139](https://github.com/hackiftekhar/IQKeyboardManager/issues/139))

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] disableDistanceHandlingInViewControllerClass:[ViewController class]];
    return YES;
}
```

#### Disable toolbar for a ViewController:-

If you would like to disable `Auto Toolbar` for a particular ViewController then register ViewController with `-(void)disableToolbarInViewControllerClass:(Class)disabledClass` method in AppDelegate.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[ViewController class]];
    return YES;
}
```

#### Considering Previous/Next buttons for textField inside customViews:-

If your textFields are on different customView and do not show previous/next to navigate between textField. Then you should create a SpecialView subclass of UIView, then put all customView inside SpecialView, then register SpecialView class using `-(void)considerToolbarPreviousNextInViewClass:(Class)toolbarPreviousNextConsideredClass` method in AppDelegate.([#154](https://github.com/hackiftekhar/IQKeyboardManager/issues/154), [#179](https://github.com/hackiftekhar/IQKeyboardManager/issues/179))

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] considerToolbarPreviousNextInViewClass:[SpecialView class]];
    return YES;
}
```

#### Keyboard Return Key Handling:-
  If you would like to implement keyboard **Return Key** as **Next/Done** button, then you can use **IQKeyboardReturnKeyHandler**.([#38](https://github.com/hackiftekhar/IQKeyboardManager/issues/38), [#63](https://github.com/hackiftekhar/IQKeyboardManager/issues/63))

  1) Create an instance variable of `IQKeyboardReturnKeyHandler` and instantiate it in `viewDidLoad` with ViewController object like this:-

```objc
@implementation ViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
}
```

   It assign all the responderView delegates to self, and change keybord Return Key to Next key.

2) set instance variable to nil in `dealloc` method.

```objc
-(void)dealloc
{
    returnKeyHandler = nil;
}
```


#### UIToolbar(IQToolbar):-

1) If you don't want to add automatic toolbar over keyboard for a specific textField then you should add a UIView as it's toolbar like this:-([#89](https://github.com/hackiftekhar/IQKeyboardManager/issues/89))

```objc
textField.inputAccessoryView = [[UIView alloc] init];
```

2) If you need your own control over the previous/next/done button then you should use the UIView category methods to add toolbar over your textField. The UIView category methods are defined in `IQUIView+IQKeyboardToolbar.h` file. You can use them like this:-([#40](https://github.com/hackiftekhar/IQKeyboardManager/issues/40))

```objc
-(void)viewDidLoad
{
    [super viewDidLoad];

    //Adding done button for textField1
    [textField1 addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];

    //Adding previous/next/done button for textField2
    [textField2 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];

    //Adding cancel/done button for textField3
    [textField3 addCancelDoneOnKeyboardWithTarget:self cancelAction:@selector(cancelAction:) doneAction:@selector(doneAction:)];
}

/*!	previousAction. */
-(void)previousAction:(id)button
{
    //previousAction
}

/*!	nextAction. */
-(void)nextAction:(id)button
{
    //nextAction
}

/*!	doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton
{
    //doneAction
}

/*!	cancelAction. */
-(void)cancelAction:(UIBarButtonItem*)barButton
{
    //cancelAction
}

```

#### Doing custom work on textField with returning NO in `textFieldShouldBeginEditing:` delegate:-

Generally if developer need to perform some custom task on a particular textField click, then usually developer write their custom code inside ***textFieldShouldBeginEditing:*** and returning NO for that textField. But if you are using IQKeyboardManager, then IQKeyboardManager also asks textField to recognize it can become first responder or not using ***canBecomeFirstResponder*** in `IQUIView+Hierarchy` category, and textField asks it's delegate to respond from `textFieldShouldBeginEditing:`, so this method is called for each textField everytime when a textField becomeFirstResponder. Unintentionally custom code runs multiple times even when we do not touch the textField to become it as first responder. To overcome this situation please use ***isAskingCanBecomeFirstResponder*** BOOL property to check that the delegate is called by IQKeyboardManager or not. ([#88](https://github.com/hackiftekhar/IQKeyboardManager/issues/88))

1) You may need to import `IQUIView+Hierarchy` category

```objc
#import "IQUIView+Hierarchy.h"
```

2) check for ***isAskingCanBecomeFirstResponder*** in `textFieldShouldBeginEditing:` delegate.

```objc
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == customWorkTextField)
    {
        if (textField.isAskingCanBecomeFirstResponder == NO)
        {
            //Do your work on tapping textField.
            [[[UIAlertView alloc] initWithTitle:@"IQKeyboardManager" message:@"Do your custom work here" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }

        return NO;
    }
    else    return YES;
}
```
