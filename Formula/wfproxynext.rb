require "formula"

class Wfproxynext < Formula
  homepage "https://www.wavefront.com"
  url "http://wavefront-cdn.s3-website-us-west-2.amazonaws.com/brew/wfproxy-4.37.0.tar.gz"
  sha256 "e2a0d18edc81933a31045a5a068569088cf6ec8c1c434e275af275261dd3e0f3"

  bottle :unneeded

  depends_on "telegraf" => :optional

  def install
	lib.install "lib/proxy-uber.jar"
	lib.install "lib/jdk"
  	bin.install "bin/wfproxy"
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront").mkpath
    etc.install "etc/wfproxy.conf" => "wavefront/wavefront-proxy/wavefront.conf"
  end

  plist_options :manual => "wfproxy -f #{HOMEBREW_PREFIX}/etc/wavefront/wavefront-proxy/wavefront.conf"

  def plist; <<-EOS
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
          <string>#{etc}/wavefront/wavefront-proxy/wavefront.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}/spool/wavefront-proxy</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/wavefront/wavefront.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/wavefront/wavefront.log</string>
      </dict>
    </plist>
    EOS
  end
end
