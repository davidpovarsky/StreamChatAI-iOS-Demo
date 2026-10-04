from pathlib import Path
import shutil
import subprocess


REPOSITORY = Path(__file__).resolve().parents[1]
UPSTREAM = REPOSITORY / "upstream" / "SwiftChat"
OVERLAY = REPOSITORY / "swiftchat-overlay"
FEATURES = UPSTREAM / "SwiftChat" / "Features"
ASSETS = UPSTREAM / "SwiftChat" / "Assets.xcassets"


def run(*arguments: str) -> None:
    command = [arguments[0], "-c", f"safe.directory={UPSTREAM.as_posix()}", *arguments[1:]]
    subprocess.run(command, cwd=UPSTREAM, check=True)


def copy_overlay_files() -> None:
    if not UPSTREAM.is_dir():
        raise SystemExit(f"SwiftChat checkout not found: {UPSTREAM}")

    for source in sorted((OVERLAY / "Features").rglob("*.swift")):
        relative = source.relative_to(OVERLAY / "Features")
        destination = FEATURES / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)

    for source in sorted((OVERLAY / "Resources").rglob("*")):
        if not source.is_file():
            continue
        relative = source.relative_to(OVERLAY / "Resources")
        destination = ASSETS / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)


def apply_checked_patches() -> None:
    patches = sorted((OVERLAY / "patches").glob("*.patch"))
    if not patches:
        raise SystemExit("No safe-overlay patches were found")

    for patch in patches:
        run("git", "apply", "--check", str(patch))
        run("git", "apply", str(patch))


def main() -> None:
    copy_overlay_files()
    run("git", "add", "-N", "SwiftChat/Features", "SwiftChat/Assets.xcassets/demo-architecture.imageset")
    apply_checked_patches()
    print("SwiftChat safe overlay applied successfully")


if __name__ == "__main__":
    main()
