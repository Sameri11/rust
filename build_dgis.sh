#!/bin/bash
set -euxo

# 1. Select the best branch, tag or commit hash from https://github.com/apple/llvm-project
# The recommended approach is to use the tagged release that matches the Swift version
# returned by the command below:
# $ xcrun -sdk iphoneos swiftc --version

LLVM_BRANCH="tags/swift-5.3.2-RELEASE"

# 2. Select the best branch, tag or commit hash from https://github.com/rust-lang/rust

RUST_BRANCH="custom-targets"

# 3. Select a name for the toolchain you want to install as. The toolchain will be installed
# under $HOME/.rustup/toolchains/rust-$RUST_TOOLCHAIN

RUST_TOOLCHAIN="ios-nsdk-custom"


export OPENSSL_STATIC=1
export OPENSSL_DIR=/usr/local/opt/openssl
if [ ! -d "$OPENSSL_DIR" ]; then
    echo "OpenSSL not found at expected location. Try: brew install openssl"
    exit 1
fi
if ! which ninja; then
    echo "ninja not found. Try: brew install ninja"
    exit 1
fi
if ! which cmake; then
    echo "cmake not found. Try: brew install cmake"
    exit 1
fi

BASE_DIR="$(pwd)"
WORKING_DIR="$(pwd)/build"
mkdir -p "$WORKING_DIR"

cd "$WORKING_DIR"
if [ ! -d "$WORKING_DIR/llvm-project" ]; then
    git clone https://github.com/apple/llvm-project.git
fi
cd "$WORKING_DIR/llvm-project"
git reset --hard
git clean -f
git checkout "$LLVM_BRANCH"
git apply ../../patches/llvm-system-libs.patch
cd ..

mkdir -p llvm-build
cd llvm-build
cmake "$WORKING_DIR/llvm-project/llvm" -DCMAKE_INSTALL_PREFIX="$WORKING_DIR/llvm-root" -DCMAKE_BUILD_TYPE=Release -DLLVM_INSTALL_UTILS=ON -DLLVM_TARGETS_TO_BUILD='X86;ARM;AArch64' -G Ninja
ninja
ninja install

cd "$BASE_DIR"

git reset --hard
mkdir -p "$WORKING_DIR/rust-build"
cd "$WORKING_DIR/rust-build"
../../configure --llvm-config="$WORKING_DIR/llvm-root/bin/llvm-config" --enable-extended --tools=cargo --release-channel=nightly
python ../../x.py build -i --target=x86_64-apple-ios,x86_64-apple-ios12.0-simulator,aarch64-apple-ios,aarch64-apple-ios12.0,aarch64-apple-ios12.0-simulator --stage 2

DEST_TOOLCHAIN="$HOME/.rustup/toolchains/$RUST_TOOLCHAIN"

# Remove unneeded files from output
rm -rf "$WORKING_DIR/rust-build/build/x86_64-apple-darwin/stage2/lib/rustlib/src"

rm -rf "$DEST_TOOLCHAIN"
mkdir -p "$DEST_TOOLCHAIN"
cp -r "$WORKING_DIR/rust-build/build/x86_64-apple-darwin/stage2"/* "$DEST_TOOLCHAIN"
cp -r "$WORKING_DIR/rust-build/build/x86_64-apple-darwin/stage2-tools/x86_64-apple-darwin/release/cargo" "$DEST_TOOLCHAIN/bin"

echo "Installed bitcode-enabled Rust toolchain. Use with: +$RUST_TOOLCHAIN"