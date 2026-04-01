# LepaoHelper

中文 | [English](#english)

LepaoHelper 是一个基于 Theos 的 iOS Tweak 项目，用于对目标应用进行运行时行为扩展与自定义。

## 免责声明

本仓库仅用于逆向工程学习与技术研究。
请自行确保你的使用行为符合当地法律法规、学校/公司政策以及目标应用的服务条款。

## 功能特性

- 基于 Hook 的运行时行为定制
- 应用内控制面板 UI
- 可配置的运行时选项

## 项目结构

- `LepaoAntiCheat.xm`：主要 Hook 实现
- `Makefile`：Theos 构建入口
- `control`：Debian 包元数据
- `LepaoHelper.plist`：Substrate 过滤配置

## 环境要求

- `macOS`
- `Theos` 工具链
- 与当前配置兼容的 iOS 设备/环境

## 构建

```bash
make package
```

## 安装

打包后使用你现有的 Theos 部署流程进行安装。

## 参与贡献

提交前请阅读 `CONTRIBUTING.md`。

## 安全问题

敏感安全问题请按照 `SECURITY.md` 中的说明通过私下渠道报告。

## 许可证

本项目使用 MIT License，详见 `LICENSE`。

---

## English

LepaoHelper is a Theos tweak project for iOS that customizes and extends behavior in the target app.

### Disclaimer

This repository is for reverse-engineering learning and technical research only.
You are responsible for complying with local laws, your school/company policies, and the target app's Terms of Service.

### Features

- Runtime hook-based behavior customization
- In-app UI control panel
- Configurable runtime options

### Project Structure

- `LepaoAntiCheat.xm`: Main hook implementation
- `Makefile`: Theos build entry
- `control`: Debian package metadata
- `LepaoHelper.plist`: Substrate filter configuration

### Requirements

- `macOS`
- `Theos` toolchain
- iOS device/environment compatible with your setup

### Build

```bash
make package
```

### Install

Use your existing Theos deployment workflow after packaging.

### Contributing

Please read `CONTRIBUTING.md` before submitting changes.

### Security

Please report sensitive issues through private channels described in `SECURITY.md`.

### License

MIT License. See `LICENSE` for details.
