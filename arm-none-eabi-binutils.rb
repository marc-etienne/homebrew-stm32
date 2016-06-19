require 'formula'

class ArmNoneEabiBinutils < Formula
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  url 'http://ftpmirror.gnu.org/binutils/binutils-2.25.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz'
  sha1 'f10c64e92d9c72ee428df3feaf349c4ecb2493bd'

  def install
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--target=arm-none-eabi",
            "--prefix=#{prefix}",
            "--infodir=#{info}",
            "--mandir=#{man}",
            "--disable-werror",
            "--disable-nls",
            "--enable-multilib"]

    mkdir 'build' do
      system "../configure", *args

      system "make"
      system "make install"
    end

    info.rmtree # info files conflict with native binutils
  end
end
