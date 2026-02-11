#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint plugin_mappintelligence.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'plugin_mappintelligence'
  s.version          = '0.0.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://mapp.com/mapp-cloud/analytics/app-analytics/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mapp Digital' => 'stefan.stevanovic@mapp.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.vendored_frameworks = 'Frameworks/MappIntelligenceiOS.xcframework'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/plugin_mappintelligence/Frameworks/**" "$(PODS_ROOT)/../.symlinks/plugins/plugin_mappintelligence/ios/Frameworks/**"',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/plugin_mappintelligence/Frameworks" "$(PODS_ROOT)/../.symlinks/plugins/plugin_mappintelligence/ios/Frameworks"', 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
