#!/bin/sh
cd $(dirname $0)
SCRIPT_DIR=$(pwd)
cd -
RDEB_DIR="$HOME/vim_ruby"
PDEB_DIR="$HOME/vim_py2"

LAST_MSG=$(git log HEAD~1..HEAD --pretty=format:'%s')
if [ "$LAST_MSG" = "Upload latest vim build." ]; then
  exit 0
fi

# Require tools for packaging
sudo apt-get update -y
sudo apt-get install -y ubuntu-dev-tools python2.7-dev
hg clone https://code.google.com/p/vim/

# Build ruby vim
cd vim
./configure --prefix="$RDEB_DIR/usr/local" --with-features=huge --enable-rubyinterp
make && make install
cd -
cp -r "$SCRIPT_DIR/DEBIAN" "$RDEB_DIR"
dpkg-deb --build "$RDEB_DIR"

# Build python vim
cd vim
./configure --prefix="$PDEB_DIR/usr/local" --with-features=huge --enable-pythoninterp
make && make install
cd -
cp -r "$SCRIPT_DIR/DEBIAN" "$PDEB_DIR"
dpkg-deb --build "$PDEB_DIR"

# Git upload debian
git config --global user.email "travis@none.com"
git config --global user.name "travis"
git clone -q $GIT_REPO upload
cd upload

# Remove older deb version to keep repo size down
git filter-branch --force --prune-empty --index-filter 'git rm --cached --ignore-unmatch *.deb' -- --all
cp "${PDEB_DIR}.deb" "${RDEB_DIR}.deb" .
git add .
git commit -m 'Upload latest vim build.'
git push -q -f origin master
