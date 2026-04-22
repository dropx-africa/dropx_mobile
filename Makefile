# Makefile for DropX Customer Mobile

.PHONY: run-dev run-prod build-apk-dev build-apk-prod build-aab-dev build-aab-prod clean get build_runner analyze format fix

all: get

run-dev:
	flutter run --dart-define=FLAVOR=dev

run-prod:
	flutter run --dart-define=FLAVOR=prod

build-apk-dev:
	flutter build apk --dart-define=FLAVOR=dev

build-apk-prod:
	flutter build apk --dart-define=FLAVOR=prod

build-aab-dev:
	flutter build appbundle --dart-define=FLAVOR=dev

build-aab-prod:
	flutter build appbundle --dart-define=FLAVOR=prod

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
