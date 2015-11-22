Pod::Spec.new do |s|
  s.name = 'LCT-TGCameraViewController'
  s.version = '2.2.2'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Custom camera with AVFoundation. Beautiful, light and easy to integrate with iOS projects.'
  s.homepage = 'https://github.com/tdginternet/TGCameraViewController'
  s.screenshot  = "http://s28.postimg.org/eeli1omct/TGCamera_View_Controller.png"
  
  s.requires_arc = true
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  
  s.authors = { 'Bruno Tortato Furtado' => 'bruno@furtado.me', 'Eddie Li' => 'eli@sandsmedia.com' }
  
  s.ios.frameworks = 'AssetsLibrary', 'AVFoundation', 'CoreImage', 'Foundation', 'MobileCoreServices', 'UIKit'
  s.source_files = 'TGCameraViewController/**/*.{h,m}'
  s.resources = ['TGCameraViewController/**/*.xib', 'TGCameraViewController/**/*.xcassets', 'TGCameraViewController/Resources/TGCameraViewController.bundle']
  s.source = { :git => 'https://github.com/eddielisands/TGCameraViewController.git', :tag => s.version }  
end
