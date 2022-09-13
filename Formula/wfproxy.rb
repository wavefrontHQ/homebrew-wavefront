class Wfproxy < Formula
  homepage "https://www.wavefront.com"
  url "https://macos-testing-glaullon.s3.us-west-2.amazonaws.com/wfproxy_macos_11.4.zip"
  sha256 "035447a04ca46ac85c49989d4597cc189584845b9d2da1d0bf379069a368262c"

  depends_on "telegraf" => :optional
  depends_on "java11" => :recommended

  def install
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront-proxy").mkpath

    lib.install "wavefront-proxy.jar"
    bin.install "wfproxy" => "wfproxy"
    etc.install "wavefront.conf" => "wavefront/wavefront-proxy/wavefront.conf"
    etc.install "log4j2.xml" => "wavefront/wavefront-proxy/log4j2.xml"

    server = ENV["HOMEBREW_WF_URL"]
    key = ENV["HOMEBREW_WF_TK"]

    if server
      print "Using server: '"+server+"'\n"
      inreplace etc/"wavefront/wavefront-proxy/wavefront.conf", /server=.*/, "server="+server
    end

    if key
      print "Using token: '"+key+"'\n"
      inreplace etc/"wavefront/wavefront-proxy/wavefront.conf", /token=.*/, "token="+key
    end

  end

  plist_options :manual => "wfproxy"

  service do
    log_path var/"log/wavefront-proxy/stdout.log"
    error_log_path var/"log/wavefront-proxy/stderr.log"
    keep_alive true
    run bin/"wfproxy"
  end
end
