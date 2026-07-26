class Fff < Formula
  desc "Fast frecency-ranked file finder MCP server for AI code assistants"
  homepage "https://github.com/abhijit-s/fff"
  version "0.17.2"
  license "MIT"

  # Stable ships aarch64-apple-darwin only (built locally, ripgrep backend).
  # Intel/Linux users: use `--HEAD` (builds from source) until CI releases resume.
  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/fff/releases/download/v0.17.2/fff-aarch64-apple-darwin.tar.gz"
      sha256 "d3e6c6da3f06604322513dcc8842f2415880ab8e3d417f945ff2ba9b1f18a334"
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
