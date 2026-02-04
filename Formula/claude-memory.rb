# typed: false
# frozen_string_literal: true

class ClaudeMemory < Formula
  desc "Local, privacy-first RAG memory system for Claude Code"
  homepage "https://github.com/mfenderov/claude-memory"
  version "1.0.4"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.4/claude-memory_1.0.4_darwin_amd64.tar.gz"
      sha256 "44e05add9e139998471568ac36adb8ae767a42350e405ace6bf3bacb3f25d9c3"
    end
    on_arm do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.4/claude-memory_1.0.4_darwin_arm64.tar.gz"
      sha256 "0505f7a817a142d1e96027943425b153cb5ffc77a57aab63b7301334a78b409d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.4/claude-memory_1.0.4_linux_amd64.tar.gz"
      sha256 "a90899f39385baafe191f2d12c38d66cb02b1c588116f12dd69fed9855de626c"
    end
    on_arm do
      url "https://github.com/mfenderov/claude-memory/releases/download/v1.0.4/claude-memory_1.0.4_linux_arm64.tar.gz"
      sha256 "6524ab44933a3f1a0a737399eb5a6b4c2859f00e1a783f64123ee151c942d1af"
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

    # Symlink binaries
    ln_s bin/"claude-memory", plugin_dir/"bin"/"claude-memory"
    ln_s bin/"claude-memory-server", plugin_dir/"bin"/"claude-memory-server"

    # Ensure memory database directory exists (but NEVER touch the database itself)
    memory_dir = Pathname.new(Dir.home) / ".claude"
    memory_dir.mkpath

    # Try to register MCP server (may fail in Homebrew sandbox - see caveats)
    server_path = plugin_dir / "bin" / "claude-memory-server"
    system "claude", "mcp", "add", "mark42", "--scope", "user", "--transport", "stdio", "--", server_path.to_s
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

      ══════════════════════════════════════════════════════════════
      IMPORTANT: Register the MCP server (one-time setup)
      ══════════════════════════════════════════════════════════════

      Run this command to enable the "mark42" memory server:

        claude mcp add mark42 --scope user --transport stdio -- \\
          ~/.claude/plugins/local/claude-memory/bin/claude-memory-server

      Then restart Claude Code. The hooks will fire automatically.

      ══════════════════════════════════════════════════════════════

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
