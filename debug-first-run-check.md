# Debug Session: first-run-check

**Status**: [OPEN]

## 目标
A 全部完成后第一次实跑项目，验证能否启动并发现任何运行时报错。

## 假设（待证伪）

1. **H1: iOS Pod install 失败** — local_auth / flutter_local_notifications / pdf / printing 等原生插件需要 CocoaPods 重新安装，可能存在版本或签名冲突。
2. **H2: Drift 数据库 seed 抛错** — `AppDatabase._seed()` 在迁移阶段执行，若 `_$AppDatabase` 编译期生成代码与手写 schema 对不齐，运行时 `createAll` 会失败。
3. **H3: SplashPage 转场后 ProviderScope 未生效** — `runApp` 用的是 `UncontrolledProviderScope` 而非 `ProviderScope`，splash 内若直接 `ref.watch` 会抛「ProviderScope not found」。
4. **H4: 隐私锁卡死（模拟器无 Face ID）** — `PrivacyService.authenticate` 在不支持 biometric 的模拟器走 fallback 分支，但我已加 `isDeviceSupported() == false` 时直接解锁；可能 `LocalAuthentication` 在 iOS 模拟器上抛 platform exception。
5. **H5: LaunchScreen.storyboard 找不到 brand_logo_calligraphy 资源** — storyboard 引用 `image="brand_logo_calligraphy"`，若 assetset 路径或 Contents.json 拼错，启动会出黑屏 / 崩溃。
6. **H6: UncontrolledProviderScope 与 MaterialApp.router 嵌套** — go_router 的 redirect 需要 ProviderScope；初次 run 时可能未注入。

## 运行时证据

（下方跑起来后填充）

## 结论

（待 fix 后填）

## Cleanup