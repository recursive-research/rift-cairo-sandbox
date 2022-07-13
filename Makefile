# Build and test
build :; nile compile
test  :; pytest --disable-warnings tests/
node  :; starknet-devnet --host 127.0.0.1 --port 5000 --seed 12345678
