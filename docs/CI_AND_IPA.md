# Continuous Integration & Unsigned IPA Distribution (iOS 27.0+)

## 1. GitHub Actions CI Configuration

The CI pipeline runs under `.github/workflows/build-ipa.yml` on GitHub-hosted macOS runners (`macos-15` / `macos-14` / `xcode-27`).

### CI Workflow Stages
1. **Toolchain Inspection**:
   - Validates `xcodebuild -version` and selected SDKs (`iphoneos` and `iphonesimulator`).
2. **SwiftPM Test Suite**:
   - Executes unit and snapshot tests against the iOS simulator:
   ```bash
   xcodebuild test \
     -scheme AgentChatSDK-Package \
     -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
     -skipMacroValidation
   ```
3. **Xcode Project Generation & Build**:
   - Generates `.xcodeproj` using `xcodegen generate --spec project.yml`.
   - Compiles the device target:
   ```bash
   xcodebuild build \
     -project "StreamChatAI Demo.xcodeproj" \
     -scheme "StreamChatAI Demo" \
     -configuration Debug \
     -sdk iphoneos \
     -destination "generic/platform=iOS" \
     -derivedDataPath build/DerivedData \
     CODE_SIGNING_ALLOWED=NO \
     CODE_SIGNING_REQUIRED=NO \
     CODE_SIGN_IDENTITY=""
   ```
4. **Unsigned IPA Assembly**:
   - Extracts `StreamChatAI Demo.app` from DerivedData into a `Payload/` folder.
   - Archives the directory into an unsigned `.ipa` package:
   ```bash
   mkdir -p Payload
   cp -R "build/DerivedData/.../StreamChatAI Demo.app" Payload/
   zip -r -9 "AgentChatSDK-Native-Demo-unsigned.ipa" Payload
   ```
5. **Artifact Publishing**:
   - Uploads `AgentChatSDK-Native-Demo-unsigned.ipa` and `StreamChatAI-Demo-unsigned.ipa` via `actions/upload-artifact@v4`.

---

## 2. Artifact Access from Windows

To download the built IPA using the GitHub CLI (`gh`):

```powershell
# List recent CI runs
gh run list --workflow=build-ipa.yml

# Download artifact from specific run ID
gh run download <RUN_ID> -n "AgentChatSDK-Native-Demo-IPA" -D ./artifacts
```

---

## 3. Sideloading onto iOS / iPadOS Devices

Because the generated IPA is unsigned (`CODE_SIGNING_ALLOWED=NO`), it cannot be installed directly via Xcode without re-signing.

### Sideloading Options:
1. **AltStore / SideStore**:
   - Transfer `AgentChatSDK-Native-Demo-unsigned.ipa` to the iOS device.
   - Open AltStore/SideStore and tap "+" to sign with a free Apple ID.
2. **Apple Configurator (macOS)**:
   - Connect the iOS/iPadOS device via USB.
   - Re-sign with a valid Development or Ad-Hoc provisioning profile and drag the app onto the device.
3. **Sideloadly (Windows / macOS)**:
   - Connect iPhone/iPad to PC via USB.
   - Drag `AgentChatSDK-Native-Demo-unsigned.ipa` into Sideloadly.
   - Enter your Apple ID to sign and install automatically.
