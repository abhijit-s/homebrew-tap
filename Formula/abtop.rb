class Abtop < Formula
  desc "AI agent monitor for your terminal"
  homepage "https://github.com/abhijit-s/abtop"
  version "0.6.1"

  on_macos do
    on_arm do
      url "https://github.com/abhijit-s/abtop/releases/download/v0.6.1/abtop-aarch64-apple-darwin.tar.xz"
      sha256 "d3004841f4fee6e9273dbab0191b68b8d2bc216d391364b6dde5582867837e50"
    end
  end

  license "MIT"

  def install
    bin.install "abtop"
  end
end
