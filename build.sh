set -e

echo "pythonVersion: $1";
echo "pythonMajorVersion: $2";


# download python source, compile
echo "Download Python";
curl -O  https://www.python.org/ftp/python/$1/Python-$1.tgz
tar -zxvf Python-$1.tgz
cd Python-$1

./configure --prefix=/Users/runner/Desktop/python --enable-optimizations
sudo make -j8
sudo make install -j8


cd /Users/runner/Desktop/python/


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
sudo zip -r python_osx.zip MacPython.pkg

