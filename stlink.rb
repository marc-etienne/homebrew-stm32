require "formula"

class Stlink < Formula
  version '1.0.0'
  homepage 'https://github.com/texane/stlink'
  url 'https://github.com/texane/stlink/archive/1.0.0.tar.gz'
  sha256 'd80af441be2c2be8a8e431e4ff6608f7c5ae52017c590d1c04b28bf0af0a3ddb'

  head do
    url 'https://github.com/texane/stlink.git'
  end

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libusb' => :build
  depends_on 'pkg-config' => :build

  def install
    system './autogen.sh'
    system "./configure --prefix=#{prefix}"
    system 'make install'
  end

  test do
    system "st-info"
  end
end
