#!/bin/sh

rm -r build/web/*
flutter build web || exit

rsync -rcv build/web/* one@mixin-wallet:/home/one/apps/wallet/web/

