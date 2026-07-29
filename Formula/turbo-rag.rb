class TurboRag < Formula
  desc "Per-user semantic source-code index, wrapping turbovec"
  homepage "https://github.com/abhijit-s/turbo-rag"
  version "0.21.1"
  license "Apache-2.0"

  # launchd is macOS-only; refuse cleanly on Linuxbrew rather than
  # installing binaries that will fail when the operator runs
  # `turbo-ragctl install`.
  depends_on :macos

  # Pinned to the stable Homebrew Python tier. `brew unlink python@3.13`
  # AFTER install is supported — the libexec venv uses absolute Cellar
  # symlinks, so your mise/uv-managed Python on $PATH isn't shadowed.
  depends_on "python@3.13"

  # Pre-built wheelhouse (73 wheels: turbo-rag + every transitive dep).
  # Built locally on a clean Python 3.13 venv via
  # `pip wheel <source> --wheel-dir wheelhouse/`, then tarred and uploaded
  # as a Release attachment on THIS tap repo. See docs/releasing.md in
  # github.com/abhijit-s/turbo-rag for the build steps.
  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/homebrew-tap/releases/download/turbo-rag-v0.21.1/turbo-rag-0.21.1-wheelhouse-macos-arm64.tar.gz"
      sha256 "5a83f040059ce26cf8769cab21a2ff86a3a0950c4bb2e00a15546b1f723141ab"
    end
  end

  def install
    # Wheelhouse is the tarball's top-level dir. Build a libexec venv
    # against the brewed python@3.13 and install everything offline.
    venv_python = libexec/"bin/python"
    system Formula["python@3.13"].opt_bin/"python3.13", "-m", "venv", libexec
    system venv_python, "-m", "pip", "install", "--upgrade", "pip"
    # Tarball has two top-level dirs (wheelhouse/ + man/), so brew does
    # NOT auto-CD; buildpath is the extraction root containing both.
    system venv_python, "-m", "pip", "install",
           "--no-index", "--find-links=#{buildpath}/wheelhouse",
           "turbo-rag-poc"

    # Explicit symlinks per the source repo's plan KTD.
    bin.install_symlink libexec/"bin/turbo-ragctl"
    bin.install_symlink libexec/"bin/turbo-rag-engine"
    bin.install_symlink libexec/"bin/turbo-rag-mcp"

    # Install groff man pages from the tarball's man/man1/ dir.
    man1.install Dir["#{buildpath}/man/man1/*.1"]
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

      Man pages are installed under $HOMEBREW_PREFIX/share/man/man1/ — try
      `man turbo-ragctl`. For dev installs from a clone, run
      `scripts/install-manpages.sh` (or `make manpages` if you've edited
      the CLIs).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/turbo-ragctl --version")
    system bin/"turbo-rag-engine", "--help"
    system bin/"turbo-rag-mcp", "--help"
  end
end
