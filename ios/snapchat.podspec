#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'snapkit'
  s.version          = '0.0.1'
  s.summary          = 'Interface with Snapchat\'s SnapKit'
  s.description      = <<-DESC
Interface with Snapchat\'s SnapKit
                       DESC
  s.homepage         = 'https://jacobbrasil.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jacob Brasil' => 'https://jacobbrasil.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

