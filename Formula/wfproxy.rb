require "formula"

class Wfproxy < Formula
  homepage "https://www.wavefront.com"
  url "https://wavefront-cdn.s3.us-west-2.amazonaws.com/brew/wavefront-proxy-11.1.0.zip"
  sha256 "3deda82f3c7673ad672ac56ce1d42cb6e2c88c490c63cf6baca6d90966b99122"

  depends_on "telegraf" => :optional

  def install
	lib.install "lib/proxy-uber.jar"
  	bin.install "bin/wfproxy"
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront").mkpath
    etc.install "etc/wfproxy.conf" => "wavefront/wavefront-proxy/wavefront.conf"
    etc.install "etc/log4j2.xml" => "wavefront/wavefront-proxy/log4j2.xml"
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
