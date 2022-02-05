
SWIFT_BUILD_FLAGS=-c release -Xswiftc -static-stdlib

build:
	swift build $(SWIFT_BUILD_FLAGS)

release: build
	cp .build/release/StyleValidator .