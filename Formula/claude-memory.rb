# typed: false
# frozen_string_literal: true

class ClaudeMemory < Formula
  desc "Local, privacy-first RAG memory system for Claude Code"
  homepage "https://github.com/mfenderov/claude-memory"
  version "1.0.1"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.1/claude-memory_1.0.1_darwin_amd64.tar.gz"
      sha256 "8797ebdf565fc8d0d75f2cf37dfc5925cf6841e0e108db1aa6fa4de69e0c84a1"
    end
    on_arm do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.1/claude-memory_1.0.1_darwin_arm64.tar.gz"
      sha256 "b5823f2e5dbc38fd9d03c7ef9c8677c2e7f1a2a479f8276d641920bc251afd73"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.1/claude-memory_1.0.1_linux_amd64.tar.gz"
      sha256 "20ecd3dbcdd7711ca77bd61854ae62ec16389ba4c45d0140daa4f766ff07c57e"
    end
    on_arm do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.1/claude-memory_1.0.1_linux_arm64.tar.gz"
      sha256 "e798e1e3e9a254ef8049171d4231630f94449d507e5fb4fedc770ac14a379f19"
    end
  end

  def install
    bin.install "claude-memory"
    bin.install "claude-memory-server"

    # Install plugin assets to share directory (Homebrew-managed)
    (share/"claude-memory").install ".claude-plugin"
    (share/"claude-memory").install "agents"
    (share/"claude-memory").install "skills"
    (share/"claude-memory").install "commands"
    (share/"claude-memory").install "hooks"
    (share/"claude-memory").install "hooks.json"
    (share/"claude-memory").install ".mcp.json"
  end

  def post_install
    # Create Claude Code plugin directory structure
    plugin_dir = Pathname.new(Dir.home) / ".claude" / "plugins" / "local" / "claude-memory"
    plugin_dir.mkpath
    (plugin_dir / "bin").mkpath

    # Symlink plugin files from share directory
    ln_sf share/"claude-memory"/".claude-plugin", plugin_dir/".claude-plugin"
    ln_sf share/"claude-memory"/"agents", plugin_dir/"agents"
    ln_sf share/"claude-memory"/"skills", plugin_dir/"skills"
    ln_sf share/"claude-memory"/"commands", plugin_dir/"commands"
    ln_sf share/"claude-memory"/"hooks", plugin_dir/"hooks"
    ln_sf share/"claude-memory"/"hooks.json", plugin_dir/"hooks.json"
    ln_sf share/"claude-memory"/".mcp.json", plugin_dir/".mcp.json"

    # Symlink binaries
    ln_sf bin/"claude-memory", plugin_dir/"bin"/"claude-memory"
    ln_sf bin/"claude-memory-server", plugin_dir/"bin"/"claude-memory-server"

    # Ensure memory database directory exists (but NEVER touch the database itself)
    memory_dir = Pathname.new(Dir.home) / ".claude"
    memory_dir.mkpath
  end

  def caveats
    <<~EOS
      Claude Memory plugin installed!

      ══════════════════════════════════════════════════════════════
      YOUR MEMORY IS SAFE
      ══════════════════════════════════════════════════════════════

      Database location: ~/.claude/memory.db

      This file contains YOUR knowledge graph and is NEVER touched by
      brew install, upgrade, or uninstall. Your memories persist forever.

      ══════════════════════════════════════════════════════════════

      Plugin location: ~/.claude/plugins/local/claude-memory/

      To activate:
        1. Restart Claude Code
        2. The MCP server "mark42" will start automatically
        3. Hooks will fire on SessionStart, PostToolUse, Stop

      Available commands: /init, /status, /sync, /calibrate

      Verify installation:
        claude-memory version
        claude-memory stats

      Backup recommendation:
        cp ~/.claude/memory.db ~/.claude/memory.db.backup
    EOS
  end

  test do
    assert_match "claude-memory", shell_output("#{bin}/claude-memory version")
  end
end
