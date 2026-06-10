class TurboRag < Formula
  desc "Per-user semantic source-code index, wrapping turbovec"
  homepage "https://github.com/abhijit-s/turbo-rag"
  version "0.2.0"
  license "Apache-2.0"

  # launchd is macOS-only; refuse cleanly on Linuxbrew rather than
  # installing binaries that will fail when the operator runs
  # `turbo-ragctl install`.
  depends_on :macos

  # Pinned to the stable Homebrew Python tier. `brew unlink python@3.13`
  # AFTER install is supported — the libexec venv uses absolute Cellar
  # symlinks, so your mise/uv-managed Python on $PATH isn't shadowed.
  depends_on "python@3.13"

  # Pre-built wheelhouse (72 wheels: turbo-rag + every transitive dep).
  # Built locally on a clean Python 3.13 venv via
  # `pip wheel <source> --wheel-dir wheelhouse/`, then tarred and uploaded
  # as a Release attachment on THIS tap repo. See docs/releasing.md in
  # github.com/abhijit-s/turbo-rag for the build steps.
  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/homebrew-tap/releases/download/turbo-rag-v0.2.0/turbo-rag-0.2.0-wheelhouse-macos-arm64.tar.gz"
      sha256 "23878908864d73d337d3899beb42b07eb6ecb81b8a3a2e1ee293bf3b3f2f6add"
    end
  end

  def install
    # Wheelhouse is the tarball's top-level dir. Build a libexec venv
    # against the brewed python@3.13 and install everything offline.
    venv_python = libexec/"bin/python"
    system Formula["python@3.13"].opt_bin/"python3.13", "-m", "venv", libexec
    system venv_python, "-m", "pip", "install", "--upgrade", "pip"
    system venv_python, "-m", "pip", "install",
           "--no-index", "--find-links=#{buildpath}/wheelhouse",
           "turbo-rag-poc"

    # Explicit symlinks per the source repo's plan KTD.
    bin.install_symlink libexec/"bin/turbo-ragctl"
    bin.install_symlink libexec/"bin/turbo-rag-engine"
    bin.install_symlink libexec/"bin/turbo-rag-mcp"
  end

  def caveats
    <<~EOS
      turbo-rag binaries (turbo-ragctl, turbo-rag-engine, turbo-rag-mcp)
      are installed; the engine is NOT yet wired to launchd.

      Next step:
        turbo-ragctl install --mode <always-on|on-demand>

      If you already have Python 3.13 via mise/uv/pyenv and want your
      version ahead on PATH, run:
        brew unlink python@3.13

      The libexec venv keeps working (it uses absolute Cellar symlinks).
      To re-link later: brew link python@3.13

      For man pages, clone the source repo and run
        scripts/install-manpages.sh
      (or `make manpages` if you've edited the CLIs).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/turbo-ragctl --version")
    system bin/"turbo-rag-engine", "--help"
    system bin/"turbo-rag-mcp", "--help"
  end
end
