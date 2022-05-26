Pod::Spec.new do |s|
  s.name             = 'Canvas'
  s.version          = '1.2.1'
  s.summary          = 'This is a canvas framework'

  s.description      = <<-DESC
This is a canvas framework
                       DESC

  s.homepage         = 'https://github.com/liuzhida33/Canvas'
  s.license          = { :type => 'MIT' }
  s.author           = { 'liuzhida33' => 'liuzhida33@gmail.com' }
  s.source           = { :git => 'https://github.com/liuzhida33/Canvas.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version    = '5.0'
  s.requires_arc     = true
  s.source_files = 'Canvas/Source/*/*.{swift}', 'Canvas/Source/ToolBar/ColorPanel/*.{swift}'
  
  s.resource_bundles = {
    'Canvas' => ['Canvas/Source/Resources/*']
  }
  
end
