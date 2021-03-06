set -e


# download ssl source, compile
curl -O  https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar -zxvf openssl-1.1.1g.tar.gz
cd openssl-1.1.1g
./config --prefix=/Users/runner/Desktop/pythonssl    # prefix : where to install
sudo make -j8
sudo make install -j8


# download python source, compile
cd ../
curl -O  https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz
tar -zxvf Python-3.8.3.tgz
cd Python-3.8.3

# copy Setup to Modules
cp ../Setup ./Modules

./configure --prefix=/Users/runner/Desktop/python --enable-optimizations
sudo make -j8
sudo make install -j8

# copy libssl.1.1.dylib and libcrypto.1.1.dylib to python/lib
sudo cp /Users/runner/Desktop/pythonssl/lib/lib* /Users/runner/Desktop/python/lib/



cd /Users/runner/Desktop/python/


# check links in python
otool -l bin/python3
#Fix python's link
sudo install_name_tool -change /Users/runner/Desktop/pythonssl/lib/libssl.1.1.dylib  @loader_path/../lib/libssl.1.1.dylib bin/python3 
sudo install_name_tool -change /Users/runner/Desktop/pythonssl/lib/libcrypto.1.1.dylib  @loader_path/../lib/libcrypto.1.1.dylib bin/python3 
otool -l bin/python3

#fix ssl lib's lik
otool -l lib/libssl.1.1.dylib
sudo install_name_tool -change /Users/runner/Desktop/pythonssl/lib/libssl.1.1.dylib  @loader_path/../lib/libssl.1.1.dylib lib/libssl.1.1.dylib
sudo install_name_tool -change /Users/runner/Desktop/pythonssl/lib/libcrypto.1.1.dylib  @loader_path/../lib/libcrypto.1.1.dylib lib/libssl.1.1.dylib


# otool -l lib/libcrypto.1.1.dylib
# install_name_tool -change /Users/runner/Desktop/pythonssl/lib/libcrypto.1.1.dylib  @loader_path/../lib/libcrypto.1.1.dylib lib/libcrypto.1.1.dylib
ls

sudo bin/python3 -m pip install --upgrade pip

#make bin/python alias pointing to python3.8
cd bin
ln -s python3.8 python

# pack python
cd ../../
# /Users/runner/Desktop/
sudo pkgbuild --identifier macpython.pkg --root "python" --install-location "Applications/MacPython" MacPython.pkg
sudo zip -r python_osx.zip MacPython.pkg

