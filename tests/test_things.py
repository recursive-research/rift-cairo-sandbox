"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet, StarknetContract
from signers import MockSigner
from utils import get_contract_class, account, int_to_string, string_to_int

# pylint: disable=invalid-name

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "things.cairo")

THINGS_CLS = get_contract_class(CONTRACT_FILE)

LEAGUE = 0xFF
OWNER = 0x0F
MSG_LOST = "you lost"
MSG_WON = "you won"


async def mint_thing(
    signer: MockSigner,
    contract: StarknetContract,
    sender: StarknetContract,
    name: str,
):
    return await signer.send_transaction(
        sender,
        contract.contract_address,
        "mint",
        [sender.contract_address, string_to_int(name)],
    )


async def fight_thing(
    signer: MockSigner,
    contract: StarknetContract,
    sender: StarknetContract,
    opponent: int,
):
    return await signer.send_transaction(
        sender, contract.contract_address, "fight", calldata=[opponent]
    )


async def thingOf(
    signer: MockSigner,
    contract: StarknetContract,
    sender: StarknetContract,
):
    return await signer.send_transaction(
        sender,
        contract.contract_address,
        "thingOf",
        calldata=[sender.contract_address],
    )


async def deploy_thing(sn: Starknet):
    return await sn.deploy(
        source=CONTRACT_FILE, constructor_calldata=[LEAGUE, OWNER]
    )


@pytest.mark.asyncio
async def test_owner():
    """Test owner method."""

    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await deploy_thing(starknet)

    data = await contract.owner().call()
    assert data.result.owner == OWNER


@pytest.mark.asyncio
async def test_mint():
    """Test mint method."""

    starknet = await Starknet.empty()
    contract = await deploy_thing(starknet)

    THING_1 = "thing1"
    signer = MockSigner(string_to_int(THING_1))
    account1 = await account(starknet, signer)

    result = await mint_thing(
        signer,
        contract,
        account1,
        THING_1,
    )


@pytest.mark.asyncio
async def test_thing_of():
    """Test me method."""

    starknet = await Starknet.empty()

    contract = await deploy_thing(starknet)

    THING_1 = "thing1"

    signer1 = MockSigner(string_to_int(THING_1))

    account1 = await account(starknet, signer1)
    mintResult1 = await mint_thing(signer1, contract, account1, THING_1)

    result = await thingOf(signer1, contract, account1)

    assert mintResult1.result.response[0] == result.result.response[0]


@pytest.mark.asyncio
async def test_fight():
    """Test fight method."""

    starknet = await Starknet.empty()

    contract = await deploy_thing(starknet)

    THING_1 = "thing1"
    THING_2 = "thing2"

    signer1 = MockSigner(string_to_int(THING_1))
    signer2 = MockSigner(string_to_int(THING_2))

    account1 = await account(starknet, signer1)
    account2 = await account(starknet, signer2)
    mintResult1 = await mint_thing(signer1, contract, account1, THING_1)

    mintResult2 = await mint_thing(signer2, contract, account2, THING_2)

    fightResult1 = await fight_thing(
        signer1, contract, account1, mintResult2.result.response[0]
    )

    fightResult2 = await fight_thing(
        signer2, contract, account2, mintResult1.result.response[0]
    )

    fightResult1Str = int_to_string(fightResult1.result.response[0])
    fightResult2Str = int_to_string(fightResult2.result.response[0])

    assert sorted([MSG_LOST, MSG_WON]) == sorted(
        [fightResult1Str, fightResult2Str]
    )
