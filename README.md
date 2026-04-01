# LepaoHelper

LepaoHelper is a Theos tweak project for iOS that customizes and extends behavior in the target app.

## Disclaimer

This repository is for reverse-engineering learning and technical research only.
You are responsible for complying with local laws, your school/company policies, and the target app's Terms of Service.

## Features

- Runtime hook-based behavior customization
- UI control panel in-app
- Configurable runtime options

## Project Structure

- `LepaoAntiCheat.xm`: Main hook implementation
- `Makefile`: Theos build entry
- `control`: Debian package metadata
- `LepaoHelper.plist`: Substrate filter configuration

## Requirements

- macOS
- Theos toolchain
- iOS device/environment compatible with your setup

## Build

```bash
make package
```

## Install

Use your existing Theos deployment workflow after packaging.

## Contributing

Please read `CONTRIBUTING.md` before submitting changes.

## Security

Please report sensitive issues through private channels described in `SECURITY.md`.

## License

MIT License. See `LICENSE` for details.
