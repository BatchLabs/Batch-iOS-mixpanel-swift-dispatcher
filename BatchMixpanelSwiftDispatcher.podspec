Pod::Spec.new do |s|
  s.name             = 'BatchMixpanelSwiftDispatcher'
  s.version          = '4.0.0'
  s.summary          = 'Batch.com Events Dispatcher Mixpanel (Swift) implementation.'

  s.description      = <<-DESC
  A ready-to-go event dispatcher for the Mixpanel Swift SDK. Requires the Batch iOS SDK.
                       DESC

  s.homepage         = 'https://batch.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Batch.com' => 'support@batch.com' }
  s.source           = { :git => 'https://github.com/BatchLabs/Batch-iOS-mixpanel-swift-dispatcher.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.platforms = {
    "ios" => "11.0"
  }
  s.swift_version = ['5.0', '5.1', '5.2', '5.3']

  s.requires_arc = true
  s.static_framework = true
  
  s.dependency 'Batch', '>= 1.20'
  s.dependency 'Mixpanel-swift'
  
  s.source_files = 'BatchMixpanelSwiftDispatcher/Classes/**/*'
end
