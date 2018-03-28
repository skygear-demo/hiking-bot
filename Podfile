use_frameworks!
platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!

target 'hikingbot' do
  # Pods for hikingbot
  pod 'SKYKit'
  pod 'SKYKitChat', :path => './'
  pod 'Kingfisher', '~> 4.0'
  pod 'JSQMessagesViewController'
  pod 'ApiAI'
  pod 'Alamofire'

end

# The SWIFT_VERSION setting is inserted into pod targets, otherwise, the
# SKPhotoBrowser pod complains when compiling. 
post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.0'
      end
  end
end