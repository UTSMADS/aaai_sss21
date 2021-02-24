# Uncomment the next line to define a global platform for your project
platform :ios, '13'

# workspace '../SMADS.xcworkspace'

inhibit_all_warnings!
use_frameworks!

target 'SMADS Manager' do
    pod 'StompClientLib', '~> 1.4.0'
    pod 'GoogleSignIn'
end

target 'SMADS Customer' do
    pod 'StompClientLib', '~> 1.4.0'
    pod 'GoogleSignIn'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
