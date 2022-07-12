"""Test fixtures"""

import asyncio
import pytest

from tests.signers import MockSigner

# pylint: disable=invalid-name
# pylint: disable=redefined-outer-name


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
def signer():
    return MockSigner(123456789987654321)
