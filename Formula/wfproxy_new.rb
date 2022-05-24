class WfproxyNew < Formula
  homepage "https://www.wavefront.com"
  url "https://macos-testing-glaullon.s3.us-west-2.amazonaws.com/wfproxy_11.2-SNAPSHOT_20220524-115027.zip"
  sha256 "29bcf4d0db15caca6e734f00f0cf8f7a479f4ea0c0830372210a0a5e4ab381da"

  depends_on "telegraf" => :optional
  depends_on "openjdk@11" => :optional

  def install
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront").mkpath

    lib.install "wavefront-proxy.jar"
    bin.install "wfproxy" => "wfproxy_new"
    etc.install "wavefront.conf" => "wavefront/wavefront-proxy/wavefront.conf"
    etc.install "log4j2.xml" => "wavefront/wavefront-proxy/log4j2.xml"
  end

  plist_options :manual => "wfproxy_new"

  service do
    log_path var/"log/wavefront/stdout.log"
    error_log_path var/"log/wavefront/stderr.log"
    keep_alive true
    run bin/"wfproxy_new"
  end
end
