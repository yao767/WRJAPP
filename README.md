# 护花使者——植保无人机适配系统 APP（MVP）

一个面向植保无人机场景的 Flutter MVP 应用，当前以 Android 演示为主，iOS 可复用同一套代码。

## 项目定位
- 目标：在“无后端、低成本”前提下，验证任务配置与作业建议闭环。
- 当前阶段：规则驱动建议 + 本地数据存储 + 设备连接接口预留。
- 适用场景：课程设计、毕业设计初版、早期演示原型。

## 已实现功能
- 登录/注册：本地账号体系（`shared_preferences`）。
- 登录会话恢复：重启应用后自动恢复最近一次登录用户。
- 主页面：创建/编辑飞行任务，查看当前任务摘要。
- 任务编辑：配置作物、时节、作业类型、起飞/运作/降落状态。
- 环境因子输入：湿度、雨量、光照。
- 一键建议：根据作物+时节+环境因子自动推荐高度/速度/角度/模式。
- 参数保存：保存为“最近一次任务”，下次启动自动加载。
- 设置页面：全局参数调节 + 设备扫描/连接/断开 + 模拟参数下发。
- 全局参数联动：设置页保存后，任务编辑页默认读取全局高度/速度/角度。
- 任务历史列表：主页展示本地历史任务，支持一键设为当前任务。
- 关于页面：版本信息、联系方式、操作说明。

## 页面流程
1. 登录页：登录或注册。
2. 主页：点击“+”进入任务编辑。
3. 任务编辑页：填写参数后点击“一键建议并设置参数”。
4. 保存任务后返回主页，历史任务列表会自动新增一条记录。
5. 设置页可模拟连接遥控器并下发参数。

## 建议规则说明（本地）
建议由 `SuggestionService` 在本地实时计算，核心输入包括：
- 作物类型：水稻、果树等会影响高度与速度基准。
- 时节：夏季/冬季会微调速度与角度。
- 环境因子：湿度、雨量、光照影响风险等级和作业模式。
- 任务类型：喷洒/除草/杀菌会对建议参数做差异化调整。

输出包括：
- 建议摘要
- 风险等级
- 推荐运作模式
- 推荐高度 / 速度 / 角度（并限制在安全区间）

## 技术栈
- Flutter 3（Material 3）
- 状态管理：`provider`
- 本地存储：`shared_preferences`

## 数据存储（当前版本）
- `users`：用户名-密码映射（明文本地存储，仅用于 MVP 演示）。
- `current_user`：当前登录用户（用于会话恢复）。
- `latest_task`：最近一次任务 JSON。
- `task_history`：最近 50 条历史任务列表（JSON 数组）。
- `global_flight_settings`：全局工作模式、高度、速度、角度。

> 注意：当前实现不包含服务端鉴权、加密与多设备同步。

## 目录结构
```
lib/
   models/      # 数据模型
   pages/       # 页面 UI
   services/    # 业务服务（鉴权/任务/建议/设备连接）
   state/       # 全局状态（AppState）
```

## 本地运行
1. 安装 Flutter SDK（建议 stable）。
2. 在项目根目录执行：

```bash
flutter pub get
flutter run
```

## 无需本机 Flutter 的 APK 打包（推荐）
如果本机无法安装 Flutter，可使用仓库内已提供的 GitHub Actions 自动构建：

1. 将项目推送到 GitHub 仓库（建议使用 `main` 分支）。
2. 打开仓库的 **Actions** 页面。
3. 运行工作流：`Build Android APK`（可手动触发 `workflow_dispatch`）。
4. 构建完成后在该次运行的 **Artifacts** 下载 `app-debug-apk`。
5. 解压后得到 `app-debug.apk`，拷贝到安卓手机安装测试。

> 说明：当前输出为调试包（debug），用于快速安装验证功能。

## 生成可分发的签名 Release APK
仓库已提供工作流：`Build Signed Release APK`。

### 1) 准备签名文件
先在任意可用 JDK 环境执行（仅一次）：

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

再将 keystore 转为 Base64（Windows PowerShell）：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("./upload-keystore.jks")) | Set-Content ./keystore.base64.txt
```

### 2) 在 GitHub 仓库配置 Secrets
进入仓库 `Settings -> Secrets and variables -> Actions`，新增：

- `ANDROID_KEYSTORE_BASE64`：`keystore.base64.txt` 的完整内容
- `ANDROID_KEYSTORE_PASSWORD`：keystore 密码
- `ANDROID_KEY_ALIAS`：别名（例如 `upload`）
- `ANDROID_KEY_PASSWORD`：key 密码

### 3) 运行发布工作流
1. 打开 `Actions` 页面。
2. 手动运行 `Build Signed Release APK`。
3. 构建完成后下载 Artifact：`app-release-apk`。
4. 解压后得到 `app-release.apk`，即可用于正式安装测试。

## 已知限制
- 账号密码仅本地存储，未加密。
- 无后端接口，无法进行任务历史云端同步。
- 蓝牙与飞控链路为模拟接口，未接入真实协议。
- 建议引擎为规则模型，尚未接入气象 API 或机器学习模型。

## 下一步建议
- 接入后端：用户体系、任务历史、设备管理。
- 替换连接层：使用 BLE 插件并对接真实飞控协议。
- 增加安全能力：密码哈希、本地敏感信息保护。
- 升级建议引擎：引入实时天气与地块数据。
