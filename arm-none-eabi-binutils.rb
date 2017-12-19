class ArmNoneEabiBinutils < Formula
  desc "FSF/GNU ld, ar, readelf, etc. for the ARM EABI development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  head "git://sourceware.org/git/binutils-gdb.git"

  stable do
    url "https://ftp.gnu.org/gnu/binutils/binutils-2.29.1.tar.xz"
    mirror "https://ftpmirror.gnu.org/gnu/binutils/binutils-2.29.1.tar.xz"
    sha256 "e7010a46969f9d3e53b650a518663f98a5dde3c3ae21b7d71e5e6803bc36b577"
  end

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

    mkdir "build" do
      system "../configure", *args

      system "make"
      system "make", "install"
    end
    # info files conflict with native binutils
    info.rmtree
  end

  test do
    system "#{bin}/arm-none-eabi-ar", "-h"
  end
end
