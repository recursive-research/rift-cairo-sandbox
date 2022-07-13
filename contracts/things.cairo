%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from contracts.access.ownable import Ownable
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le, sign
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bitwise import bitwise_and, BitwiseBuiltin

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
func fight{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
    player : felt, opponent : felt
) -> (battlle : felt):
    alloc_locals

    _assertOwnerOf(player)

    let (player_stuff : felt) = _stuff{bitwise_ptr=bitwise_ptr}(player)
    let (opponent_stuff : felt) = _stuff(opponent)
    let (player_won : felt) = sign(player_stuff - opponent_stuff)

    if player_won == 1:
        _processWin(player)
        _processLoss(opponent)
        Fight.emit(player, opponent)
        let fight = 'you won'
        return (fight)
    else:
        _processLoss(player)
        _processWin(opponent)
        let fight = 'you lost'
        Fight.emit(opponent, player)
        return (fight)
    end
end

func _stuff{syscall_ptr: felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(thingId: felt) -> (_stuff: felt):
    alloc_locals
    let (numThings) = league_size.read()
    let prod = thingId * numThings
    let (_stuff: felt) = bitwise_and(prod, 0xffffffffffffffffffffffffffffffff)
    
    return (_stuff)

end

@external
func mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt) -> (
    thingId : felt
):
    alloc_locals
    let (caller : felt) = get_caller_address()
    let (sizeLeague : felt) = league_size.read()
    let (thingId : felt) = _thingId(name, caller)
    league_size.write(sizeLeague + 1)
    owners.write(thingId, caller)

    Mint.emit(caller, thingId)

    return (thingId)
end

func _thingId{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt, addr : felt
) -> (_thingId : felt):
    pedersen_ptr.x = name
    pedersen_ptr.y = addr
    let _thingId = pedersen_ptr.result
    let pedersen_ptr = pedersen_ptr + HashBuiltin.SIZE

    return (_thingId)
end

func _assertOwnerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    thingId : felt
):
    let (owner : felt) = owners.read(thingId)
    let (caller : felt) = get_caller_address()

    if caller != owner:
        owner = owner + 1
    end
    return ()
end


@storage_var
func owners(thingId : felt) -> (owner : felt):
end

@storage_var
func names(thingId : felt) -> (name : felt):
end

@storage_var
func wins(thingId : felt) -> (wins : felt):
end

@storage_var
func losses(thingId : felt) -> (losses : felt):
end

@storage_var
func league() -> (league : felt):
end

@storage_var
func league_size() -> (league_size : felt):
end

@event
func Fight(winner : felt, loser : felt):
end

@event
func Mint(owner : felt, thingId : felt):
end
