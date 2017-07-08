require "formula"

class Wfproxy < Formula
  homepage "https://www.wavefront.com"
  url "http://wavefront-cdn.s3-website-us-west-2.amazonaws.com/brew/wfproxy-4.12.0.tar.gz"
  sha256 "05a43d0aed735a0cc5ffee277366b03404499959e2d1d772ec141e05ffc3daec"

  bottle :unneeded

  depends_on :java => "1.8+"
  depends_on "wftelegraf" => :optional

  def install
	lib.install "lib/proxy-uber.jar"
  	bin.install "bin/wfproxy"
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront").mkpath
    etc.install "etc/wfproxy.conf" => "wavefront/wavefront-proxy/wavefront.conf"
  end

  plist_options :manual => "wfproxy -f #{HOMEBREW_PREFIX}/etc/wavefront/wavefront-proxy/wavefront.conf"

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
