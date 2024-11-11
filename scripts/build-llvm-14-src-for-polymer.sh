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