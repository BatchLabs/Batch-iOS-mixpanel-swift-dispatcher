all: framework

PROJECT=BatchMixpanelSwiftDispatcher.xcodeproj
SIMULATOR='platform=iOS Simulator,name=iPhone 12'
DERIVED_DATA=$(CURDIR)/DerivedData

clean:
	rm -rf $(DERIVED_DATA) $(SONAR_WORKDIR)
	set -o pipefail && xcodebuild clean -project $(PROJECT) -scheme BatchMixpanelSwiftDispatcher | xcpretty

framework: clean
	set -o pipefail && xcodebuild build -project $(PROJECT) -scheme BatchMixpanelSwiftDispatcher -destination generic/platform=iOS | xcpretty

test: clean
	set -o pipefail && xcodebuild test -project $(PROJECT) -scheme BatchMixpanelSwiftDispatcher -destination $(SIMULATOR) | xcpretty

carthage:
	carthage bootstrap --platform ios --use-xcframeworks

ci: carthage test

.PHONY: carthage test
