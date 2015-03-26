Pod::Spec.new do |s|
	s.name = "IQKeyboardManager"
	s.version = "3.2.2"
	s.summary = "Keyboard TextField Manager"
	s.homepage = "https://github.com/hackiftekhar/IQKeyboardManager"
	s.screenshots = "https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/KeyboardTextFieldDemo/Screenshot/IQKeyboardManagerScreenshot.png"
	s.license = 'MIT'
	s.author = { "Iftekhar Qurashi" => "hack.iftekhar@gmail.com" }
	s.platform = :ios, '5.0'
	s.source = { :git => "https://github.com/hackiftekhar/IQKeyboardManager.git", :tag => "v3.2.2" }
	s.source_files = 'Classes', 'IQKeyBoardManager/**/*.{h,m}'
	s.resources = "IQKeyBoardManager/Resources/IQKeyboardManager.bundle"
	s.requires_arc = true
end
