# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'EVE ESI' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
source 'https://github.com/CocoaPods/Specs.git'
  use_frameworks!

  pod 'Alamofire', '~> 4.5'
  pod 'AlamofireImage', '~> 3.3'
  pod "AlamofireObjectMapper", :git => 'https://github.com/tristanhimmelman/AlamofireObjectMapper.git', :branch => 'swift-4'
  pod 'Eureka'
  pod 'NVActivityIndicatorView'
  pod 'PopupDialog', '~> 0.6'
  pod 'Charts'
  pod 'GSTouchesShowingWindow-Swift'

  # Pods for EVE ESI

  target 'EVE ESITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'EVE ESIUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
