class Wfproxynext < Formula
  homepage "https://www.wavefront.com"
  url "https://wavefront-cdn.s3.us-west-2.amazonaws.com/brew/wavefront-proxy-12.0.0.zip"
  sha256 "0022bd3dcde2ab8d12e71796e8805244045401228bcf5a03befba0dd80f6f4a9"

  depends_on "telegraf" => :optional
  depends_on "java11" => :recommended

  def install
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront-proxy").mkpath

    lib.install "wavefront-proxy.jar"
    bin.install "wfproxy" => "wfproxynext"
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

  plist_options :manual => "wfproxynext"

  service do
    log_path var/"log/wavefront-proxy/stdout.log"
    error_log_path var/"log/wavefront-proxy/stderr.log"
    keep_alive true
    run bin/"wfproxynext"
  end
end
