#!/bin/sh

rm -r build/web/*

sed -i -- "s/BUILD_VERSION/`git rev-parse HEAD`/g" web/index.html || exit
#flutter pub run build_runner build --delete-conflicting-outputs || exit
flutter build web --web-renderer html --release || exit

SUM=`md5 -q build/web/index.html`
mv build/web/index.html build/web/index.$SUM.html

rm -rf ./dist
mkdir dist

mv build/web dist/

cp app.one.yaml dist/app.yaml
sed -i ''  "s/index.html/index.$SUM.html/g" dist/app.yaml || exit
cd dist && gcloud app deploy app.yaml
