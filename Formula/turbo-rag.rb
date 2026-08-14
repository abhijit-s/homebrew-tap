class TurboRag < Formula
  desc "Per-user semantic source-code index, wrapping turbovec"
  homepage "https://github.com/abhijit-s/turbo-rag"
  version "0.25.0"
  license "Apache-2.0"

  # launchd is macOS-only; refuse cleanly on Linuxbrew rather than
  # installing binaries that will fail when the operator runs
  # `turbo-ragctl install`.
  depends_on :macos

  # NO `depends_on "python@3.13"`. The frozen --onedir bundle carries its own
  # CPython runtime + every dependency — there is no interpreter, no libexec
  # venv, no PYTHONPATH, and no client-wheel install order at runtime.

  # Pre-built frozen bundle (three executables sharing one _internal/ runtime).
  # Built locally on a clean Python 3.13 venv via
  # `scripts/release/build-frozen-bundle.sh <version>` (build-host == install-
  # host — KTD11), then uploaded as a Release attachment on THIS tap repo. See
  # docs/releasing.md in github.com/abhijit-s/turbo-rag for the build steps.
  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/homebrew-tap/releases/download/turbo-rag-v0.25.0/turbo-rag-0.25.0-bundle-macos-arm64.tar.gz"
      # sha256 is set by scripts/release/bump-formula.sh at release time.
      sha256 "00978dfc369ee926cdca562623a98140f215eaf3fdaa506c2dc6cca129545aad"
    end
  end

  def install
    # Tarball has two top-level dirs (bundle/ + man/), so brew does NOT
    # auto-CD; buildpath is the extraction root containing both. Install the
    # whole --onedir bundle under libexec, then symlink the three executables
    # onto PATH — they resolve their shared runtime from the sibling _internal/.
    libexec.install "bundle" => "turbo-rag"
    bin.install_symlink libexec/"turbo-rag/turbo-ragctl"
    bin.install_symlink libexec/"turbo-rag/turbo-rag-engine"
    bin.install_symlink libexec/"turbo-rag/turbo-rag-mcp"

    # Install groff man pages from the tarball's man/man1/ dir.
    man1.install Dir["#{buildpath}/man/man1/*.1"]
  end

  def caveats
    <<~EOS
      turbo-rag binaries (turbo-ragctl, turbo-rag-engine, turbo-rag-mcp)
      are installed; the engine is NOT yet wired to launchd.

      Next step:
        turbo-ragctl install --mode <always-on|on-demand>

      The binaries are a self-contained frozen bundle — no Python, venv, or
      PYTHONPATH is involved, and `brew upgrade` swaps the bundle atomically
      under opt/ without stranding the launchd agent.

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
    # Self-contained: the formula declares no python@3.13 dependency.
    assert_empty deps.select { |d| d.name == "python@3.13" }
  end
end
