# SwiftUI Support for IQKeyboardManager

Starting with IQKeyboardManager 7.0, the library provides basic SwiftUI support, primarily focused on toolbar management since SwiftUI handles most keyboard management internally.

## Features

### Toolbar Management for SwiftUI Views

You can now control toolbar behavior for specific SwiftUI view types using the new APIs:

#### Disabling Toolbars for SwiftUI Views

```swift
// Disable toolbars for specific SwiftUI view types
IQKeyboardManager.shared.disabledSwiftUIToolbarTypes.append(MyTextFieldView.self)
IQKeyboardManager.shared.disabledSwiftUIToolbarTypes.append(MyFormView.self)
```

#### Enabling Toolbars for SwiftUI Views

```swift
// Enable toolbars for specific SwiftUI view types (when global toolbar is disabled)
IQKeyboardManager.shared.enabledSwiftUIToolbarTypes.append(MyImportantFormView.self)
```

### Custom UIHostingController

For automatic toolbar management, use the provided `IQSwiftUIHostingController`:

```swift
import SwiftUI
import IQKeyboardManagerSwift

// Your SwiftUI view
struct MyTextFieldView: View {
    @State private var text = ""
    
    var body: some View {
        VStack {
            TextField("Enter text", text: $text)
            TextField("Another field", text: $text)
        }
        .padding()
    }
}

// Use IQSwiftUIHostingController
class MyTextFieldHostingController: IQSwiftUIHostingController<MyTextFieldView> {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: MyTextFieldView())
    }
    
    // Toolbar management is automatic based on SwiftUI content type
    // and the disabledSwiftUIToolbarTypes/enabledSwiftUIToolbarTypes arrays
}
```

### Manual UIHostingController Management

If you prefer to use standard UIHostingController, you can still manage toolbar behavior manually:

```swift
// Disable toolbar for your hosting controller class
IQKeyboardManager.shared.disabledToolbarClasses.append(MyTextFieldHostingController.self)

// Or enable toolbar for your hosting controller class
IQKeyboardManager.shared.enabledToolbarClasses.append(MyTextFieldHostingController.self)
```

## How It Works

1. **SwiftUI View Type Detection**: The system identifies SwiftUI view types specified in the disabled/enabled arrays
2. **Automatic Registration**: When using `IQSwiftUIHostingController`, it automatically checks its content type and registers itself in the appropriate disabled/enabled classes
3. **UIKit Integration**: The SwiftUI toolbar management integrates with the existing UIKit-based toolbar system

## Demo

The included demo application shows SwiftUI toolbar management in action:

1. Navigate to the "Custom" section in the demo app
2. Toggle the "Disable Toolbar" switch - this will also disable toolbars for the SwiftUI `TextFieldView`
3. Navigate to the SwiftUI demo to see the toolbar behavior change

## Migration from UIKit

If you're migrating from UIKit to SwiftUI:

### Before (UIKit)
```swift
IQKeyboardManager.shared.disabledToolbarClasses.append(MyViewController.self)
```

### After (SwiftUI)
```swift
// Option 1: Disable by SwiftUI view type
IQKeyboardManager.shared.disabledSwiftUIToolbarTypes.append(MySwiftUIView.self)

// Option 2: Disable by UIHostingController type
IQKeyboardManager.shared.disabledToolbarClasses.append(MyHostingController.self)
```

## Best Practices

1. **Use Type-Based Management**: Prefer using `disabledSwiftUIToolbarTypes` over manually managing UIHostingController classes
2. **Custom Hosting Controllers**: Use `IQSwiftUIHostingController` for automatic toolbar management
3. **Consistent Naming**: Use clear, descriptive names for your SwiftUI view types to make toolbar management easier

## Limitations

- SwiftUI toolbar management is primarily focused on toolbar enable/disable functionality
- Other IQKeyboardManager features (like distance handling) are less relevant for SwiftUI since SwiftUI handles keyboard avoidance natively
- The SwiftUI view type detection relies on type names, so avoid generic or anonymous view types for toolbar management