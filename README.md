# P.T. for iOS

**Work in progress — experimental iOS port of P.T.**

Based on **[LoreanXavier/pt-pc](https://github.com/LoreanXavier/pt-pc)** and its Hallway Engine. The original source snapshot is commit [`d0a9b8f`](https://github.com/LoreanXavier/pt-pc/commit/d0a9b8f). This repository adapts that project for iOS; it is not an independent recreation of the engine.

Native ARM64, **no CPU JIT**. Touch controls, rendering, MetalFX, and performance are still being refined. Bugs and visual glitches are expected.

No game archives, PS4 executable, keys, saves, or resource-bearing IPA are included. **Your own extracted P.T. dump is required.** This project does not download the game or decrypt packages.

## Current state

- Native C++ compiled ahead of time; Lua 5.1 runs interpreted.
- Vulkan rendering through MoltenVK, with optional MetalFX temporal upscaling. GPU shader compilation is separate from CPU JIT.
- Touch overlay using an SDL virtual Xbox-style gamepad; physical controllers are supported.
- Lower scene resolutions using the phone display's aspect ratio, fullscreen output, and a separate UI canvas.
- A 120 FPS ceiling with thermal/power management. This is a ceiling, not a sustained-performance claim.

The user has launched and played earlier builds on an iPhone 16 Pro, including with a DualShock 4. Latest touch, fullscreen, and MetalFX changes still need physical-device verification. MetalFX can reduce performance; it remains optional. Successful cross-builds and Mac renderer tests do not prove iPhone performance or full game completion.

## Build

Requirements: Apple silicon Mac, Xcode with the iOS SDK, CMake, Ninja, and the Vulkan headers/tools. The current target is ARM64, iOS 18 or newer.

```sh
brew install cmake ninja vulkan-headers shaderc vulkan-loader
./script/build_ios.sh
```

The build script fetches a SHA-256-pinned MoltenVK iOS release and the upstream dependencies. It produces `dist/PT-iOS-unsigned.ipa`, **without the game**. Sign it for your own device before installing. No signing credentials are included.

At first launch, import your own extracted US P.T. dump (CUSA01127), containing:

- `chunk1.psarc`
- `texture.qar`
- `pathid_list_ps4.bin`

Imported resources and saves stay on the device. See [iOS build notes and validation history](docs/ios.md) for implementation details and limitations. Resource-bearing build options are for local use only; never commit or distribute their output.

## Controls

Left stick moves; right stick looks. **A** confirms/interacts, **B** goes back, **ZOOM** holds R3, and the pause button opens the menu. Touch controls reset on cancellation and application/window transitions. Touch sensitivity and multi-touch behavior are still being tested.

## Credits and license

- **LoreanXavier**: original [pt-pc](https://github.com/LoreanXavier/pt-pc) project, Hallway Engine, game implementation, and upstream work. The original MIT copyright and license are retained in [LICENSE](LICENSE).
- **IlieBanda**: iOS adaptation and device testing.
- iOS implementation and debugging were developed with assistance from OpenAI Codex. Test limitations are documented above and in the iOS notes.
- SDL, MoltenVK, Lua, fonts, and other dependencies retain their own licenses and notices. See `third_party/`, `assets/fonts/`, and the upstream documentation.

P.T. and its names, artwork, and original game content belong to their respective rights holders, including Konami. This is an unofficial project and is not affiliated with or endorsed by Konami or Kojima Productions. The source-code license does not grant rights to the game or its assets.
