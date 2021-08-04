#!/bin/sh

rm -r build/web/*
sed -i -- "s/BUILD_VERSION/`git rev-parse HEAD`/g" web/index.html || exit
#flutter pub run build_runner build --delete-conflicting-outputs || exit
flutter build web --web-renderer html --release || exit

ssh one@mixin-wallet cp -r /home/one/apps/wallet/web /home/one/apps/wallet/web_old

rsync -rcv build/web/* one@mixin-wallet:/home/one/apps/wallet/web/

ssh one@mixin-wallet sudo service nginx restart

