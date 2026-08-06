class Abtop < Formula
  desc "AI agent monitor for your terminal"
  homepage "https://github.com/abhijit-s/abtop"
  version "0.6.3"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/abhijit-s/abtop/releases/download/v0.6.3/abtop-aarch64-apple-darwin.tar.xz"
      sha256 "13ad06537cfa2a329c45c7e2a4ef1758341410a550a8471592c4b6c94274d9a2"
    end
    if Hardware::CPU.intel?
      url "https://github.com/abhijit-s/abtop/releases/download/v0.6.3/abtop-x86_64-apple-darwin.tar.xz"
      sha256 "fe8898c9c64904343f1fb578e742027a15e977b96d8f7c0c7a70b7c25d5de12d"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/abhijit-s/abtop/releases/download/v0.6.3/abtop-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "44d6ca37cb3544ce04c9e95e157d2cfe5ef34dee59903de7f47b97baebd938af"
    end
    if Hardware::CPU.intel?
      url "https://github.com/abhijit-s/abtop/releases/download/v0.6.3/abtop-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "a4aaa19cf9ff59b9da3ac403edaa2e6f517cd78bc565adfb4f93f878e2f6f951"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-apple-darwin": {},
    "x86_64-unknown-linux-gnu": {}
  }

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "abtop"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "abtop"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "abtop"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "abtop"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
