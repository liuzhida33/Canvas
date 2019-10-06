
Pod::Spec.new do |s|
  s.name             = 'ImageBoard'
  s.version          = '1.0.0'
  s.summary          = '图片涂鸦板'

  s.description      = <<-DESC
图片涂鸦板、Swift项目、支持iOS10+
                       DESC

  s.homepage         = 'https://github.com/liuzhida33/ImageBoard'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuzhida33' => 'liuzhida33@gmail.com' }
  s.source           = { :git => 'https://github.com/liuzhida33/ImageBoard.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = "5.0"

  s.source_files = 'ImageBoard/Classes/**/*'
  
  s.resource_bundles = {
    'ImageBoard' => ['ImageBoard/Assets/*.png']
  }

end
