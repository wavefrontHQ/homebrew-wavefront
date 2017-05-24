require "formula"

class Wfproxy < Formula
  homepage "https://www.wavefront.com"
  url "https://github.com/vikramraman/homebrew-wfproxy/raw/master/files/4.6.0/wfproxy-4.6.0.tar.gz"
  sha256 "a3a0401bb68e1d17bc3fc56b3f0712ed9642dbdf89178a08d4cb3141d93ea8f1"

  bottle :unneeded

  depends_on :java => "1.8+"

  def install
	lib.install "lib/proxy-uber.jar"
  	bin.install "bin/wfproxy"
  end
end
