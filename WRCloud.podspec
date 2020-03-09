#
# Be sure to run `pod lib lint WRCloud.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WRCloud'
  s.version          = '1.0.0'
  s.summary          = '使用CloudKit，缓存服务端需要数据'
  s.description      = '使用CloudKit，上传，下载App中需要的文件。针对无服务端的小项目'

  s.homepage         = 'https://github.com/GodFighter/WRCloud'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GodFighter' => 'xianghui_ios@163.com' }
  s.source           = { :git => 'https://github.com/GodFighter/WRCloud.git', :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/huigedang/home?wvr=5&lf=reg'

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source_files = 'WRCloud/Classes/*.swift'
  
end
