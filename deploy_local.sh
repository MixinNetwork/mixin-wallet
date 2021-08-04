#!/bin/sh

rm -r build/*
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web
python3 -m http.server 8001 --directory build/web
