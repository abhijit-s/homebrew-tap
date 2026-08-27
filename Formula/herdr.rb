class Herdr < Formula
  desc "Terminal-based agent runtime for coding agents (abhijit-s fork)"
  homepage "https://github.com/abhijit-s/herdr"
  version "0.8.3-abhi.1"
  license "Apache-2.0"

  # Fork of herdrdev/herdr. See FORK.md in the repo for what diverges upstream.
  # Prebuilt binaries come from this fork's GitHub releases; --HEAD builds from
  # source and needs the same Rust + Zig toolchain upstream requires.
  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3-abhi.1/herdr-macos-aarch64"
      sha256 "31e8fe6d00470d3bc339d12e0b1fb6323fe5efb3690cf5343e4cabacbf78c57b"
    end
    on_intel do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3-abhi.1/herdr-macos-x86_64"
      sha256 "4217820421595b1a3e24efd1170cc97244cba2cd554541ca0e0017b57f068e34"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3-abhi.1/herdr-linux-aarch64"
      sha256 "d0e375125605792be6c64c414b4529fb48e366f322223b3a3e333118953aa840"
    end
    on_intel do
      url "https://github.com/abhijit-s/herdr/releases/download/v0.8.3-abhi.1/herdr-linux-x86_64"
      sha256 "64aac8985e2d3f0d2bf5c43e0f0e664db1eedd11b585644739ca2675e90867ce"
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

      Fork releases use a semver prerelease suffix so they sort below the
      equivalent upstream version.
    EOS
  end

  test do
    assert_match "herdr", shell_output("#{bin}/herdr --version")
  end
end
