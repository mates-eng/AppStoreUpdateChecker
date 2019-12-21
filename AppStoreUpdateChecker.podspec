Pod::Spec.new do |spec|
  spec.name         = "AppStoreUpdateChecker"
  spec.version      = "1.1"
  spec.summary      = "AppStoreUpdateChecker can notify you if you need to update your app."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  The Update Checker SDK for iOS.
                   DESC
  spec.homepage     = "https://github.com/mates-eng/AppStoreUpdateChecker"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Taisuke Kondo" => "taisuke_kondo@mates-system.com" }
  spec.platform     = :ios, "9.3"
  spec.source       = { :git => "https://github.com/mates-eng/AppStoreUpdateChecker.git", :tag => "#{spec.version}" }
  spec.source_files = 'AppStoreUpdateChecker/**/*.{swift}' 
  spec.swift_version = "5.0"
  spec.requires_arc = true
end
