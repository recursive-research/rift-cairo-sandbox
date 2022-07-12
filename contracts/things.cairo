%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from contracts.access.ownable import Ownable
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le, sign
from starkware.cairo.common.hash import hash2

struct Position:
    member x : felt
    member y : felt
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    league_ : felt, owner_ : felt
):
    Ownable.initializer(owner_)
    league.write(league_)
    return ()
end

@view
func leagueSize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    leagueSize : felt
):
    let (leagueSize) = league_size.read()

    return (leagueSize)
end

@view
func owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (owner : felt):
    let (owner : felt) = Ownable.owner()
    return (owner)
end

func _processWin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(thingId : felt):
    let (playerWins : felt) = wins.read(thingId)
    wins.write(thingId, playerWins + 1)

    return ()
end

func _processLoss{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    thingId : felt
):
    let (playerLosses : felt) = losses.read(thingId)
    wins.write(thingId, playerLosses + 1)

    return ()
end

@external
func battle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player : felt, opponent : felt
) -> (battlle : felt):
    alloc_locals

    _assertOwnerOf(player)

    let (player_stuff : felt) = stuff.read(player)
    let (opponent_stuff : felt) = stuff.read(opponent)
    let (player_won : felt) = sign(player_stuff - opponent_stuff)

    if player_won == 1:
        _processWin(player)
        _processLoss(opponent)
        let battle = 'you won'
        return (battle)
    else:
        _processLoss(player)
        _processWin(opponent)
        let battle = 'you lost'
        return (battle)
    end
end

@external
func mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt) -> (
    thingId : felt
):
    alloc_locals
    let (caller : felt) = get_caller_address()
    let (sizeLeague : felt) = league_size.read()
    let (thingId : felt) = _thingId{hash_ptr=pedersen_ptr}(name, caller)
    league_size.write(sizeLeague + 1)
    return (thingId)
end

func _thingId{
    syscall_ptr : felt*, hash_ptr : HashBuiltin*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(name : felt, addr : felt) -> (_thingId : felt):
    let (numThings : felt) = league_size.read()
    let (_thingId : felt) = hash2(name * numThings, addr / numThings)
    return (_thingId)
end

func _initializeThing(thingId : felt):
    # names
    # wins
    # losses

    return ()
end

func _assertOwnerOf{syscall_ptr : felt*}(owner : felt):
    let (caller : felt) = get_caller_address()

    if caller != owner:
        owner = owner + 1
    end
    return ()
end

@storage_var
func stuff(thingId : felt) -> (stuff : felt):
end

func _stuff{
    syscall_ptr : felt*, hash_ptr : HashBuiltin*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(thingId : felt) -> (_stuff : felt):
    let (_name : felt) = names.read(thingId)
    let (_stuff) = hash2(_name, thingId)

    return (_stuff)
end

@storage_var
func names(thingId : felt) -> (name : felt):
end

@storage_var
func wins(thingId : felt) -> (wins : felt):
end

@storage_var
func losses(thingId : felt) -> (wins : felt):
end

@storage_var
func level(thingId : felt) -> (wins : felt):
end

@storage_var
func league() -> (league : felt):
end

@storage_var
func league_size() -> (league_size : felt):
end
