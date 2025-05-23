PAK_NAME := $(shell jq -r .label config.json)
PAK_TYPE := $(shell jq -r .pak_type config.json)
PAK_FOLDER := $(shell echo $(PAK_TYPE) | tr '[:lower:]' '[:upper:]' | cut -c1)$(shell echo $(PAK_TYPE) | cut -c2-)s

PUSH_SDCARD_PATH ?= /mnt/SDCARD
PUSH_PLATFORM ?= tg5040

PLATFORMS := tg5040

MINUI_POWER_CONTROL_VERSION := 1.1.0

clean:
	rm -f bin/minui-power-control

build: bin/minui-power-control

bin/minui-power-control:
	mkdir -p bin
	curl -f -o bin/minui-power-control -sSL https://github.com/ben16w/minui-power-control/releases/download/$(MINUI_POWER_CONTROL_VERSION)/minui-power-control
	chmod +x bin/minui-power-control

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist

push: release
	rm -rf "dist/$(PAK_NAME).pak"
	cd dist && unzip "$(PAK_NAME).pak.zip" -d "$(PAK_NAME).pak"
	adb push "dist/$(PAK_NAME).pak/." "$(PUSH_SDCARD_PATH)/$(PAK_FOLDER)/$(PUSH_PLATFORM)/$(PAK_NAME).pak"
