# typed: false
# frozen_string_literal: true

class ClaudeMemory < Formula
  desc "Local, privacy-first RAG memory system for Claude Code"
  homepage "https://github.com/mfenderov/claude-memory"
  version "1.0.3"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.3/claude-memory_1.0.3_darwin_amd64.tar.gz"
      sha256 "121a615aa9b73d6ce62c594e165a9186ee75eafb8d0e905512c29bf7aeb0d9fc"
    end
    on_arm do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.3/claude-memory_1.0.3_darwin_arm64.tar.gz"
      sha256 "2d65104204d27bd4eccf20ca66cdb37c5b685ae802ea4d40dd8a0892d8d6a74a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.3/claude-memory_1.0.3_linux_amd64.tar.gz"
      sha256 "9904d9d7ddecb5ac0ff2f387322aac6ecca3343cb071deca51cf35c6e42ecd3a"
    end
    on_arm do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.3/claude-memory_1.0.3_linux_arm64.tar.gz"
      sha256 "84888fa5f90c9532c28db2c171360a5d69d42b8d22d3cc54d0cb20f8a20b875a"
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

    # Clean up existing installation (handles upgrades)
    plugin_dir.rmtree if plugin_dir.exist?
    plugin_dir.mkpath
    (plugin_dir / "bin").mkpath

    # Symlink plugin files from share directory
    ln_s share/"claude-memory"/".claude-plugin", plugin_dir/".claude-plugin"
    ln_s share/"claude-memory"/"agents", plugin_dir/"agents"
    ln_s share/"claude-memory"/"skills", plugin_dir/"skills"
    ln_s share/"claude-memory"/"commands", plugin_dir/"commands"
    ln_s share/"claude-memory"/"hooks", plugin_dir/"hooks"
    ln_s share/"claude-memory"/"hooks.json", plugin_dir/"hooks.json"
    ln_s share/"claude-memory"/".mcp.json", plugin_dir/".mcp.json"

    # Symlink binaries
    ln_s bin/"claude-memory", plugin_dir/"bin"/"claude-memory"
    ln_s bin/"claude-memory-server", plugin_dir/"bin"/"claude-memory-server"

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
