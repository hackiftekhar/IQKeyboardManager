Pod::Spec.new do |s|
  s.name        = "IQKeyboardManager"
  s.version     = "3.2.0"
  s.summary     = "Keyboard TextField Manager"
  s.homepage    = "https://github.com/hackiftekhar/IQKeyboardManager"
  s.screenshots = "https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/KeyboardTextFieldDemo/Screenshot/IQKeyboardManagerScreenshot.png"
  s.license     = "MIT"
  s.authors     = { "Iftekhar Qurashi" => "hack.iftekhar@gmail.com" }
  s.platforms   = :ios, '5.0'
  s.source      = {:git => "https://github.com/phamquy/IQKeyboardManager.git", :tag => "nk1.8" }
  s.source_files= 'Classes', 'IQKeyBoardManager/*.{h,m}'
  s.resources   = 'IQKeyBoardManager/IQKeyboardManager.bundle'
  s.requires_arc= true
end
