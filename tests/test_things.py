"""things.cairo test file."""

from typing import NamedTuple, Tuple

import pytest

from tests.signers import MockSigner
from starkware.starknet.testing.starknet import Starknet, StarknetContract

from tests.utils import (
    contract_path,
    to_uint,
    from_uint,
    from_uint,
    str_to_felt,
    felt_to_str,
    account,
    get_contract_class,
)


# pylint: disable=invalid-name
# pylint: disable=redefined-outer-name

things_cls = get_contract_class("contracts/things.cairo")


@pytest.fixture(scope="module")
async def things_init(signer):
    starknet = await Starknet.empty()
    deployer = await account(starknet, signer)
    user1 = await account(starknet, signer)
    user2 = await account(starknet, signer)
    things = await starknet.deploy(
        contract_class=things_cls,
        constructor_calldata=[deployer.contract_address],
    )
    return things, deployer, user1, user2


class OnChainThing(NamedTuple):
    id: Tuple[int, int]
    name: int


class Thing:
    id: int
    name: str
    onchain: OnChainThing

    def __init__(self, id, name):
        self.id = id
        self.name = name
        self.onchain = OnChainThing(
            # tuples returned as lists in execution info
            id=to_uint(id),
            name=str_to_felt(name),
        )


thing1 = Thing(id=1234, name="The one and only")
thing2 = Thing(id=5678, name="The other one")


async def mint_thing(
    thing: Thing,
    signer: MockSigner,
    things: StarknetContract,
    owner: StarknetContract,
    to: StarknetContract,
):
    return await signer.send_transaction(
        owner,
        things.contract_address,
        "mint",
        [to.contract_address, *thing.onchain.id, thing.onchain.name],
    )


@pytest.mark.asyncio
async def test_mint(signer, things_init):
    things, deployer, user1, user2 = things_init

    await mint_thing(thing1, signer, things, deployer, user1)
    await mint_thing(thing2, signer, things, deployer, user2)

    # check owner
    execution_info = await things.ownerOf(thing1.onchain.id).call()
    assert execution_info.result == (user1.contract_address,)

    execution_info = await things.ownerOf(thing2.onchain.id).call()
    assert execution_info.result == (user2.contract_address,)


@pytest.mark.asyncio
async def test_fight(signer, things_init):
    things, deployer, user1, user2 = things_init

    execution_info = await signer.send_transaction(
        user1,
        things.contract_address,
        "fight",
        [*thing1.onchain.id, *thing2.onchain.id],
    )

    # tuples returned as lists
    assert execution_info.result == (list(thing2.onchain.id),)

    # check owner
    # execution_info = await things.things(thing1.onchain.id).call()
    # assert execution_info.result == (
    #     list(thing1.onchain.id),
    #     to_uint(0), # wins
    #     to_uint(1), # losses
    # )

    # execution_info = await things.ownerOf(thing2.onchain.id).call()
    # assert execution_info.result == (user2.contract_address,)
