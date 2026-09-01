class Fff < Formula
  desc "Fast frecency-ranked file finder MCP server for AI code assistants"
  homepage "https://github.com/abhijit-s/fff"
  version "0.19.4"
  license "MIT"

  # Stable ships aarch64-apple-darwin only (built locally, ripgrep backend).
  # macOS ships pre-built bottles for both Apple Silicon (arm64) and Intel (x86_64).
  # Linux installs via the APT repo or `brew install --HEAD` (source build).
  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/fff/releases/download/v0.19.4/fff-aarch64-apple-darwin.tar.gz"
      sha256 "3124d4c9e4e13a0a0cdec3a51b3271a6121d8f7d74001f37946058a9d5c9d9f3"
    end
    on_intel do
      url "https://github.com/abhijit-s/fff/releases/download/v0.19.4/fff-x86_64-apple-darwin.tar.gz"
      sha256 "ccceb3d606726d5b74a13b385ac4bc3e885d7ab8d6b69993bda61ca54e50e091"
    end
  end

  head do
    url "https://github.com/abhijit-s/fff.git", branch: "main"
    depends_on "rust" => :build
  end

  def install
    if build.head?
      ENV["CMAKE_ARGS"] = "-DUSE_SQLITE_CREDENTIAL_CACHING=OFF"
      # Crate defaults give fff-mcp the pure-Rust `ripgrep` walker (no Zig),
      # unified across the -p set so fff-core satisfies its ripgrep|zlob guard.
      system "cargo", "build", "--release",
             "-p", "fff-engine", "-p", "fff-mcp", "-p", "fff-ctl"
      bin.install "target/release/fff-mcp"
      bin.install "target/release/fff-engine"
      bin.install "target/release/fffctl"
    else
      bin.install "fff-mcp"
      bin.install "fff-engine"
      bin.install "fffctl"
    end

    # Shell completions, generated from the installed binaries.
    generate_completions_from_executable(bin/"fffctl", "--completions")
    generate_completions_from_executable(bin/"fff-mcp", "--completions")
  end

  def caveats
    <<~EOS
      fff-mcp, fff-engine, and fffctl are all installed to #{HOMEBREW_PREFIX}/bin/.

      Register with Claude Code (user-scoped, survives updates):
        claude mcp add -s user fff -- #{bin}/fff-mcp

      Or add to your project .mcp.json:
        {
          "mcpServers": {
            "fff": { "type": "stdio", "command": "fff-mcp" }
          }
        }

      Manage running daemons with fffctl:
        fffctl list           # show all running daemons
        fffctl stop --all     # stop every daemon
        fffctl clean          # remove stale lockfiles / orphan sockets
        fffctl restart        # stop --all + clean (run after upgrading fff)

      Configuration (optional): ~/.config/fff/config.toml
        [log]
        level = "fff_engine=info,fff_mcp=info,warn"

        # Search multiple projects from one server:
        [mcp]
        default = "app"
        [[mcp.roots]]
        name = "app"
        path = "/Users/you/work/app"
    EOS
  end

  test do
    assert_predicate bin/"fff-mcp", :executable?
    assert_predicate bin/"fff-engine", :executable?
    assert_predicate bin/"fffctl", :executable?
    assert_match "fff-engine", shell_output("#{bin}/fff-engine --help 2>&1", 2)
    assert_match "Manage fff-engine daemons", shell_output("#{bin}/fffctl --help 2>&1")
  end
end
