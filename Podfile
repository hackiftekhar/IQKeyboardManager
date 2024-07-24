project "Demo.xcodeproj"

install! 'cocoapods',
         :preserve_pod_file_structure => true

use_frameworks!

target "DemoObjC" do
  platform :ios, "13.0"

  pod "IQDropDownTextField"
  pod "IQKeyboardManager", :path => "."

end

target "DemoSwift" do
  platform :ios, "13.0"

  pod "SwiftLint"
  pod "IQDropDownTextFieldSwift"
  pod "IQTextView"
  pod "IQKeyboardReturnManager"
  pod "IQKeyboardToolbarManager"

  pod "IQKeyboardManagerSwift", :path => "."
  pod "IQKeyboardManagerSwift/Resign", :path => "."
  pod "IQKeyboardManagerSwift/Appearance", :path => "."

end

#target "DemoExtension" do
#  platform :ios, "13.0"
#
#  pod "SwiftLint"
#  pod "IQKeyboardManagerSwift", :path => "."
#
#end
