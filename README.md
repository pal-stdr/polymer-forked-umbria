# Polymer: bridging polyhedral tools to MLIR

- You can find the original README.md here [README-ORIGINAL.md](README-ORIGINAL.md).




# Major Changes

## `cmake/AddPluto.cmake` update

- This change will make sure, **once you build polymer, then `pluto` is not needed to build again and again.**


### How to add `llvm-9` build path to meet `pluto` dependency (actually `pet-for-pluto` dependency)

- At `line 15`, please add your `llvm-9` src build path like

```cmake
set(PLUTO_LIBCLANG_PREFIX "path/to/llvm-9-src-build/installation" CACHE STRING
    "The prefix to libclang used by Pluto (version < 10 required).")
```



# How to build Polymer

## pre-requisite

- You need specific `llvm` build that has been used for polygeist

## Build shell

```sh

# The absolute path to the directory of this script.
BUILD_SCRIPT_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Go to the polygeist llvm directory and carry out installation.
POLYGEIST_LLVM_BUILD_DIR="/path/to/llvm-build-for-polygeist-polymer-polsca"


# Set Polymer build folder name
BUILD_FOLDER_NAME=polymer-build-for-polsca
INSTALLATION_FOLDER_NAME="${BUILD_FOLDER_NAME}"-installation

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
    -DLLVM_ENABLE_ASSERTIONS=ON


# Mandatory for avoiding regression test failure
export LD_LIBRARY_PATH="$PWD/pluto/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"


# Run build
cmake --build . --target check-polymer
ninja install
```