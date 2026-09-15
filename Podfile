# 全局申明最低平台：iOS 15.0
platform :ios, '15.0'

target 'Demo' do

# 若需静态库链接（优化启动速度），可改为 use_framework!
use_frameworks! :linkage => :static

# 开启模块化头文件，混编 OC 依赖是更稳定，无需手动桥接文件
use_modular_headers!

# ====== 业务依赖库 ======
# Swift 库
pod 'Alamofire'
pod 'SnapKit'
pod 'Kingfisher'
pod 'GRDB.swift'
# OC 库（Swift 可直接 import 调用）

end

# 安装后钩子：统一所有 Pod 的编译配置，适配 Swift 与新版 Xcode
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 1. 强制所有 Pod 对齐最低部署版本 15.6，批量消除版本警告
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'

      # 2. 统一 Swift 编译版本（可选，Xcode 15+ 自动兼容，老库报错时开启）
      # config.build_settings['SWIFT_VERSION'] = '5.10'

      # 3. 关闭脚本沙盒，解决老旧 Pod 的脚本执行权限报错
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'

      # 4. 禁用 Pod 库单独签名，避免第三方库签名冲突
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'

      # 5. Debug 模式仅编译当前架构，提升 Swift 编译速度
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
end
