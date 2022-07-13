# installation

installation is a bit weird. they suggest you install in a global venv. I suggest we install in a local venv (and rather than install directly, install via nile)

https://github.com/OpenZeppelin/nile


also we should use poetry

`
python3 -m venv .venv
source .venv/bin/activate
poetry add cairo-nile
nile init
`

## StarkNet

use starknet cli to intface with chainn (`--network=`, or `STAKNET_NETWORK=`)

StarkNet does not distinguish between EOAs and contracts. an account is represented by a deployed contract that defines the accounts logic - mode notabley, the signature scheme that controls who can issue transactions from it

to interact with starknet, you need to deploy an account contract

```
export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
```


also, we can't used metamask directly, though can use MetaMask Flask + the StarkNet Snap

https://consensys.net/blog/metamask/metamask-integrates-starkware-into-first-of-its-kind-zk-rollup-snap/


## Witing Contracts

`%lang starknet`
use `starknet-compile`, not `cairo-compile`


- cairo programs are stateless, starknet contracts are not


# Define a storage variable.
```
@storage_var
func balance() -> (res : felt):
end

// created by decorator
balance.read()
balance.write()
```

StarkNet contracts have no `main`.

`@view` is identical to `@external`, except it is annotated as a method that only queries state rather than modifying it (though this is not enforced atm)


why implicit args?
```
# Increases the balance by the given amount.
@external
func increase_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(amount : felt):
    let (res) = balance.read()
    balance.write(res + amount)
    return ()
end
```
`pedersen_ptr` - allows you to compute Pedersen hash function
`range_check_ptr` - allows you to compair integers

needed because staged variables require these implicit args (to make them available within scope, presumably). to do things like `.read` and `.write`

`syscall_ptr` -  new primitive unique to StarkNet contracts (doens't exisit in base cairo). allows code to invoke system calls. also needed for `.read` and `.write` (which use system calls)

you can inline python in cairo:

```
[ap] = 25; ap++
%{
    import math
    memory[ap] = int(math.sqrt(memory[ap - 1]))
%}
[ap - 1] = [ap] * [ap]; ap++
```

this is a "hint", executed by the prover right before next instruction

you can not use hints in StarkNet contracts.

> This is due to the fact that the contract’s author, the user invoking the function and the operator running it are likely to be different entities:

> The operator cannot run arbitrary python code due to security concerns.

> The user won’t be able to verify that the operator ran the hint the contract author supplied.

> It is not possible to prove that nondeterministic code failed, since you should either prove you executed the hint or prove that for any hint the code would’ve failed.

unlike ethereum, stark net distinguishes between a contract class and a contract instance.

class: code of the contract (no state)
instance: with state

so you need to "declare" contract class: deploy the code
then you can create instances from it

```
starknet declare --contract contract_compiled.json
starknet deploy --contract contract_compiled.json
```

you need to save contract address ( from deploy ) to interact with contract

```
# The deployment address of the previous contract.
export CONTRACT_ADDRESS="<address of the previous contract>"
```

```
starknet invoke \
    --address ${CONTRACT_ADDRESS} \
    --abi contract_abi.json \
    --function increase_balance \
    --inputs 1234
```

* due to use of fees in starknet, every interaction with a contract througha function invocation must be done using an account (a contract)

## User Auth



mapping is still a function
```
# A map from user (represented by account contract address)
# to their balance.
@storage_var
func balance(user : felt) -> (res : felt):
end
```

use syscalls for caller address

```
from starkware.starknet.common.syscalls import get_caller_address

let (caller_address) = get_caller_address()

```



## Randomg

struct:

```
struct User:
    member first_name : felt
    member last_name : felt
end
```

arrays:

two consecutive args (len, ptr)

```
@external
func compare_arrays(
    a_len : felt, a : felt*, b_len : felt, b : felt*
):
    assert a_len = b_len
    if a_len == 0:
        return ()
    end
    assert a[0] = b[0]
    return compare_arrays(
        a_len=a_len - 1, a=&a[1], b_len=b_len - 1, b=&b[1]
    )
end
```



block number + timestamp: both require implict arg `srscall_ptr`
block timestamp is the time at the beginning of the block creation, which can differ significatnly from the time the block is accepted on l1
```
from starkware.starknet.common.syscalls import (
    get_block_number,
    get_block_timestamp,
)

let (block_number) = get_block_number()
let (block_timestamp) = get_block_timestamp()
```

- contstructo



good notes on extensibility: https://github.com/OpenZeppelin/cairo-contracts/blob/main/docs/Extensibility.md


> Using imports for modularity can result in clashes (more so given that arguments are not part of the selector), and lack of overrides or aliasing leaves no way to resolve them

> Any @external function defined in an imported module will be automatically re-exposed by the importer (i.e. the smart contract)


pattern:

libaries: resuable logic / stoage variables which can then be extedend and expose by contracts
contracts and be deployed, libraries cannot

```
internal: internal to a library, not meant to be used outside the module or imported
public: part of the public API of a library
external: subset of public that is ready to be exported as-is by contracts
storage: storage variable functions
```

# variables

any function that uses local variabhles must use alloc_locals
let syntax defines a `reference` (a ptr location)

## Questions

- can you update state of L1 on L2?
