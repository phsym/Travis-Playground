#!/bin/sh

echo "Rust version : ${TRAVIS_RUST_VERSION}"

[ $TRAVIS_RUST_VERSION != "stable" ] || exit 0
[ $TRAVIS_PULL_REQUEST = false ] || exit 0
if [ $TRAVIS_BRANCH = master ]; then
	RELEASE="master"
elif [ ! -z $TRAVIS_TAG ]; then
	RELEASE=$TRAVIS_TAG
else
	exit 1
fi

cargo doc || exit 1

git clone --depth=50 --branch=gh-pages https://github.com/${TRAVIS_REPO_SLUG}.git gh-pages
rm -Rf "gh-pages/${RELEASE}"
mkdir "gh-pages/${RELEASE}"

echo "<meta http-equiv=refresh content=0;url=test/index.html>" > target/doc/index.html 
cp -R target/doc/* "gh-pages/${RELEASE}/"

echo "<html><head><title>Prettytable-rs API documentation</title></head><body>" > gh-pages/index.html
for entry in $(ls -1 gh-pages)
do
	if [ -d "gh-pages/$entry" ]; then
		echo "<a href='${entry}'>${entry}</a><br/>" >> gh-pages/index.html
	fi
done
echo "</body></html>" >> gh-pages/index.html

cd gh-pages
git config user.name "travis-ci"
git config user.email "travis@travis-ci.org"

git add --all
git commit -m "Updated documentation"

git push -fq https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git gh-pages || exit 1

