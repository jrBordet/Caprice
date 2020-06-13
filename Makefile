
setup:
	xcodegen
	pod install
	#swiftgen

# Reset the project for a clean build
reset:
	rm -rf XcodegenApp.xcodeproj
	rm -rf XcodegenApp.xcworkspace
	rm -rf Pods/
	rm Podfile.lock

