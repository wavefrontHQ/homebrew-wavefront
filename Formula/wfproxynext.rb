class Wfproxynext < Formula
  homepage "https://www.wavefront.com"
  url "https://wavefront-cdn.s3.us-west-2.amazonaws.com/brew/wavefront-proxy-11.4.0.zip"
  sha256 "badc1a2a819fb3b1a490d515d5da5aeccee640ee0775dc05d5cfe157fee255cf"

  depends_on "telegraf" => :optional
  depends_on "java11" => :recommended

  def install
    (etc/"wavefront/wavefront-proxy").mkpath
    (var/"spool/wavefront-proxy").mkpath
    (var/"log/wavefront-proxy").mkpath

    lib.install "wavefront-proxy.jar"
    bin.install "wfproxy"
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
