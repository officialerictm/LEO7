# Leonardo AI Universal (LEO7)

<div align="center">
  
```ascii
    __    _______  ____     _   _____    ____  ____   ____ 
   / /   / ____/ / __ \   / | / /   |  / __ \/ __ \ / __ \
  / /   / __/   / / / /  /  |/ / /| | / /_/ / / / // / / /
 / /___/ /___  / /_/ /  / /|  / ___ |/ _, _/ /_/ // /_/ / 
/_____/_____/  \____/  /_/ |_/_/  |_/_/ |_/_____/ \____/  
                                                          
         AI Universal - Deploy Anywhere, Run Everywhere
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-7.0.0-blue.svg)](https://github.com/officialerictm/LEO7)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)](https://github.com/officialerictm/LEO7)

</div>

## 🌟 What is Leonardo AI Universal?

Leonardo AI Universal (LEO7) is a revolutionary cross-platform solution that transforms any USB drive into a portable, secure AI environment. With a single seed file, you can deploy AI models to USB drives, local systems, containers, cloud instances, and air-gapped environments - all without leaving a trace on host systems.

### ✨ Key Features

- **🔒 Zero-Trace Security**: Paranoid by design, leaves no footprint on host systems
- **🌍 Universal Compatibility**: One USB works on any computer (Mac, Windows, Linux)
- **🧠 Adaptive Intelligence**: Automatically selects optimal models based on hardware
- **💻 Hacker-Friendly UX**: Nostalgic terminal aesthetics with modern usability
- **🔌 Air-Gap Ready**: Full offline capability for security-critical environments
- **🚀 Multiple Deployment Targets**: USB, local, container, cloud, and air-gapped
- **📦 Modular Architecture**: Hot-swappable components with assembly system
- **🎨 Progressive UI**: From beautiful CLI to full web dashboard

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/officialerictm/LEO7.git
cd LEO7

# Run the installer
./leonardo.sh

# Follow the interactive setup!
```

### Formatting a USB Drive

Before installing Leonardo on a USB drive you can format it on **any** platform:

```bash
# Linux
./leonardo.sh usb format /dev/sdX --format exfat --label LEONARDO

# macOS
diskutil eraseDisk ExFAT LEONARDO /dev/diskN

# Windows (run in PowerShell)
leonardo usb format 1 --format exfat --label LEONARDO
```

The Linux formatter now marks the partition as `msftdata`, ensuring the drive
mounts correctly on macOS and Windows.

## 📋 Requirements

### Minimum System Requirements
- **OS**: Linux, macOS 10.15+, Windows 10+
- **RAM**: 8GB (16GB+ recommended)
- **Storage**: 500MB for Leonardo + model sizes
- **USB**: 16GB+ USB 3.0 drive (for USB deployment)

### Supported Models
- Meta LLaMA 3 (8B, 70B)
- Mistral 7B
- Mixtral 8x7B
- Google Gemma (2B, 7B)
- Custom GGUF models

## 🏗️ Architecture

Leonardo uses a sophisticated modular architecture:

```
LEO7/
├── assembly/          # Build system and manifest
├── src/
│   ├── core/         # Core engine and utilities
│   ├── modules/      # Deployment modules
│   ├── ui/          # User interface components
│   └── models/      # Model management
├── tests/           # Test suite
├── docs/            # Documentation
└── examples/        # Example configurations
```

## 🤝 Contributing

We love contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

Leonardo AI Universal is MIT licensed. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

Built with ❤️ by Eric and the amazing AI assistant team. Special thanks to the open-source community and all contributors who made this project possible.

## 🔗 Links

- [Documentation](https://leonardo-ai.dev)
- [Discord Community](https://discord.gg/leonardo-ai)
- [Report Issues](https://github.com/officialerictm/LEO7/issues)

---

<div align="center">
  <i>Remember: With great portability comes great responsibility. Use Leonardo wisely!</i>
</div>
