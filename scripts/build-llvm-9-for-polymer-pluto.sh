# The absolute path to the directory of this script.
BUILD_SCRIPT_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Project root dir (i.e. polsca/)
POLYMER_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../ && pwd )"

# LLVM-9 dir
LLVM_9_DIR="${POLYMER_ROOT_DIR}/llvm-9-src-for-polymer-pluto/"


# Set llvm-9 build folder name
BUILD_FOLDER_NAME="llvm-9-src-build-for-polymer-pluto"
INSTALLATION_FOLDER_NAME="${BUILD_FOLDER_NAME}-installation"


# Create the build folders in $POLYMER_ROOT_DIR
BUILD_FOLDER_DIR="${POLYMER_ROOT_DIR}/${BUILD_FOLDER_NAME}"
INSTALLATION_FOLDER_DIR="${POLYMER_ROOT_DIR}/${INSTALLATION_FOLDER_NAME}"


rm -Rf "${BUILD_FOLDER_DIR}" "${INSTALLATION_FOLDER_DIR}"
mkdir -p "${BUILD_FOLDER_DIR}" "${INSTALLATION_FOLDER_DIR}"
cd "${BUILD_FOLDER_DIR}"/

echo $PWD

cmake   \
    -G Ninja    \
    -S "${LLVM_9_DIR}/llvm"  \
    -B .    \
    -DCMAKE_BUILD_TYPE=Release      \
    -DCMAKE_INSTALL_PREFIX="${INSTALLATION_FOLDER_DIR}"  \
    -DLLVM_ENABLE_PROJECTS="llvm;clang;lld" \
    -DLLVM_INSTALL_UTILS=ON

cmake --build .

ninja install