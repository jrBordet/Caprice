
setup:
	xcodegen
	pod install
	#swiftgen

# Reset the project for a clean build
reset:
	rm -rf *.xcodeproj
	rm -rf *.xcworkspace
	rm -rf Pods/
	rm Podfile.lock

