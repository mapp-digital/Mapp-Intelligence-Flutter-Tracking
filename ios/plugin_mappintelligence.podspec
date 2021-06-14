#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint plugin_mappintelligence.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'plugin_mappintelligence'
  s.version          = '0.0.1'
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
  s.dependency 'MappIntelligence' , '5.0.0-beta10'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
