# Polymer: bridging polyhedral tools to MLIR

- You can find the original README.md here [README-ORIGINAL.md](README-ORIGINAL.md).
- Setup for Polygeist commit `2e6bb368ff4894993eb2102c1da3389fa18e49ef`. llvm-project lives inside `polygeist`. The LLVM commit is `30d87d4a5d02f00ef58ebc24a0ee5c6c370b8b4c` (clang version `14.0.0`)




# Major Changes

## `cmake/AddPluto.cmake` update (Or special feature)

- This change will make sure, **once you build polymer, then `pluto` is not needed to build again and again.**




# How to build Polymer

## pre-requisite

- `cmake`, `ninja` required.

## You need specific `llvm-9` build that required for `pet-for-pluto`. Check [`scripts/build-llvm-9-for-polymer-pluto.sh`](scripts/build-llvm-9-for-polymer-pluto.sh)

```sh
# Src is added as submodule "llvm-9-src-for-polymer-pluto"
# Build llvm-9
scripts/build-llvm-9-for-polymer-pluto.sh
```

## You also need the `llvm-project` shipped with compatible polygeist to build the Polymer.

- Clone

```sh
mkdir -p llvm-14-src-from-polygeist

cd llvm-14-src-from-polygeist

git clone https://github.com/llvm/llvm-project.git .

git checkout 30d87d4a5d02f00ef58ebc24a0ee5c6c370b8b4c


# Create a shell to build
touch scripts/build-llvm-14-src-for-polymer.sh

chmod +x scripts/build-llvm-14-src-for-polymer.sh
```


- Load `scripts/build-llvm-14-src-for-polymer.sh` with following content. Check [`scripts/build-llvm-14-src-for-polymer.sh`](scripts/build-llvm-14-src-for-polymer.sh)

```sh
# The absolute path to the directory of this script. (not used)
BUILD_SCRIPT_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Project root dir (i.e. polsca/)
POLYMER_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../ && pwd )"


# Go to the llvm directory and carry out installation.
POLYGEIST_LLVM_DIR="${POLYMER_ROOT_DIR}/llvm-14-src-from-polygeist"


# Set your build folder name
BUILD_FOLDER_NAME="llvm-14-src-build-for-polymer"
INSTALLATION_FOLDER_NAME="${BUILD_FOLDER_NAME}-installation"


BUILD_FOLDER_DIR="${POLYMER_ROOT_DIR}/${BUILD_FOLDER_NAME}"
INSTALLATION_FOLDER_DIR="${POLYMER_ROOT_DIR}/${INSTALLATION_FOLDER_NAME}"


rm -Rf "${BUILD_FOLDER_DIR}" "${INSTALLATION_FOLDER_DIR}"

# Create the build folders in $POLYMER_ROOT_DIR
mkdir -p "${BUILD_FOLDER_DIR}" "${INSTALLATION_FOLDER_DIR}"

cd "${BUILD_FOLDER_DIR}"/


echo $POLYGEIST_LLVM_DIR
echo $BUILD_FOLDER_DIR


cmake   \
    -G Ninja    \
    -S "${POLYGEIST_LLVM_DIR}/llvm"  \
    -B .    \
    -DCMAKE_BUILD_TYPE=Release      \
    -DCMAKE_INSTALL_PREFIX="${INSTALLATION_FOLDER_DIR}"  \
    -DLLVM_ENABLE_PROJECTS="clang;mlir;lld" \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_INSTALL_UTILS=ON     \
    -DCMAKE_C_COMPILER=gcc    \
    -DCMAKE_CXX_COMPILER=g++    \
    -DLLVM_TARGETS_TO_BUILD="host"    \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DLLVM_ENABLE_ASSERTIONS=ON


# Run build
cmake --build . --target check-mlir
ninja install
```

- Now build

```sh
./scripts/build-llvm-14-src-for-polymer.sh
```


### How to add `llvm-9` & `llvm-14` build path to meet `polymer` & `pluto` (actually `pet-for-pluto` dependency) dependency

- Add your `llvm-9` src build or installation dir to the following `cmake` config variable. Check the build shell for better understanding.

```cmake
-DPLUTO_LIBCLANG_PREFIX="/path/to/polymer-root/llvm-9-src-build-for-polymer-pluto-installation/"
POLYGEIST_LLVM_BUILD_DIR="/path/to/llvm-14-src-build-for-polymer"

-DMLIR_DIR="${POLYGEIST_LLVM_BUILD_DIR}/lib/cmake/mlir"
-DLLVM_DIR="${POLYGEIST_LLVM_BUILD_DIR}/lib/cmake/llvm"
-DLLVM_EXTERNAL_LIT="${POLYGEIST_LLVM_BUILD_DIR}/bin/llvm-lit"
```



## Build shell

```sh

# The absolute path to the directory of this script.
# Guess, your polymer lives here.
BUILD_SCRIPT_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Go to the llvm directory and carry out installation.
POLYGEIST_LLVM_BUILD_DIR="/path/to/llvm-build-for-polygeist"


# This is mandatory to satify pluto's "pet-for-pluto" clang dependency.
PLUTO_LIBCLANG_PREFIX_DIR="/path/to/llvm-9-src-build/installation"


# Set Polymer build folder name
BUILD_FOLDER_NAME="polymer-build"
INSTALLATION_FOLDER_NAME="${BUILD_FOLDER_NAME}-installation"

# Create the build folders in $BUILD_SCRIPT_ROOT_DIR
BUILD_FOLDER_DIR="${BUILD_SCRIPT_ROOT_DIR}/${BUILD_FOLDER_NAME}"
INSTALLATION_FOLDER_DIR="${BUILD_SCRIPT_ROOT_DIR}/${INSTALLATION_FOLDER_NAME}"


rm -Rf "${BUILD_FOLDER_DIR}" "${INSTALLATION_FOLDER_DIR}"
mkdir -p "${BUILD_FOLDER_DIR}" "${INSTALLATION_FOLDER_DIR}"
cd "${BUILD_FOLDER_DIR}"/


cmake   \
    -G Ninja    \
    -S "${BUILD_SCRIPT_ROOT_DIR}"  \
    -B .    \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DCMAKE_INSTALL_PREFIX="${INSTALLATION_FOLDER_DIR}"  \
    -DMLIR_DIR="${POLYGEIST_LLVM_BUILD_DIR}/lib/cmake/mlir" \
    -DLLVM_DIR="${POLYGEIST_LLVM_BUILD_DIR}/lib/cmake/llvm" \
    -DLLVM_EXTERNAL_LIT="${POLYGEIST_LLVM_BUILD_DIR}/bin/llvm-lit" \
    -DPLUTO_LIBCLANG_PREFIX="${PLUTO_LIBCLANG_PREFIX_DIR}"  \
    -DLLVM_ENABLE_ASSERTIONS=ON


# Mandatory for avoiding regression test failure (libosl.so.0 linker error)
export LD_LIBRARY_PATH="${BUILD_FOLDER_DIR}/pluto/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"


# Run build
cmake --build . --target check-polymer
ninja install
```