# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Build in docker:
# docker run -it --rm --name paul_grpc debian
# apt update
# apt install -y python3 python3-distutils wget nano tmux
# echo "alias python=\"python3\"" >> ~/.bashrc && . ~/.bashrc
# python <(wget -qO- https://bootstrap.pypa.io/get-pip.py) --user
# echo "export PATH=\"\$PATH:\$HOME/.local/bin\"" >> ~/.bashrc && . ~/.bashrc
# pip install --user conan
# conan remote add bintray_grpc https://api.bintray.com/conan/inexorgame/inexor-conan
# ============================================================================ #
rm -rf build ;
mkdir build &&
pushd build &&
conan install .. &&
conan build .. &&
ls -la bin ;
popd
# ============================================================================ #

