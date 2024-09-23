Pod::Spec.new do |s|
  s.name         = 'Mocker'
  s.version      = '2.3.0'  # Use the latest version or the desired version
  s.summary      = 'Mocker enables the easy mocking of HTTP requests in Swift.'
  s.description  = <<-DESC
                   Mocker is a lightweight Swift library that enables the easy mocking of HTTP requests. 
                   It's perfect for testing HTTP networking code in Swift applications.
                   DESC
  s.homepage     = 'https://github.com/WeTransfer/Mocker'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'WeTransfer' => 'opensource@wetransfer.com' }
  s.source       = { :git => 'https://github.com/WeTransfer/Mocker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'
  s.macos.deployment_target = '10.15'
  s.swift_version = '5.0'

  s.source_files = [ 'Sources/**/*.swift', 'Tests/**/*.swift' ]

end
