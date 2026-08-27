class Herdr < Formula
  desc "Terminal-based agent runtime for coding agents (abhijit-s fork)"
  homepage "https://github.com/abhijit-s/herdr"
  version "0.8.3"
  license "Apache-2.0"

  # Fork of herdrdev/herdr. See FORK.md in the repo for what diverges upstream.
  # Prebuilt binaries come from this fork's GitHub releases; --HEAD builds from
  # source and needs the same Rust + Zig toolchain upstream requires.
  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3/herdr-macos-aarch64"
      sha256 "8d04609fdda80cb993651fbda8237118d521fd7591da1372663fdc2392926216"
    end
    on_intel do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3/herdr-macos-x86_64"
      sha256 "5ace90c80417c6dbcd915a6c12a5960626bfa63786b94d24eefab51405256c7e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3/herdr-linux-aarch64"
      sha256 "28d1c23036852c14bd8a2d17378c8c91eca94598368beb68a8ca42870cd1c5d1"
    end
    on_intel do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3/herdr-linux-x86_64"
      sha256 "81ef5fa44a3dc4f338594c5ee47eaed0bae9ad5288db9c42ebc3466d5801557f"
    end
  end

  head do
    url "https://github.com/abhijit-s/herdr.git", branch: "master"
    depends_on "rust" => :build
    depends_on "zig@0.15" => :build
  end

  def install
    if build.head?
      system "cargo", "build", "--release", "--locked"
      bin.install "target/release/herdr"
    else
      # Release assets are bare binaries named per platform.
      binary = Dir["herdr-*"].first
      bin.install binary => "herdr"
    end
  end

  def caveats
    <<~EOS
      This is the abhijit-s fork of herdr, not upstream herdrdev/herdr.
      Fork-only changes are inventoried in:
        https://github.com/abhijit-s/herdr/blob/master/FORK.md

      It conflicts with the homebrew-core herdr formula. If that one is
      installed, unlink it first:
        brew unlink herdr

      Fork releases reuse upstream's next patch number: herdr's own version
      model reserves the -suffix form for its channel/build identity, so a
      semver prerelease in Cargo.toml makes update checks and plugin gating
      panic.
    EOS
  end

  test do
    assert_match "herdr", shell_output("#{bin}/herdr --version")
  end
end
