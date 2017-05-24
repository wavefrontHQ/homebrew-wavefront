require "formula"

class Wftelegraf < Formula
  homepage "https://www.wavefront.com"
  url "https://github.com/vikramraman/homebrew-wfproxy/raw/master/files/telegraf/1.3.0/telegraf-1.3.0.tar.gz"
  sha256 "55260be83d1cbb8823e92eac21fc507a4731970ef5da06b13661b2cbf4e7b8c1"

  bottle :unneeded

  def install
    bin.install "bin/telegraf"
  end

  def post_install
    # Create directory for additional user configurations
    (etc/"telegraf.d").mkpath
  end

  plist_options :manual => "telegraf -config #{HOMEBREW_PREFIX}/etc/telegraf.conf"
end
