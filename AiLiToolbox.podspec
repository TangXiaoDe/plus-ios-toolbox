
Pod::Spec.new do |spec|
  spec.name             = 'AiLiToolbox'
  spec.version          = '0.1.0'
  spec.summary          = 'Simple toolbox.'
  spec.description      = <<-DESC
    * 该工具库实现了和ThinkSNS + 服务器相关的通讯协议
    * 该工具库存储了开发实践中好用的相关函数
                       DESC

  spec.homepage         = 'https://github.com/zhiyicx/AiLiToolbox'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'Lip Young' => 'mainbundle@gmail.com' }

  spec.source           = { :git => 'https://github.com/zhiyicx/AiLiToolbox.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '8.0'

  spec.default_subspecs = 'Toolbox'
  spec.subspec 'Toolbox' do |toolbox|
    toolbox.source_files = 'AiLiToolbox/**/*.{swift}'
  end

end
