.PHONY: build run clean project archive

SCHEME := ClipboardSticky
PROJECT := ClipboardSticky.xcodeproj
DERIVED_DATA := $(shell find ~/Library/Developer/Xcode/DerivedData -maxdepth 1 -name "ClipboardSticky-*" -type d 2>/dev/null | head -1)
APP := $(DERIVED_DATA)/Build/Products/Debug/ClipboardSticky.app

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug build

run: build
	@# Find the built app
	@APP_PATH=$$(find ~/Library/Developer/Xcode/DerivedData -maxdepth 5 -name "ClipboardSticky.app" -path "*/Debug/*" 2>/dev/null | head -1); \
	if [ -n "$$APP_PATH" ]; then \
		echo "🚀 Launching $$APP_PATH"; \
		open "$$APP_PATH"; \
	else \
		echo "❌ Could not find built .app"; \
		exit 1; \
	fi

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
	rm -rf ~/Library/Developer/Xcode/DerivedData/ClipboardSticky-*

project:
	xcodegen generate --spec project.yml

archive:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release archive \
		-archivePath ./build/ClipboardSticky.xcarchive

release: archive
	@echo "Archive created at ./build/ClipboardSticky.xcarchive"
	@echo "To export: open Xcode -> Organizer -> Archives"
