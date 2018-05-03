# XXTouch

This is XXTouch (iOS Client) v1.1, work with XXTouch (iOS Daemon) 1.1.x.

XXTouch iOS 客户端 1.1 版本，与 XXTouch 服务 1.1.x 协同工作。


## 说明

该源代码工程是 XXTouch 原始旧版本工程，采用 XXTouch OpenAPI 与服务进行通讯控制。
您可以进行 OEM 定制，但定制时请务必修改客户端内的说明文档、关于页面及联系方式。XXTouch 不会对该源代码工程的修改、编译、安装与再发布提供任何技术支持，亦不会从中收取任何利益。


## 部署

- Xcode 8.0 及以上
- iOS 7.0 及以上

```shell
git clone https://github.com/XXTouchAssistant/XXTouchApp.git
cd XXTouchApp
open XXTouchApp.xcworkspace
```

*请勿运行 `pod install`，因为该仓库已经自带修改后的 Cocoapods 第三方库。*


## 这里面有什么

- 简易的文件管理器，支持批量拷贝/剪切/符号链接/查看属性/压缩解压
- 许多文件查看器，支持代码查看高亮/多媒体播放/文档浏览/网页浏览
- 简易的 Lua 编辑器，支持代码高亮/修改字体/主题/缩进/快捷键盘
- 简易的图片取色工具/代码片段生成工具
- 动态界面生成库 (XUI 的前身)
- XXTouch OpenAPI 的使用示例

当然 XXTouch (XXTExplorer) 1.2.x 中这些东西会更棒。最新版为了保持一定的竞争力，暂时是**不开源**的。


## 免责声明

您知晓并确认，不允许利用该源代码工程从事任何违反中华人民共和国法律法规或侵犯第三方合法权益的行为。因修改、编译、安装与再发布等行为造成的任何损失，我们无须对您或任何第三方承担任何责任。您应当同时负责赔偿 XXTouch 遭受的全部损失，包括但不限于任何的赔偿金、补偿金、违约金、罚款、诉讼费、调查取证费、公证费、律师费等。


## License

XXTouch (iOS Client) is available under the MIT license. See the LICENSE file for more info.

