Pod::Spec.new do |s|
	s.name = "IQKeyboardManagerSwift"
	s.version = "3.3.3"
	s.summary = "Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView."
	s.homepage = "https://github.com/hackiftekhar/IQKeyboardManager"
	s.screenshots = "https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/IQKeyboardManagerScreenshot.png"
	s.license = 'MIT'
	s.author = { "Iftekhar Qurashi" => "hack.iftekhar@gmail.com", "OCTO Technology" => "team.mobilite@octo.com" }
	s.platform = :ios, '8.0'
	s.source = { :git => "https://github.com/octo-technology/IQKeyboardManager.git", :tag => "v3.3.2" }
	s.source_files = 'Classes', 'IQKeyboardManagerSwift/**/*.{swift}'
	s.resources = "IQKeyboardManagerSwift/Resources/IQKeyboardManager.bundle"
	s.requires_arc = true
end
