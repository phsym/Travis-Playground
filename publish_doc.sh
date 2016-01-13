#!/bin/sh

CRATE_NAME="$1"
if [ -z $CRATE_NAME ]; then
	echo "Please provide crate name as first argument"
	exit 1
fi

[ $TRAVIS_RUST_VERSION = "stable" ] || exit 0
[ $TRAVIS_PULL_REQUEST = false ] || exit 0
if [ $TRAVIS_BRANCH = master ]; then
	RELEASE="master"
elif [ ! -z $TRAVIS_TAG ]; then
	RELEASE=$TRAVIS_TAG
else
	exit 1
fi

echo "Publishing documentation for $RELEASE"

cargo doc || exit 1
if [ ! -d target/doc/$CRATE_NAME ]; then
	echo "Cannot find target/doc/$CRATE_NAME"
	exit 1
fi

git clone --depth=50 --branch=gh-pages https://github.com/${TRAVIS_REPO_SLUG}.git gh-pages
rm -Rf "gh-pages/${RELEASE}"
mkdir "gh-pages/${RELEASE}"

echo "<meta http-equiv=refresh content=0;url=${CRATE_NAME}/index.html>" > target/doc/index.html 
cp -R target/doc/* "gh-pages/${RELEASE}/"

INDEX="gh-pages/index.html"
echo "<html><head><title>${TRAVIS_REPO_SLUG} API documentation</title></head><body>" > $INDEX
echo "<h1>API documentation for crate $CRATE_NAME (<a href='https://github.com/${TRAVIS_REPO_SLUG}'>${TRAVIS_REPO_SLUG}</a>)</h1>" >> $INDEX
for entry in $(ls -1 gh-pages)
do
	[ -d "gh-pages/$entry" ] && echo "<a href='${entry}'>${entry}</a><br/>" >> $INDEX
done
echo "</body></html>" >> $INDEX

cd gh-pages
git config user.name "travis-ci"
git config user.email "travis@travis-ci.org"

git add --all
git commit -m "Updated documentation"

git push -fq https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git gh-pages || exit 1

