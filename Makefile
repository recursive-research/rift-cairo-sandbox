# Build and test
build :; nile compile
test  :; pytest tests/
node :; starknet-devnet --port 5000 --seed 123
