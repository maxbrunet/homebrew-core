class Termshark < Formula
  desc "Terminal UI for tshark, inspired by Wireshark"
  homepage "https://termshark.io"
  url "https://github.com/gcla/termshark/archive/v2.4.0.tar.gz"
  sha256 "949c71866fcd2f9ed71a754ea9e3d1bdc23dee85969dcdc78180f1d18ca8b087"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "bf549bc000877e1862c26ed6d3a1f466c09bc48fcb4488f6fe464738c717c986"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "9fc25d8ee00903f6f3ce91d3cde70c12dc636d51050f938f2230a1bb6eaabbba"
    sha256 cellar: :any_skip_relocation, monterey:       "6da8cd2b25fecd0edbac43ee4cc688932f46212624735c4cb655e76b7276d690"
    sha256 cellar: :any_skip_relocation, big_sur:        "4e8111a7730d4d042b4654689d0baa4e1cec23c658fc75f62f552d5d7f553843"
    sha256 cellar: :any_skip_relocation, catalina:       "8dc2114b14d2738361021fef34e5069de185371c5828c1528fe7fbd3a5543aec"
    sha256 cellar: :any_skip_relocation, mojave:         "a665f8f658b7699ff18acf7a8ac29658a90b694d368438fb7082b068d0ae426c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "3502b76bdc682ba2dea3ec1fc463c52e087ea5f9a390a0e26314d7e5402ca869"
  end

  depends_on "go" => :build
  depends_on "socat" => :test
  depends_on "wireshark"

  def install
    # Don't set GOPATH because we want to build using go modules to
    # ensure our dependencies are the ones specified in go.mod.
    mkdir_p buildpath
    ln_sf buildpath, buildpath/"termshark"

    cd "termshark" do
      system "go", "build", "-o", bin/"termshark",
             "cmd/termshark/termshark.go"
    end
  end

  test do
    assert_match "termshark v#{version}",
                 shell_output("#{bin}/termshark -v --pass-thru=false")

    # Build a test pcap programmatically. Termshark will read this
    # from a temp file.
    packet = []
    packet += [0xd4, 0xc3, 0xb2, 0xa1, 0x02, 0x00, 0x04, 0x00]
    packet += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    packet += [0x00, 0x00, 0x04, 0x00, 0x06, 0x00, 0x00, 0x00]
    packet += [0xf3, 0x2a, 0x39, 0x52, 0x00, 0x00, 0x00, 0x00]
    packet += [0x4d, 0x00, 0x00, 0x00, 0x4d, 0x00, 0x00, 0x00]
    packet += [0x10, 0x40, 0x00, 0x20, 0x35, 0x01, 0x2b, 0x59]
    packet += [0x00, 0x06, 0x29, 0x17, 0x93, 0xf8, 0xaa, 0xaa]
    packet += [0x03, 0x00, 0x00, 0x00, 0x08, 0x00, 0x45, 0x00]
    packet += [0x00, 0x37, 0xf9, 0x39, 0x00, 0x00, 0x40, 0x11]
    packet += [0xa6, 0xdb, 0xc0, 0xa8, 0x2c, 0x7b, 0xc0, 0xa8]
    packet += [0x2c, 0xd5, 0xf9, 0x39, 0x00, 0x45, 0x00, 0x23]
    packet += [0x8d, 0x73, 0x00, 0x01, 0x43, 0x3a, 0x5c, 0x49]
    packet += [0x42, 0x4d, 0x54, 0x43, 0x50, 0x49, 0x50, 0x5c]
    packet += [0x6c, 0x63, 0x63, 0x6d, 0x2e, 0x31, 0x00, 0x6f]
    packet += [0x63, 0x74, 0x65, 0x74, 0x00, 0xf3, 0x2a, 0x39]
    packet += [0x52, 0x00, 0x00, 0x00, 0x00, 0x4d, 0x00, 0x00]
    packet += [0x00, 0x4d, 0x00, 0x00, 0x00, 0x10, 0x40, 0x00]
    packet += [0x20, 0x35, 0x01, 0x2b, 0x59, 0x00, 0x06, 0x29]
    packet += [0x17, 0x93, 0xf8, 0xaa, 0xaa, 0x03, 0x00, 0x00]
    packet += [0x00, 0x08, 0x00, 0x45, 0x00, 0x00, 0x37, 0xf9]
    packet += [0x39, 0x00, 0x00, 0x40, 0x11, 0xa6, 0xdb, 0xc0]
    packet += [0xa8, 0x2c, 0x7b, 0xc0, 0xa8, 0x2c, 0xd5, 0xf9]
    packet += [0x39, 0x00, 0x45, 0x00, 0x23, 0x8d, 0x73, 0x00]
    packet += [0x01, 0x43, 0x3a, 0x5c, 0x49, 0x42, 0x4d, 0x54]
    packet += [0x43, 0x50, 0x49, 0x50, 0x5c, 0x6c, 0x63, 0x63]
    packet += [0x6d, 0x2e, 0x31, 0x00, 0x6f, 0x63, 0x74, 0x65]
    packet += [0x74, 0x00]

    File.write("#{HOMEBREW_TEMP}/termshark-test.pcap", packet.pack("C*"))

    # Rely on exit code of grep - if termshark works correctly, it will
    # detect stdout is not a tty, defer to tshark and display the grepped IP.
    system [
      "#{bin}/termshark -r #{HOMEBREW_TEMP}/termshark-test.pcap",
      " | grep 192.168.44.123",
    ].join

    # Pretend to be a tty and run termshark with the temporary pcap. Queue up
    # 'q' and 'enter' to terminate.  Rely on the exit code of termshark, which
    # should be EXIT_SUCCESS/0. Output is piped to /dev/null to avoid
    # interfering with the outer terminal. The quit command is delayed five
    # seconds to provide ample time for termshark to load the pcap (there is
    # no external mechanism to tell when the load is complete).
    testcmds = [
      "{ sleep 5 ; echo q ; echo ; } | ",
      "socat - EXEC:'sh -c \\\"",
      "stty rows 50 cols 80 && ",
      "TERM=xterm ",
      "#{bin}/termshark -r #{HOMEBREW_TEMP}/termshark-test.pcap",
      "\\\"',pty,setsid,ctty > /dev/null",
    ]
    system testcmds.join

    # "Scrape" the terminal UI for a specific IP address contained in the test
    # pcap. Since the output contains ansi terminal codes, use the -a flag to
    # grep to ensure it's not treated as binary input.
    testcmds[5] = "\\\"',pty,setsid,ctty | grep -a 192.168.44.123 > /dev/null"
    system testcmds.join

    # Clean up.
    File.delete("#{HOMEBREW_TEMP}/termshark-test.pcap")
  end
end
