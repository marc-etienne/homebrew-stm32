require 'formula'

class ArmNoneEabiBinutils < Formula
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  url 'http://ftpmirror.gnu.org/binutils/binutils-2.25.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz'
  sha256 'cccf377168b41a52a76f46df18feb8f7285654b3c1bd69fc8265cb0fc6902f2d'

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
