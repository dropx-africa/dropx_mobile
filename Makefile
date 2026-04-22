# Makefile for DropX Customer Mobile

.PHONY: run-dev run-prod build-apk-dev build-apk-prod build-aab-dev build-aab-prod clean get build_runner analyze format fix

all: get

DEV_DEFINES = \
	--dart-define=BACKEND_BASE_URL=https://api-production-dcbb.up.railway.app \
	--dart-define=CLOUDINARY_CLOUD_NAME=dxcyytvmm \
	--dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_unsigned_upload \
	--dart-define=GOOGLE_MAPS_API_KEY=AIzaSyBW0zgD8_dIPtv9u2UWYM8vWgaIeIMM-Jk

PROD_DEFINES = \
	--dart-define=BACKEND_BASE_URL=https://api-production-dcbb.up.railway.app \
	--dart-define=CLOUDINARY_CLOUD_NAME=dxcyytvmm \
	--dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_unsigned_upload \
	--dart-define=GOOGLE_MAPS_API_KEY=AIzaSyBW0zgD8_dIPtv9u2UWYM8vWgaIeIMM-Jk

run-dev:
	flutter run $(DEV_DEFINES)

run-prod:
	flutter run $(PROD_DEFINES)

build-apk-dev:
	flutter build apk $(DEV_DEFINES)

build-apk-prod:
	flutter build apk $(PROD_DEFINES)

build-aab-dev:
	flutter build appbundle $(DEV_DEFINES)

build-aab-prod:
	flutter build appbundle $(PROD_DEFINES)

clean:
	flutter clean

get:
	flutter pub get

build_runner:
	dart run build_runner build --delete-conflicting-outputs

analyze:
	flutter analyze

format:
	dart format .

fix:
	dart fix --apply
