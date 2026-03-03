class CcProxy < Formula
  include Language::Python::Virtualenv

  desc "Claude Code proxy for NVIDIA NIM, OpenRouter, and LM Studio"
  homepage "https://github.com/rainbow-365/free-claude-code"
  url "https://github.com/rainbow-365/free-claude-code/archive/f3b6ab0.tar.gz"
  sha256 "e46754e41e5c7d2d2306b6939e0c23db281e3f7a422a82b365cc59025ffdf6aa"
  version "2.0.0-f3b6ab0"
  license "MIT"
  head "https://github.com/rainbow-365/free-claude-code.git", branch: "codex/homebrew-stabilization"

  depends_on "python@3.14"

  def install
    virtualenv_create(libexec, "python3.14")
    python = Formula["python@3.14"].opt_bin/"python3.14"
    system python, "-m", "pip", "--python=#{libexec}", "install", buildpath
    bin.install_symlink libexec/"bin/cc-nim"
  end

  def post_install
    config = Pathname.new(Dir.home) / ".ccenv"
    return if config.exist?

    system({ "CCPROXY_CONFIG" => config.to_s }, bin/"cc-nim", "init")
  end

  service do
    run [opt_bin/"cc-nim", "start"]
    keep_alive true
    log_path var/"log/cc-proxy.log"
    error_log_path var/"log/cc-proxy-error.log"
  end

  test do
    output = shell_output("#{bin}/cc-nim 2>&1", 1)
    assert_match "Usage: cc-nim", output
  end
end
