from pathlib import Path
import sys

REPOSITORY = Path(__file__).resolve().parents[1]
AGENTUI = REPOSITORY / "Packages" / "AgentUI" / "Sources" / "AgentUI"
UPSTREAM_VIEWS = REPOSITORY / "upstream" / "SwiftChat" / "SwiftChat" / "Views"

CORE_COMPONENTS = [
    {
        "name": "Composer",
        "package_file": AGENTUI / "Composer" / "AgentComposerView.swift",
        "package_tokens": ["struct AgentComposerView", "struct CustomTextEditor", "RoundedRectangle(cornerRadius: 26)"],
        "app_file": UPSTREAM_VIEWS / "MessageInputView.swift",
        "app_bridge_token": "AgentComposerView",
        "max_app_lines": 120,
    },
    {
        "name": "MessageView",
        "package_file": AGENTUI / "Message" / "AgentMessageView.swift",
        "package_tokens": ["struct AgentMessageView", "AgentActivityTimelineView", "ToolExecutionDisclosure"],
        "app_file": UPSTREAM_VIEWS / "MessageView.swift",
        "app_bridge_token": "AgentMessageView",
        "max_app_lines": 150,
    },
    {
        "name": "MessageTableView",
        "package_file": AGENTUI / "Chat" / "AgentMessageTableView.swift",
        "package_tokens": ["struct AgentMessageTableView", "UITableView", "Coordinator"],
        "app_file": UPSTREAM_VIEWS / "MessageTableView.swift",
        "app_bridge_token": "AgentMessageTableView",
        "max_app_lines": 100,
    },
    {
        "name": "ChatListView",
        "package_file": AGENTUI / "Chat" / "AgentMessageListView.swift",
        "package_tokens": ["struct AgentMessageListView", "AgentMessageTableView"],
        "app_file": UPSTREAM_VIEWS / "ChatListView.swift",
        "app_bridge_token": "AgentMessageListView",
        "max_app_lines": 100,
    },
    {
        "name": "ChatSidebar",
        "package_file": AGENTUI / "Sidebar" / "AgentChatSidebarView.swift",
        "package_tokens": ["struct AgentChatSidebarView"],
        "app_file": UPSTREAM_VIEWS / "ChatSidebar.swift",
        "app_bridge_token": "AgentChatSidebarView",
        "max_app_lines": 120,
    },
    {
        "name": "ChatShell",
        "package_file": AGENTUI / "Chat" / "AgentChatView.swift",
        "package_tokens": ["struct AgentChatView"],
        "app_file": UPSTREAM_VIEWS / "ChatView.swift",
        "app_bridge_token": "AgentChatView",
        "max_app_lines": 120,
    },
]


def verify_core_ownership(allow_in_progress: bool = False) -> bool:
    all_passed = True
    print("=== Checking AgentUI Core UI Ownership ===")

    for comp in CORE_COMPONENTS:
        name = comp["name"]
        pkg_file = comp["package_file"]
        app_file = comp["app_file"]

        if not pkg_file.exists():
            print(f"[-] {name}: Package implementation missing at {pkg_file}")
            all_passed = False
            continue

        pkg_content = pkg_file.read_text(encoding="utf-8")
        for token in comp["package_tokens"]:
            if token not in pkg_content:
                print(f"[-] {name}: Package file missing required token '{token}'")
                all_passed = False

        if not app_file.exists():
            print(f"[-] {name}: App file missing at {app_file}")
            all_passed = False
            continue

        app_content = app_file.read_text(encoding="utf-8")
        app_lines = len(app_content.splitlines())

        bridge_present = comp["app_bridge_token"] in app_content
        is_thin = app_lines <= comp["max_app_lines"]

        if bridge_present and is_thin:
            print(f"[+] {name}: Sole owner is AgentUI ({len(pkg_content.splitlines())} lines in package, {app_lines} lines in app bridge)")
        else:
            if allow_in_progress:
                print(f"[~] {name}: In progress (App has {app_lines} lines, bridge={bridge_present})")
            else:
                print(f"[-] {name}: App still has full implementation or missing bridge ({app_lines} lines > {comp['max_app_lines']} or missing '{comp['app_bridge_token']}')")
                all_passed = False

    return all_passed


if __name__ == "__main__":
    allow_partial = "--allow-in-progress" in sys.argv
    success = verify_core_ownership(allow_in_progress=allow_partial)
    if not success and not allow_partial:
        sys.exit(1)
