# 🇪🇺 BLEUnlock LTS

[English](README.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [Türkçe](README.tr.md) | [Svenska](README.sv.md) | [Dansk](README.da.md) | [Norsk](README.nb.md)

![CI](https://github.com/Altissnono/BLEUnlock-LTS/actions/workflows/test.yml/badge.svg)
[![Latest release](https://img.shields.io/github/v/release/Altissnono/BLEUnlock-LTS?display_name=tag&cacheSeconds=300)](https://github.com/Altissnono/BLEUnlock-LTS/releases/latest)
![GDPR friendly](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%BA-GDPR--friendly-003399?labelColor=FFCC00) ![No telemetry](https://img.shields.io/badge/telemetry-none-brightgreen) ![Languages](https://img.shields.io/badge/languages-10-informational)

BLEUnlock 是一个菜单栏小工具，可根据 iPhone、Apple Watch 或任何低功耗蓝牙（BLE）设备的远近来锁定和解锁您的 Mac。

## 功能

- 无需 iPhone 应用：支持 iPhone、Apple Watch 或任何地址固定的 BLE 设备。
- 设备离开时锁定 Mac，设备回来时解锁。
- 两种模式：**锁定并解锁** 或 **仅锁定**（不保存密码，也不需要辅助功能权限）。
- 校准助手、第二台设备（Watch 和 iPhone）、稳健信号滤波。
- 可选：靠近时唤醒、暂停媒体、睡眠或合盖时锁定、蓝牙关闭时锁定。
- 支持 10 种语言。

## 🇪🇺 隐私与 GDPR

- 没有账户、统计分析、广告和崩溃报告。所有数据都留在您的 Mac 上。
- 检查更新是可选的：向 `api.github.com` 发送一次 HTTPS 请求，对方会看到您的 IP 地址。
- 一键清除：安全 → 清除所有数据…
- 密码（仅解锁模式）保存在 macOS 钥匙串中，仅限此设备。
- 没有第三方依赖，启用 Hardened Runtime，并对安全逻辑做了单元测试。

> 以上描述的是应用的技术行为，不是法律认证。详情：[PRIVACY.md](PRIVACY.zh-Hans.md)。

## 系统要求

- 支持低功耗蓝牙的 Mac
- macOS 12（Monterey）或更高版本
- iPhone、Apple Watch 或其他地址固定的 BLE 设备

## 安装

从 [Releases](https://github.com/Altissnono/BLEUnlock-LTS/releases) 下载 zip，解压后移动到“应用程序”文件夹。

> 应用未经过公证：首次打开请右键选择**打开**（或运行 `xattr -dr com.apple.quarantine /Applications/BLEUnlock.app`）。可用 `SHA256SUMS.txt` 或认证校验 zip：`gh attestation verify BLEUnlock-<version>.zip --repo Altissnono/BLEUnlock-LTS`。

## 快速上手

1. 打开应用（菜单栏的锁形图标），首次启动时选择模式。
2. 允许蓝牙和通知。只有选择 **锁定并解锁** 时才需要允许辅助功能。
3. 菜单 → **设备列表**：把 iPhone 或 Apple Watch 靠近 Mac，它会排在列表最上面，选择它。
4. 菜单 → **接近** → **校准信号…**：按两个步骤操作（近处 12 秒，远处 12 秒）。
5. 可选：**第二台设备**，同时监测 Watch 和 iPhone。
6. 测试：走远一些，Mac 会在锁定延迟后锁定。

## 注意事项

- 蓝牙信号很不稳定（Apple Watch 两次读数之间可能相差 25 到 30 dB）。请让阈值与“近处”和“远处”的数值都至少相差 10 dB。无信号超时短于 5 秒可能导致误锁。
- 接近解锁可能被带有合适设备的人模仿。对安全要求高的环境请选择 **仅锁定**。

## 更多信息

- 完整文档（英文）：[README.md](README.md)
- 隐私政策：[PRIVACY.md](PRIVACY.zh-Hans.md)
- 安全审计：[SECURITY_AUDIT.md](SECURITY_AUDIT.md)

---

MIT 许可证。原项目作者 [Takeshi Sone](https://github.com/ts1/BLEUnlock)。由 [Altissnono](https://github.com/Altissnono) 维护。
