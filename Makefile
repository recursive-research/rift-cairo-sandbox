# Build and test
build :; nile compile
test  :; pytest tests/
node :; starknet-devnet --seed 123