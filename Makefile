# Build and test
build :; nile compile
test  :; pytest --disable-warnings tests/
