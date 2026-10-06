# Core Golden Source Hashes

## Golden Source Traceability

This record documents the exact cryptographic hashes (SHA-256) of the materialized SwiftChat core files, upstream commit, scripts, and safe-overlay patches for complete forensic traceability.

### Upstream & Repository Metadata

| Property | Value |
|---|---|
| **Repository Starting SHA** | `7ac5bd611b27d296195f2f32f0597e2bf964af45` |
| **Pinned Upstream SwiftChat SHA** | `d6f54ccf9e84d2fec672b7b89d5a67dd6ee0f957` |
| **Local Golden Baseline Commit** | `6f191a59f4d018398113e5192b81535a47dacb32` |
| **Materialization Pipeline** | Clone -> Checkout d6f54cc -> patch_swiftchat_full_demo.py -> upgrade_swiftchat_ui.py -> Commit Baseline -> apply_swiftchat_safe_overlay.py -> verify_swiftchat_safe_overlay.py |

---

### Pipeline Script Hashes (SHA-256)

| Script | SHA-256 |
|---|---|
| `scripts/patch_swiftchat_full_demo.py` | `471ebe6af27d7891a2e1100b4dd24cb16668b80a20213f158d36104df5ac8ef8` |
| `scripts/upgrade_swiftchat_ui.py` | `40edd1cde40f208589bc14592c925f6f893ff8e772424fa6ccf42691c67de22f` |
| `scripts/apply_swiftchat_safe_overlay.py` | `702395fb6448d998e6ee1b1fb26d3637f031820fc8c971aea64f6ca02b5ee1d4` |
| `scripts/verify_swiftchat_safe_overlay.py` | `22d1bd9afed3bc26c60db49a1f88d3b9f624053c6c1b5a3c993610b1f9bc8690` |

---

### Safe Overlay Patches (SHA-256)

| Patch | SHA-256 |
|---|---|
| `swiftchat-overlay/patches/001-message-view-bridges.patch` | `0eec1c05e1eb4459ccc90abb4eb8a15e890038f99d6884214b6f841c68743828` |
| `swiftchat-overlay/patches/002-composer-model-menu.patch` | `902e260e542657d089bf1c6d5f9d3b48995d9ac792b997c884501ec9298474a0` |
| `swiftchat-overlay/patches/003-activity-stream-and-demo-hooks.patch` | `dcec84b7f477ce4897a03dc3a98a54e5189274a5ee9b99d2b3eddb0b668f84cd` |
| `swiftchat-overlay/patches/004-tool-execution-demo.patch` | `56343b81b550b0e4796497f7279e18d1706d4b3dc2530626adf3d23c2e37c562` |
| `swiftchat-overlay/patches/005-link-agentui-package.patch` | `93efd50df3a17d984099976290ef95f98eac3d7c90ed321194fd09780868fe44` |

---

### Materialized Core View Source Hashes (SHA-256)

These hashes reflect the files in `upstream/SwiftChat/SwiftChat/` after the complete pipeline has executed:

| Relative Path | Line Count | SHA-256 |
|---|---|---|
| `SwiftChat/Views/ChatView.swift` | 257 | `6fdb2bffdb9aeef6459d56ff0dd7bdc0d18f3117d6bf5ed0e1167f33efa36aa2` |
| `SwiftChat/Views/ChatSidebar.swift` | 172 | `81f39e1fc06d3376e6e59343bd5686dbc31f9021c5005b91a77a9640aeb7141a` |
| `SwiftChat/Views/ChatListView.swift` | 167 | `b0c9b315d1cb82251a0223e084476cba6f47b429d0e7bb429cd17b84ed5c466e` |
| `SwiftChat/Views/MessageTableView.swift` | 715 | `056d74bd79517b2d08a07613bf2966c14364f1b7b2205bffe6a282532433d613` |
| `SwiftChat/Views/MessageInputView.swift` | 663 | `02b9c981a31c622e448ff763960de9420af74da036a121bf6ecc6eb0764e450f` |
| `SwiftChat/Views/MessageView.swift` | 1859 | `fe2b0ed164d8b19c6c81412391fea1b02f3dee9615c9cb4c8f1a5ff1a0f2b24c` |
| `SwiftChat/Views/LaTeXMarkdownView.swift` | 1044 | `e2158e53a7a333fc49f44712d6a035476039a8b586ce1d418bd9e2d89ab8a835` |
| `SwiftChat/Views/AttachmentPreviewBar.swift` | 132 | `713b96def3cf458913875fba304e4b95b0d8ee38a42b90c77bda5021e3657d97` |
| `SwiftChat/Views/MessageAttachmentIndicator.swift` | 294 | `a843c6602a41c94041892d367144f814b266794f9dac8218e066b5e9b9ac2cfb` |
| `SwiftChat/Views/WebSearchBox.swift` | 226 | `a5923b2f8e996432edd1a5c23a94aeb5ab174e98404defdb02063c8556b60ab7` |
| `SwiftChat/Views/URLFetchBox.swift` | 171 | `2b1ba43fec4ecc77d65b99f82b67e2c4f91041f0576016ca8efc1d4ec5fbcca1` |
| `SwiftChat/Views/CameraPickerView.swift` | 50 | `751d974a7da998d9fa5d3b9c3234f45e4b67c5dbc0cbb527b1e7e1daa0218072` |
| `SwiftChat/Views/DocumentPickerView.swift` | 69 | `17a8fa42159395da4b2a245b9463b2a2d523daaa42473578fc404f22ab9f55bb` |
