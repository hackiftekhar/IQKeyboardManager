
Pod::Spec.new do |s|

  s.name         = "IQKeyboardManager"
  s.version      = "1.2"
  s.summary      = "Keyboard TextField Manager. We called it 'IQKeyboardManager."
  s.description  = 'Often while developing an app, We ran into an issues where the iPhone UIKeyboard slide up and cover the UITextField/UITextView.'
  s.homepage     = "https://github.com/hackiftekhar/IQKeyboardManager"
  s.screenshots  = "https://github.com/hackiftekhar/IQKeyboardManager/blob/master/KeyboardTextFieldDemo/Screenshot/IQKeyboardManagerScreenshot.png"
  s.license      = 'MIT License'
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "hackiftekhar" => "hack.iftekhar@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/hackiftekhar/IQKeyboardManager.git", :tag => "v1.2" }
  s.source_files  = 'KeyboardTextFieldDemo/IQKeyBoardManager/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
end
