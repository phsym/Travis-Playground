#!/bin/sh

echo "Rust version : ${TRAVIS_RUST_VERSION}"

[ $TRAVIS_PULL_REQUEST = false ] || exit 0
[ $TRAVIS_BRANCH = master ] || exit 0

RELEASE="master"

[ -z $TRAVIS_TAG ] || RELEASE=$TRAVIS_TAG

cargo doc || exit 1

# git branch -a
# git fetch -a https://github.com/phsym/Travis-Playground.git
# git checkout gh-pages
git clone --depth=50 --branch=gh-pages https://github.com/${TRAVIS_REPO_SLUG}.git gh-pages
rm -Rf "gh-pages/${RELEASE}"
mkdir "gh-pages/${RELEASE}"

echo "<meta http-equiv=refresh content=0;url=test/index.html" > target/doc/index.html 
cp -R target/doc/* "gh-pages/${RELEASE}/"

cd gh-pages
git config user.name "travis"
git config user.email "none@travis-ci.org"

git add --all
git commit -m "Updated documentation"

git push -fq https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git gh-pages || exit 1

