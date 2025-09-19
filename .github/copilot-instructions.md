# IQKeyboardManager

IQKeyboardManager is an iOS library available in both Objective-C and Swift versions that provides automatic keyboard management functionality. The library includes comprehensive demo applications and supports CocoaPods, Carthage, and Swift Package Manager.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Requirements
- **CRITICAL**: This is an iOS-specific library that requires macOS with Xcode for full development
- Minimum Xcode 15 for Demo projects
- Minimum Xcode 13 for library development  
- iOS 13.0+ target for both Objective-C and Swift versions
- Swift 5.7+ supported

### Dependency Management and Setup
**ALWAYS** perform these steps in order for fresh repository setup:

1. **Install CocoaPods** (on macOS only):
   ```bash
   gem install cocoapods --user-install
   export PATH=$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH
   ```

2. **Install dependencies** (macOS only - NEVER CANCEL - takes 5-10 minutes):
   ```bash
   cd /path/to/IQKeyboardManager
   pod install --repo-update
   ```
   Set timeout to 15+ minutes. This downloads all dependencies including SwiftLint.
   **NOTE**: `pod install` fails in sandboxed environments due to network restrictions.

3. **Verify Swift Package Manager dependencies** (works on both macOS and Linux - takes ~2 seconds):
   ```bash
   swift package resolve
   ```
   This resolves all SPM dependencies successfully even on Linux.

4. **Show dependency tree**:
   ```bash
   swift package show-dependencies
   ```

### Build and Test
**IMPORTANT**: Full builds require macOS with Xcode installed. Linux environments can only validate Swift Package Manager dependency resolution.

#### On macOS with Xcode:
1. **Build Demo Applications** (NEVER CANCEL - takes 10-15 minutes):
   ```bash
   cd /path/to/IQKeyboardManager
   xcodebuild -workspace Demo.xcworkspace -scheme DemoSwift -sdk iphonesimulator clean build
   xcodebuild -workspace Demo.xcworkspace -scheme DemoObjC -sdk iphonesimulator clean build
   ```
   Set timeout to 30+ minutes for each command.

2. **Run UI Tests** (NEVER CANCEL - takes 15-20 minutes):
   ```bash
   xcodebuild -workspace Demo.xcworkspace -scheme DemoObjC -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' test
   ```
   Set timeout to 45+ minutes.

#### On Linux (Limited Validation):
- **Dependency resolution works**: `swift package resolve` (takes ~2 seconds)
- **Dependency analysis works**: `swift package show-dependencies`
- **Building FAILS**: `swift build` fails with "no such module 'UIKit'" error (expected)
- **Cannot run simulators or UI tests** 
- **CocoaPods may fail** due to network restrictions in sandboxed environments

### Linting and Code Quality
1. **SwiftLint** (macOS only - installed via CocoaPods):
   ```bash
   Pods/SwiftLint/swiftlint
   ```
   **NOTE**: Not available on Linux or when CocoaPods installation fails.
   
2. **Check formatting** before commits (macOS only):
   ```bash
   Pods/SwiftLint/swiftlint --fix
   ```

3. **Manual code review** (any platform):
   - Review Swift files in `IQKeyboardManagerSwift/`
   - Check Objective-C files in `IQKeyboardManager/`
   - Verify integration examples in demo apps

## Validation

### Required Manual Testing Scenarios
**ALWAYS** test these scenarios after making changes to keyboard management:

1. **Basic Keyboard Management**:
   - Run DemoSwift app in iOS Simulator
   - Navigate to "UITextField/UITextView example"
   - Tap text fields - verify keyboard shows/hides smoothly
   - Verify toolbar appears above keyboard with Previous/Next/Done buttons
   - Test scrolling behavior when keyboard appears

2. **Configuration Testing**:
   - Open Settings in demo app
   - Toggle "Enable IQKeyboardManager" - verify keyboard behavior changes
   - Test different toolbar management options
   - Verify appearance customization works

3. **Both Platform Testing**:
   - Test identical scenarios in both DemoSwift and DemoObjC apps
   - Ensure Objective-C and Swift versions behave identically

### CI Validation
The project uses Travis CI (`.travis.yml`) with these validation steps:
```bash
xcodebuild -workspace Demo.xcworkspace -scheme DemoObjC -sdk iphonesimulator
xcodebuild -workspace Demo.xcworkspace -scheme DemoSwift -sdk iphonesimulator
```

**Always** run these commands locally before committing changes.

## Key Project Structure

### Library Files
- `IQKeyboardManager/` - Objective-C version (legacy)
- `IQKeyboardManagerSwift/` - Swift version (current)
  - `IQKeyboardManager/` - Core keyboard management
  - `Appearance/` - UI appearance customization
  - `Resign/` - Keyboard dismissal handling
  - `IQKeyboardToolbarManager/` - Toolbar management

### Demo Applications  
- `Demo/Swift_Demo/` - Swift demonstration app (45 Swift files)
- `Demo/Objective_C_Demo/` - Objective-C demonstration app (28 Objective-C files)
- `DemoObjCUITests/` - UI test suite

### Dependencies (Swift Package Manager)
The Swift version depends on separate modular libraries:
- IQKeyboardNotification (1.0.5+)
- IQTextInputViewNotification (1.0.8+) 
- IQKeyboardToolbarManager (1.1.3+)
- IQKeyboardReturnManager (1.0.5+)
- IQTextView (1.0.5+)

## Platform-Specific Instructions

### macOS Development
- Use Xcode 15+ for demo projects
- Open `Demo.xcworkspace` (NOT `Demo.xcodeproj`)
- Build times: 10-15 minutes for clean builds
- UI test runs: 15-20 minutes

### Linux Development (Limited)
- Can validate Swift Package Manager dependencies only
- Cannot build iOS targets or run simulators
- Use for dependency analysis and non-iOS-specific code review only

## Validated Commands and Timing

### Commands That Work on Any Platform
```bash
# Fast dependency resolution (~2 seconds)
swift package resolve

# Show dependency tree (~1 second)
swift package show-dependencies

# Basic file exploration and structure analysis
find . -name "*.swift" | wc -l  # Count Swift files
find . -name "*.m" | wc -l      # Count Objective-C files
```

### Commands That Work Only on macOS
```bash
# CocoaPods installation (5-10 minutes)
pod install --repo-update

# Xcode builds (10-15 minutes each)
xcodebuild -workspace Demo.xcworkspace -scheme DemoSwift -sdk iphonesimulator clean build
xcodebuild -workspace Demo.xcworkspace -scheme DemoObjC -sdk iphonesimulator clean build

# UI Tests (15-20 minutes)
xcodebuild -workspace Demo.xcworkspace -scheme DemoObjC -sdk iphonesimulator test
```

### Commands That Fail on Linux (Expected)
```bash
# Fails with "no such module 'UIKit'" error
swift build

# May fail due to network restrictions
pod install --repo-update
```

## Common Tasks

### Basic Usage Integration
**Swift**:
```swift
import IQKeyboardManagerSwift

// In AppDelegate.swift
IQKeyboardManager.shared.isEnabled = true
IQKeyboardManager.shared.enableAutoToolbar = true
```

**Objective-C**:
```objc
#import <IQKeyboardManager/IQKeyboardManager.h>

// In AppDelegate.m
[[IQKeyboardManager sharedManager] setEnable:YES];
```

### Installation Methods
1. **CocoaPods**: `pod 'IQKeyboardManagerSwift'` or `pod 'IQKeyboardManager'`
2. **Swift Package Manager**: `https://github.com/hackiftekhar/IQKeyboardManager.git`
3. **Carthage**: `github "hackiftekhar/IQKeyboardManager"`

### Documentation Locations
- `Documentation/` - Migration guides for major versions
- `README.md` - Installation and basic usage
- `CONTRIBUTING.md` - Development guidelines
- Demo apps serve as comprehensive usage examples