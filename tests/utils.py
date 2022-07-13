"""Utilities for testing Cairo contracts."""
import os
from pathlib import Path
import math
import openzeppelin
from starkware.starknet.public.abi import get_selector_from_name
from starkware.starknet.compiler.compile import compile_starknet_files
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.testing.starknet import StarknetContract
from starkware.starknet.business_logic.execution.objects import Event

MAX_UINT256 = (2**128 - 1, 2**128 - 1)
INVALID_UINT256 = (MAX_UINT256[0] + 1, MAX_UINT256[1])
ZERO_ADDRESS = 0
TRUE = 1
FALSE = 0

TRANSACTION_VERSION = 0

BYTE_MASK = 0xff


_root = Path(__file__).parent.parent


def contract_path(name):
    if name.startswith("openzeppelin/"):
        return os.path.join(
            os.path.dirname(openzeppelin.__file__),
            name.replace("openzeppelin/", ""),
        )

    return str(_root / name)

def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")


def felt_to_str(felt):
    b_felt = felt.to_bytes(31, "big")
    return b_felt.decode()


def uint(a):
    return(a, 0)


def to_uint(a):
    """Takes in value, returns uint256-ish tuple."""
    return (a & ((1 << 128) - 1), a >> 128)


def from_uint(uint):
    """Takes in uint256-ish tuple, returns value."""
    return uint[0] + (uint[1] << 128)


def add_uint(a, b):
    """Returns the sum of two uint256-ish tuples."""
    a = from_uint(a)
    b = from_uint(b)
    c = a + b
    return to_uint(c)


def sub_uint(a, b):
    """Returns the difference of two uint256-ish tuples."""
    a = from_uint(a)
    b = from_uint(b)
    c = a - b
    return to_uint(c)


def mul_uint(a, b):
    """Returns the product of two uint256-ish tuples."""
    a = from_uint(a)
    b = from_uint(b)
    c = a * b
    return to_uint(c)


def div_rem_uint(a, b):
    """Returns the quotient and remainder of two uint256-ish tuples."""
    a = from_uint(a)
    b = from_uint(b)
    c = math.trunc(a / b)
    m = a % b
    return (to_uint(c), to_uint(m))


async def assert_revert(fun, reverted_with=None):
    try:
        await fun
        assert False
    except StarkException as err:
        _, error = err.args
        if reverted_with is not None:
            assert reverted_with in error['message']


async def assert_revert_entry_point(fun, invalid_selector):
    selector_hex = hex(get_selector_from_name(invalid_selector))
    entry_point_msg = f"Entry point {selector_hex} not found in contract"

    await assert_revert(fun, entry_point_msg)


def assert_event_emitted(tx_exec_info, from_address, name, data):
    assert Event(
        from_address=from_address,
        keys=[get_selector_from_name(name)],
        data=data,
    ) in tx_exec_info.raw_events


def get_contract_class(path):
    """Return the contract class from the contract path"""
    path = contract_path(path)
    contract_class = compile_starknet_files(
        files=[path],
        debug_info=True
    )
    return contract_class


def cached_contract(state, _class, deployed):
    """Return the cached contract"""
    contract = StarknetContract(
        state=state,
        abi=_class.abi,
        contract_address=deployed.contract_address,
        deploy_execution_info=deployed.deploy_execution_info
    )
    return contract

async def account(starknet, signer):
    account_cls = get_contract_class("openzeppelin/account/Account.cairo")
    return await starknet.deploy(
        contract_class=account_cls, constructor_calldata=[signer.public_key]
    )

def string_to_int(string: str) -> int:
    return sum([ord(string[i]) << 8*(len(string) - (i+1)) for i in range(len(string))])


def int_to_string(val: int) -> str:
    offset = 0
    out = ''
    while True:
        if (val >> 8*offset) <= 0:
            return out
        chr_ord = (val >> 8*offset) & BYTE_MASK
        out = chr(chr_ord) + out
        offset += 1

