#!/bin/sh

rm -r build/web/*
sed -i -- "s/BUILD_VERSION/`git rev-parse HEAD`/g" web/index.html || exit
flutter pub run build_runner build || exit
flutter build web --web-renderer html --release || exit

rsync -rcv build/web/* one@mixin-wallet:/home/one/apps/wallet/web/

ssh one@mixin-wallet sudo service nginx restart

