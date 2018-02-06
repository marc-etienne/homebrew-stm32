Homebrew-stm32
============
This repository contains tools for STM32 development as formulae for [Homebrew](https://github.com/mxcl/homebrew).

The formulae uses vanilla FSF sources to build the toolchain, ie not CodeSourcery or Linaro or similar.
Moreover, it does not use any prebuilt package such as those found at https://launchpad.net/gcc-arm-embedded. This makes the formula build time significant.

Current Versions
----------------
- gcc 5.3.0
- binutils 2.30
- newlib 2.3.0

Installing Homebrew-stm32 Formulae
--------------------------------
Just `brew tap marc-etienne/stm32` and then `brew install <formula>`.
