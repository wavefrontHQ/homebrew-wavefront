require "formula"

class Wfproxy < Formula
  homepage "https://www.wavefront.com"
  url "http://wavefront-cdn.s3-website-us-west-2.amazonaws.com/brew/wfproxy-4.6.0.tar.gz"
  sha256 "91c44bfdccf2247cdc02326ea8739104c696a4a53ce709b12bb23e10e01a7e68"

  bottle :unneeded

  depends_on :java => "1.8+"
  depends_on "wftelegraf" => :optional

  def install
	lib.install "lib/proxy-uber.jar"
  	bin.install "bin/wfproxy"
	etc.install "etc/wfproxy.conf"
  end

  plist_options :manual => "wfproxy -f #{HOMEBREW_PREFIX}/etc/wfproxy.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/wfproxy</string>
          <string>-f</string>
          <string>#{etc}/wfproxy.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/wfproxy.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/wfproxy.log</string>
      </dict>
    </plist>
    EOS
  end
end
