#!/usr/bin/env bash
# Simple deb
# http://www.sj-vs.net/creating-a-simple-debian-deb-package-based-on-a-directory-structure/#ref3

# More Complete References
# https://jameswestby.net/bzr/builddeb/user_manual/
# http://packaging.ubuntu.com/html/packaging-new-software.html

# Build deb, first arg is deb directory

pushd $(dirname $0)
SCRIPT_DIR=$(pwd)
popd
RDEB_DIR="$HOME/vim_ruby"
PDEB_DIR="$HOME/vim_py2"

build_deb() {
  DEB_DIR="$1"
  cp -r "$SCRIPT_DIR/DEBIAN" "$DEB_DIR"
  # Related to a debian bug?
  #sudo chown -R root:root "$DEB_DIR"
  dpkg-deb --build "$DEB_DIR"
}

# Deb tools
sudo apt-get update -y
sudo apt-get install -y pbuilder ubuntu-dev-tools bzr-builddeb python2.7-dev
hg clone https://code.google.com/p/vim/

# Build ruby vim
pushd vim
./configure --prefix="$RDEB_DIR/usr/local" --with-features=huge --enable-rubyinterp
make && make install
popd
build_deb $RDEB_DIR

# Build python vim
pushd vim
./configure --prefix="$PDEB_DIR/usr/local" --with-features=huge --enable-pythoninterp
make && make install
popd
build_deb $PDEB_DIR

# Git upload debian
git config --global user.email "travis@none.com"
git config --global user.name "travis"
git clone -q $GIT_REPO upload
pushd upload
# Remove older deb version to keep repo size down
git filter-branch --force --prune-empty --index-filter 'git rm --cached --ignore-unmatch *.deb' -- --all
git mv .travis.yml .travis.yml_OFF
cp "${PDEB_DIR}.deb" "${RDEB_DIR}.deb" .
git add .
git commit -m 'Upload latest vim build.'
git push -q -f origin master
popd
