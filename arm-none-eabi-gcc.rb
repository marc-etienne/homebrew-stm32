require 'formula'

class ArmNoneEabiGcc < Formula
  homepage 'http://www.gnu.org/software/gcc/gcc.html'
  url 'http://ftpmirror.gnu.org/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/releases/gcc-5.3.0/gcc-5.3.0.tar.bz2'
  sha256 'b84f5592e9218b73dbae612b5253035a7b34a9a1f7688d2e1bfaaf7267d5c4db'

  # http://sourceware.org/newlib/
  resource 'newlib' do
    url 'ftp://sourceware.org/pub/newlib/newlib-2.3.0.20160104.tar.gz'
    sha256 'c92a0e02904bd4fbe1dd416ed94e786c66afbaeae484e4c26be8bb7c7c1e4cd1'
  end

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'cloog'
  depends_on 'isl'

  depends_on 'arm-none-eabi-binutils'

  option 'disable-cxx', 'Don\'t build the g++ compiler'

  patch do
    url "https://projects.archlinux.org/svntogit/community.git/plain/trunk/enable-with-multilib-list-for-arm.patch?h=packages/arm-none-eabi-gcc&id=b8718ed4f7eabe7125419f8c4e4e89a98ca85950"
    sha256 "ee8c74097c1ff01918bda9acf9b45783fd3ba3a4c493e9e9255fa3c2130bf690"
  end

  def install
    resource('newlib').stage do
      (buildpath).install Dir['newlib', 'libgloss']
    end

    # See https://gcc.gnu.org/ml/gcc/2014-05/msg00014.html
    ENV["CC"]  += " -fbracket-depth=1024"
    ENV["CXX"] += " -fbracket-depth=1024"

    # The C compiler is always built, C++ can be disabled
    languages = %w[c]
    languages << 'c++' unless build.include? 'disable-cxx'

    args = [
            "--target=arm-none-eabi",
            "--prefix=#{prefix}",

            "--enable-multilib",
            "--enable-interwork",
            "--with-multilib-list=armv6-m,armv7-m,armv7e-m,armv7-r,armv7-a",
            "--enable-languages=#{languages.join(',')}",
            "--with-gnu-as",
            "--with-gnu-ld",
            "--with-ld=#{Formula["arm-none-eabi-binutils"].opt_bin/'arm-none-eabi-ld'}",
            "--with-as=#{Formula["arm-none-eabi-binutils"].opt_bin/'arm-none-eabi-as'}",
            "--with-newlib",
            "--with-headers=newlib/libc/include",

            "--disable-nls",
            "--disable-shared",
            "--disable-threads",
            "--disable-libssp",
            "--disable-libstdcxx-pch",
            "--disable-libgomp",
            "--disable-newlib-supplied-syscalls",

            "--with-gmp=#{Formula["gmp"].opt_prefix}",
            "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
            "--with-mpc=#{Formula["libmpc"].opt_prefix}",
            "--with-cloog=#{Formula["cloog"].opt_prefix}",
            "--with-isl=#{Formula["isl"].opt_prefix}",
            "--with-system-zlib"
    ]

    mkdir 'build' do
      system "../configure", *args
      system "make"

      ENV.deparallelize
      system "make install"
    end

    # info and man7 files conflict with native gcc
    info.rmtree
    man7.rmtree

    # stdcxx's python helpers may conflict with native gcc
    (share + "gcc-#{version}/python").rmtree
  end
end
