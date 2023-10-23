set -e

echo "pythonVersion: $1";
echo "pythonMajorVersion: $2";


# download python source, compile
echo "Download Python";
curl -O  https://www.python.org/ftp/python/$1/Python-$1.tgz
tar -zxvf Python-$1.tgz
cd Python-$1

# copy Setup to Modules
cp ../Setup.dist ./Modules

./configure --prefix=/Users/runner/Desktop/python --enable-optimizations
sudo make -j8
sudo make install -j8


# copy libintl.8.dylib to python/lib
sudo cp /usr/local/opt/gettext/lib/libintl.8.dylib /Users/runner/Desktop/python/lib/

# copy libssl.3.dylib and libcrypto.3.dylib to python/lib
sudo cp /usr/local/opt/openssl@3/lib/libssl.3.dylib /Users/runner/Desktop/python/lib/
sudo cp /usr/local/opt/openssl@3/lib/libcrypto.3.dylib /Users/runner/Desktop/python/lib/


cd /Users/runner/Desktop/python/

# check links in python
otool -l bin/python3
#Fix python's link: libintl.8
sudo install_name_tool -change /usr/local/opt/gettext/lib/libintl.8.dylib  @loader_path/../lib/libintl.8.dylib bin/python3

#Fix python's link: libssl.3.dylib and libcrypto.3.dylib
sudo install_name_tool -change /usr/local/opt/openssl@3/lib/libssl.3.dylib  @loader_path/../../libssl.3.dylib lib/python3.10/lib-dynload/_ssl.cpython-310-darwin.so
sudo install_name_tool -change /usr/local/opt/openssl@3/lib/libcrypto.3.dylib  @loader_path/../../libcrypto.3.dylib lib/python3.10/lib-dynload/_ssl.cpython-310-darwin.so
otool -l lib/python3.10/lib-dynload/_ssl.cpython-310-darwin.so


ls
echo "install pip";
sudo bin/python3 -m pip install --upgrade pip

#make bin/python alias pointing to python3.7
cd bin
ln -s python$2 python

# pack python
echo "pack python";
cd ../../
# /Users/runner/Desktop/
sudo pkgbuild --identifier macpython.pkg --root "python" --install-location "Applications/MacPython" MacPython.pkg
sudo zip -r MacPython.zip MacPython.pkg
