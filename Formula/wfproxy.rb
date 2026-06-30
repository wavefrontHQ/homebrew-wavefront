class Wfproxy < Formula
  homepage "https://www.wavefront.com"
  url "https://51811f5f5eecd3a2.tobs.sptobsg1.vmw.saas.broadcom.com/wf-proxy/brew_wavefront-proxy-15.1.0.zip"
  sha256 "79fd040994eafc716ddd9876d020be8661b37a7816eefcdcdcdcf80c59c30e5a"

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

  service do
    require_root true
    log_path var/"log/wavefront-proxy/stdout.log"
    error_log_path var/"log/wavefront-proxy/stderr.log"
    keep_alive true
    run bin/"wfproxy"
  end
end
