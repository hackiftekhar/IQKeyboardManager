# Fix for UIDocumentBrowserViewController Toolbar Disable Issue

## Problem Description

The `disabledToolbarClasses` configuration had no effect on `UIDocumentBrowserViewController` when users tapped the navigation title to rename documents. The toolbar would still appear above the keyboard despite adding `DocumentBrowserViewController.self` to the disabled classes.

## Root Cause

The issue occurred because the toolbar detection logic in `privateIsEnableAutoToolbar` only checked the immediate containing view controller using `viewContainingController()`, not the parent view controller hierarchy.

When a user activates the rename field in `UIDocumentBrowserViewController`, the actual text field is managed by an internal view controller (e.g., `_UIDocumentBrowserInternalController`), not directly by the `DocumentBrowserViewController` class. The original logic would only find this internal controller and wouldn't detect that it's contained within a disabled `DocumentBrowserViewController`.

## Solution

Modified the toolbar enabled/disabled class checking logic to traverse the entire parent view controller hierarchy using `parentViewController`. This ensures that if any parent controller in the hierarchy is in the `disabledToolbarClasses` (or `enabledToolbarClasses`), the appropriate action is taken.

### Changes Made

**File: `IQKeyboardManager/IQKeyboardManager.m`**

In the `privateIsEnableAutoToolbar` method (lines ~527-558):

1. **Enabled Classes Check**: Instead of only checking `textFieldViewController`, now traverses up the parent hierarchy until it finds an enabled class or reaches the root.

2. **Disabled Classes Check**: Similarly traverses the parent hierarchy to check for disabled classes.

### Code Changes

**Before:**
```objc
// Only checked immediate controller
for (Class disabledToolbarClass in _disabledToolbarClasses) {
    if ([textFieldViewController isKindOfClass:disabledToolbarClass]) {
        enableAutoToolbar = NO;
        break;
    }
}
```

**After:**
```objc
// Check current controller and its parent hierarchy
UIViewController *checkController = textFieldViewController;
while (checkController && enableAutoToolbar) {
    for (Class disabledToolbarClass in _disabledToolbarClasses) {
        if ([checkController isKindOfClass:disabledToolbarClass]) {
            enableAutoToolbar = NO;
            break;
        }
    }
    // Move up the hierarchy to check parent controllers
    checkController = checkController.parentViewController;
}
```

## Testing

The fix can be tested by:

1. Creating a subclass of `UIDocumentBrowserViewController`
2. Adding it to `disabledToolbarClasses`:
   ```swift
   IQKeyboardManager.shared.disabledToolbarClasses.append(DocumentBrowserViewController.self)
   ```
3. Tapping the navigation title to rename a document
4. Verifying that the keyboard toolbar no longer appears

## Impact

- **Backward Compatible**: The change maintains all existing functionality
- **Minimal**: Only affects the class checking logic, no API changes
- **Consistent**: Applies the same hierarchy traversal to both enabled and disabled classes
- **General Purpose**: Fixes the issue for any view controller with internal text field management, not just `UIDocumentBrowserViewController`

## Related Issues

This fix resolves any similar issues where text fields are managed by internal view controllers within a disabled/enabled parent controller class.