#!/bin/sh

rm -r build/web/*
flutter build web --web-renderer html --release || exit

rsync -rcv build/web/* one@mixin-wallet:/home/one/apps/wallet/web/

ssh one@mixin-wallet sudo service nginx restart

