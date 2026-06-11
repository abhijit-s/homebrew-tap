class Fff < Formula
  desc "Fast frecency-ranked file finder MCP server for AI code assistants"
  homepage "https://github.com/abhijit-s/fff"
  version "0.16.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/fff/releases/download/v0.16.0/fff-aarch64-apple-darwin.tar.gz"
      sha256 "e2b9aca9b16ff819f2aecedd450bba22380fb1fe593d2f5e2334d42f2902d236"
    end
    on_intel do
      url "https://github.com/abhijit-s/fff/releases/download/v0.16.0/fff-x86_64-apple-darwin.tar.gz"
      sha256 "6e53c9aa578786dd78e757e4832ca1d6d00894075dd6199a6382c789af9a62f3"
    end
  end

  head do
    url "https://github.com/abhijit-s/fff.git", branch: "main"
    depends_on "rust" => :build
  end

  def install
    if build.head?
      ENV["CMAKE_ARGS"] = "-DUSE_SQLITE_CREDENTIAL_CACHING=OFF"
      system "cargo", "build", "--release", "--no-default-features",
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
