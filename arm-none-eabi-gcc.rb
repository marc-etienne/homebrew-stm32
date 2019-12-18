require 'formula'

class ArmNoneEabiGcc < Formula
  homepage 'http://www.gnu.org/software/gcc/gcc.html'
  url 'https://ftpmirror.gnu.org/gcc/gcc-9.2.0/gcc-9.2.0.tar.xz'
  mirror 'https://gcc.gnu.org/pub/gcc/releases/gcc-9.2.0/gcc-9.2.0.tar.xz'
  sha256 'ea6ef08f121239da5695f76c9b33637a118dcf63e24164422231917fa61fb206'

  # http://sourceware.org/newlib/
  resource 'newlib' do
    url 'ftp://sourceware.org/pub/newlib/newlib-3.1.0.tar.gz'
    sha256 'fb4fa1cc21e9060719208300a61420e4089d6de6ef59cf533b57fe74801d102a'
  end

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'isl'

  depends_on 'arm-none-eabi-binutils'

  option 'disable-cxx', 'Don\'t build the g++ compiler'

  # Fix parallel build on APFS filesystem
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81797
  # Taken from homebrew-core/gcc:
  # https://github.com/Homebrew/homebrew-core/blob/dc0c6aa82e15ec88b75b91d1760b1f0e6230c899/Formula/gcc.rb#L62
  if MacOS.version >= :high_sierra
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/df0465c02a/gcc/apfs.patch"
      sha256 "f7772a6ba73f44a6b378e4fe3548e0284f48ae2d02c701df1be93780c1607074"
    end
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
            "--with-multilib-list=aprofile,rmprofile",
            "--enable-languages=#{languages.join(',')}",
            "--with-gnu-as",
            "--with-gnu-ld",
            "--with-ld=#{Formula["arm-none-eabi-binutils"].opt_bin/'arm-none-eabi-ld'}",
            "--with-as=#{Formula["arm-none-eabi-binutils"].opt_bin/'arm-none-eabi-as'}",
            "--with-newlib",
            "--with-headers=newlib/libc/include",

            "--disable-shared",
            "--disable-threads",
            "--disable-libssp",
            "--disable-libstdcxx-pch",
            "--disable-libgomp",
            "--disable-tls",

            "--disable-nls",
            "--disable-newlib-supplied-syscalls",
            "--enable-newlib-global-atexit",
            "--enable-newlib-nano-formatted-io",
            "--enable-newlib-reent-small",
            "--disable-newlib-fvwrite-in-streamio",
            "--disable-newlib-fseek-optimization",
            "--disable-newlib-wide-orient",
            "--enable-newlib-nano-malloc",
            "--disable-newlib-unbuf-stream-opt",
            "--enable-lite-exit",
            "--enable-target-optspace",

            "--with-gmp=#{Formula["gmp"].opt_prefix}",
            "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
            "--with-mpc=#{Formula["libmpc"].opt_prefix}",
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

    lib_paths = `#{prefix}/bin/arm-none-eabi-gcc -print-multi-lib`
    lib_paths.each_line.map { |line| line.split(";").first }.each do |lib_path|
      cd prefix/"arm-none-eabi/lib/#{lib_path}" do
        ["libc", "libg", "librdimon"].each do |lib_name|
          ln_s "#{lib_name}.a", "#{lib_name}_nano.a"
        end
      end
    end
  end

  test do
    (testpath/"noop.c").write "void _start() {}"
    system "#{bin}/arm-none-eabi-gcc", "-o", "noop", "-nostartfiles", "noop.c"
  end
end
