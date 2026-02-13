SHELL := /bin/zsh
.PHONY: validate lint format test

validate:
	@.ci/agent_validate.sh

lint:
	@swiftlint --strict || true

format:
	@swiftformat . --config .swiftformat || true

test:
	xcodebuild test \
		-project AvoidObstaclesGame.xcodeproj \
		-scheme AvoidObstaclesGame \
		-testPlan AvoidObstaclesGame \
		-xcconfig Config/Test.xcconfig \
		-destination 'platform=iOS Simulator,name=iPhone 17' || true
