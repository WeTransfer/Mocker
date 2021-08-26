Pod::Spec.new do |spec|
  spec.name             = 'Mocker'
  spec.version          = '2.5.3'
  spec.summary          = 'Mock data requests using a custom URLProtocol and run them offline.'
  spec.description      = 'Mocker is a library written in Swift which makes it possible to mock data requests using a custom URLProtocol and run them offline.'

  spec.homepage         = 'https://github.com/WeTransfer/Mocker'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors           = {
    'Antoine van der Lee' => 'ajvanderlee@gmail.com',
    'Samuel Beek' => 'ik@samuelbeek.com'
  }
  spec.source           = { :git => 'https://github.com/WeTransfer/Mocker.git', :tag => spec.version.to_s }
  spec.social_media_url = 'https://twitter.com/WeTransfer'

  spec.ios.deployment_target = '10.0'
  spec.source_files = 'Sources/**/*'
  spec.swift_version = '5.1'
  spec.weak_framework = 'XCTest'
end
