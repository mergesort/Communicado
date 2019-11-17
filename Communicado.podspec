Pod::Spec.new do |spec|
  spec.name         = 'Communicado'
  spec.version      = '3.2'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage     = 'https://github.com/mergesort/Communicado'
  spec.authors      =  { 'Joe Fabisevich' => 'github@fabisevi.ch' }
  spec.summary      = 'The easiest way to share from your app to anywhere, because you\'ve got so much to say!'
  spec.source       =   { :git => 'https://github.com/mergesort/Communicado.git', :tag => "#{spec.version}" }
  spec.source_files = 'Source/*.swift'
  spec.framework   = 'Foundation', 'MessageUI', 'Photos', 'Social'
  spec.requires_arc = true
  spec.social_media_url = 'https://twitter.com/mergesort'
  spec.ios.deployment_target = '9.0'
  spec.swift_version = '5.1'
end
