class Wfproxy < Formula
  homepage "https://www.wavefront.com"
  url "https://wavefront-cdn-dev.s3.us-west-2.amazonaws.com/wavefront-proxy/wfproxy_11.2-SNAPSHOT_20220523-153903.zip"
  sha256 "d95b60167323028c25b51152380d4a9a909fe0ac"

  depends_on "telegraf" => :optional
  depends_on "openjdk@11" => :optional

  def install
	lib.install "wavefront-proxy.jar"
  	bin.install "wfproxy"
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront").mkpath
    etc.install "proxy.conf" => "wavefront/wavefront-proxy/wavefront.conf"
    etc.install "log4j2.xml" => "wavefront/wavefront-proxy/log4j2.xml"
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
