# Zig Extension

This extension adds Zig language and ZLS (Zig Language server)

### Installation

Install the extension through the Xed-Editor's extension marketplace, and you're ready to go! Alternatively, you can download the latest release ZIP file and install it via Settings > Extensions > Install from storage.

After install extension install zig and zls in Settings > Editor > Language servers > Zig > Install

Check installed:
```bash
zig --help
zls --help
```

## Build

Debug build:
```bash
./gradlew assembleDebug
./gradlew :app:createFinalZip
```

Release build:
```bash
./gradlew assembleRelease
./gradlew :app:createFinalZip
```

Or use files `./compileDebug` or `./compileRelease`