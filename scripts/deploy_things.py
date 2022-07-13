from nile.nre import NileRuntimeEnvironment
from nile.signer import Signer


def only_localhost(func):
    def wrapper(nre: NileRuntimeEnvironment):
        if nre.network != "127.0.0.1":
            raise ValueError(
                "This script can only be run on network=127.0.0.1"
            )
        return func(nre)

    return wrapper


@only_localhost
def run(nre: NileRuntimeEnvironment):

    # signer = "DEV_PRIVATE_KEY"
    signer = "ACCOUNT0_PRIVATE_KEY"

    account = nre.get_or_deploy_account(signer)
    address, abi = nre.deploy(
        "things", alias="things", arguments=[account.address]
    )
    print("Account")
    print("Adddress:", account.address)
    print("Public Key", hex(account.signer.public_key))
    print("Private Key", hex(account.signer.private_key))
    print("--------------")
    print("Things address:", address)
