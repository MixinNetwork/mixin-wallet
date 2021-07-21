#!/bin/sh

rm -r build/*
flutter build web
python3 -m http.server 8001 --directory build/web