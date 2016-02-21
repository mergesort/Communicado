Pod::Spec.new do |spec|
  spec.name         = 'Communicado'
  spec.version      = '1.3'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage     = 'https://github.com/mergesort/Communicado'
  spec.authors      =  { 'Joe Fabisevich' => 'github@fabisevi.ch' }
  spec.summary      = 'The easiest way to share from your app to anywhere, because you\'ve got so much to say!'
  spec.source       =   { :git => 'https://github.com/mergesort/Communicado.git', :tag => "#{spec.version}" }
  spec.source_files = 'src/UIViewController+Sharing.swift'
  spec.framework    = 'Foundation'
  spec.requires_arc = true
  spec.social_media_url = 'https://twitter.com/mergesort'
  spec.ios.deployment_target = '8.0'

  s.subspec 'FacebookSDK' do |ss|
    ss.source_files = 'src/UIViewController+Sharing.swift', 'src/FacebookSDK/UIViewController+FacebookAppSharing.swift'
    ss.dependency 'FBSDKCoreKit'
  end
end