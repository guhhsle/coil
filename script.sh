#!/usr/bin/env bash

packages=("just_audio: ^0.9.34" "simple_audio: ^1.6.2")

line=$(grep -n "audio-packages" pubspec.yaml | awk -F  ":" '{print $1}')
i=$line

for pack in "${packages[@]}"
do
	((i++))
	sed -i "${i}s/.*/  #${pack}/" pubspec.yaml
done

if [ $2 = "l" ]; then
	((line+=2))
	sed -i "${line}s/.*/  ${packages[1]}/" pubspec.yaml

	cp lib/services/audio_linux.dart lib/services/audio.dart
	len=$(wc -l < lib/services/audio.dart)
	sed -i "1s/.*/\/\//" lib/services/audio.dart
	sed -i "${len}s/.*/\/\//" lib/services/audio.dart

	flutter build linux --release

elif [ $2 = "a" ]; then
	((line+=1))
	sed -i "${line}s/.*/  ${packages[0]}/" pubspec.yaml

	cp lib/services/audio_android.dart lib/services/audio.dart
	len=$(wc -l < lib/services/audio.dart)
	sed -i "1s/.*/\/\//" lib/services/audio.dart
	sed -i "${len}s/.*/\/\//" lib/services/audio.dart

	flutter build apk --split-per-abi
	cd build/app/outputs/flutter-apk/
	mv app-arm64-v8a-release.apk $1.apk
	#nohup nohup firefox eu1.storj.io/login & 
	nohup nohup nautilus ./ &

else 
	echo "Nema"
fi

echo "Done"
exit 0
