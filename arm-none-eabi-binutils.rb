require 'formula'

class ArmNoneEabiBinutils < Formula
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  url 'https://ftpmirror.gnu.org/binutils/binutils-2.30.tar.gz'
  mirror 'https://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.gz'
  sha256 '8c3850195d1c093d290a716e20ebcaa72eda32abf5e3d8611154b39cff79e9ea'

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
