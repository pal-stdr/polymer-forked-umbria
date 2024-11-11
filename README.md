# Polymer: bridging polyhedral tools to MLIR

- You can find the original README.md here [README-ORIGINAL.md](README-ORIGINAL.md).
- Setup for Polygeist commit `2e6bb368ff4894993eb2102c1da3389fa18e49ef`. llvm-project lives inside `polygeist`. The LLVM commit is `30d87d4a5d02f00ef58ebc24a0ee5c6c370b8b4c` (clang version `14.0.0`)




# Major Changes

## `cmake/AddPluto.cmake` update (Or special feature)

- This change will make sure, **once you build polymer, then `pluto` is not needed to build again and again.**




# How to build Polymer

## pre-requisite

- `cmake`, `ninja` required.

- You need specific `llvm` build that has been used for polygeist. First clone it

```sh
git clone -b release/9.x --depth 1 https://github.com/llvm/llvm-project.git llvm-9-src-build
```

- Then use the following build shell.

```sh
mkdir -p build installation
cd build/

echo $PWD

cmake   \
    -G Ninja    \
    -S ../llvm  \
    -B .    \
    -DCMAKE_BUILD_TYPE=Release      \
    -DCMAKE_INSTALL_PREFIX=../installation  \
    -DLLVM_ENABLE_PROJECTS="llvm;clang;lld" \
    -DLLVM_INSTALL_UTILS=ON

cmake --build .

ninja install
```


### How to add `llvm-9` build path to meet `pluto` dependency (actually `pet-for-pluto` dependency)

- Add your `llvm-9` src build or installation dir to the following `cmake` config variable. Check the build shell for better understanding.

```cmake
-DPLUTO_LIBCLANG_PREFIX="/path/to/llvm-9-src-build/installation"
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