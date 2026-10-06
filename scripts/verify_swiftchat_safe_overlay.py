from pathlib import Path
import subprocess
import sys


REPOSITORY = Path(__file__).resolve().parents[1]
UPSTREAM = REPOSITORY / "upstream" / "SwiftChat"
SWIFTCHAT = UPSTREAM / "SwiftChat"

FROZEN = [
    "SwiftChat/Views/ChatView.swift",
    "SwiftChat/Views/ChatSidebar.swift",
    "SwiftChat/ContentView.swift",
    "SwiftChat/Views/LaTeXMarkdownView.swift",
    "SwiftChat/Views/WebSearchBox.swift",
    "SwiftChat/Extensions/Color.swift",
]
ALLOWED_EXISTING = {
    "SwiftChat/Views/MessageView.swift",
    "SwiftChat/Views/MessageInputView.swift",
    "SwiftChat/ViewModels/ChatViewModel.swift",
    "SwiftChat.xcodeproj/project.pbxproj",
}


def git(*arguments: str) -> str:
    result = subprocess.run(
        ["git", "-c", f"safe.directory={UPSTREAM.as_posix()}", *arguments],
        cwd=UPSTREAM, check=True, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    return result.stdout


def fail(message: str) -> None: raise SystemExit(f"SAFE OVERLAY VERIFICATION FAILED: {message}")
def baseline_text(path: str) -> str: return git("show", f"HEAD:{path}")
def current_text(path: str) -> str: return (UPSTREAM / path).read_text(encoding="utf-8")


def assert_frozen_files() -> None:
    for path in FROZEN:
        if git("diff", "--name-only", "HEAD", "--", path).strip():
            fail(f"frozen file changed: {path}")
        baseline_hash = git("rev-parse", f"HEAD:{path}").strip()
        current_hash = git("hash-object", path).strip()
        if baseline_hash != current_hash:
            fail(f"frozen file hash mismatch: {path}")


def assert_diff_scope() -> list[str]:
    names = [line for line in git("diff", "--name-only", "HEAD").splitlines() if line]
    for path in names:
        if path in ALLOWED_EXISTING:
            continue
        if path.startswith("SwiftChat/Features/") or path.startswith("SwiftChat/Assets.xcassets/demo-architecture.imageset/"):
            continue
        fail(f"overlay changed a disallowed path: {path}")
    for required in ALLOWED_EXISTING:
        if required not in names:
            fail(f"required bridge file was not patched: {required}")
    return names


def assert_message_invariants() -> None:
    path = "SwiftChat/Views/MessageView.swift"
    after = current_text(path)
    if "AgentMessageView(" not in after or "import AgentUI" not in after:
        fail("MessageView is missing AgentMessageView bridge")
    if len(after.splitlines()) > 50:
        fail(f"MessageView bridge exceeds 50 lines: {len(after.splitlines())}")

    pkg_message = (REPOSITORY / "Packages" / "AgentUI" / "Sources" / "AgentUI" / "Message" / "AgentMessageView.swift").read_text(encoding="utf-8")
    for token in [
        "struct AgentMessageView",
        ".frame(width: 32, height: 32)",
        "HStack(spacing: 16)",
        ".padding(.vertical, 8)",
        "AI can make mistakes. Verify important information.",
        "struct SourcesButton",
        "AgentActivityTimelineView",
        "ToolExecutionDisclosure",
    ]:
        if token not in pkg_message:
            fail(f"AgentMessageView missing invariant token: {token}")


def assert_composer_invariants() -> None:
    path = "SwiftChat/Views/MessageInputView.swift"
    after = current_text(path)
    if "AgentComposerView(" not in after or "import AgentUI" not in after:
        fail("MessageInputView is missing AgentComposerView bridge")
    if "struct CustomTextEditor" in after or "private var attachButton" in after:
        fail("MessageInputView still contains duplicate app-local composer body")
    if len(after.splitlines()) > 40:
        fail(f"MessageInputView bridge exceeds 40 lines: {len(after.splitlines())}")

    pkg_composer = (REPOSITORY / "Packages" / "AgentUI" / "Sources" / "AgentUI" / "Composer" / "AgentComposerView.swift").read_text(encoding="utf-8")
    for token in [
        "RoundedRectangle(cornerRadius: 26)",
        ".padding(.horizontal)",
        ".buttonStyle(.glass)",
        ".buttonBorderShape(.circle)",
        "Color.sendButtonForegroundDark",
        "Color.sendButtonBackgroundDark",
        "struct CustomTextEditor",
    ]:
        if token not in pkg_composer:
            fail(f"AgentComposerView missing invariant token: {token}")


def assert_project_invariants() -> None:
    diff = git("diff", "HEAD", "--", "SwiftChat.xcodeproj/project.pbxproj")
    if not diff.strip():
        return
    allowed_tokens = {"AgentUI", "XCLocalSwiftPackageReference", "relativePath", "};", "isa = XCSwiftPackageProductDependency"}
    for line in diff.splitlines():
        if line.startswith("+") and not line.startswith("+++"):
            stripped = line[1:].strip()
            if stripped and not any(tok in stripped for tok in allowed_tokens):
                fail(f"disallowed project.pbxproj addition: {line}")
        elif line.startswith("-") and not line.startswith("---"):
            fail(f"disallowed project.pbxproj deletion: {line}")


def assert_overlay_files() -> None:
    files = list((SWIFTCHAT / "Features").rglob("*.swift"))
    if not files:
        fail("no overlay Swift files were installed")
    for path in files:
        line_count = len(path.read_text(encoding="utf-8").splitlines())
        if line_count > 350:
            fail(f"new file exceeds 350 lines: {path.relative_to(UPSTREAM)} ({line_count})")
    if len(Path(__file__).read_text(encoding="utf-8").splitlines()) > 180:
        fail("verification script exceeds 180 lines")
    installer = REPOSITORY / "scripts" / "apply_swiftchat_safe_overlay.py"
    if len(installer.read_text(encoding="utf-8").splitlines()) > 180:
        fail("overlay installer exceeds 180 lines")


def main() -> None:
    if not UPSTREAM.is_dir():
        fail(f"SwiftChat checkout not found: {UPSTREAM}")
    assert_frozen_files()
    names = assert_diff_scope()
    assert_project_invariants()
    assert_message_invariants()
    assert_composer_invariants()
    assert_overlay_files()
    print("SwiftChat safe overlay verification passed")
    print("\nDiff names from local golden baseline:")
    print("\n".join(names))
    print("\nDiff stat from local golden baseline:")
    print(git("diff", "--stat", "HEAD").rstrip())


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print(error.stderr, file=sys.stderr)
        raise
