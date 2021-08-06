#!/bin/sh

rm -r build/web/*

sed -i '' "s/BUILD_VERSION/`git rev-parse HEAD`/g" web/index.html || exit
#flutter pub run build_runner build --delete-conflicting-outputs || exit
flutter build web --web-renderer html --release || exit

rm -rf ./dist
mkdir dist

cp -r build/web dist/

cp app.one.yaml dist/app.yaml
gcloud app deploy dist/app.yaml

git checkout web/index.html
