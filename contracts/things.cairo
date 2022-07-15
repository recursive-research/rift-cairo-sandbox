%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from openzeppelin.access.ownable import Ownable
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le, assert_not_equal, sign, assert_not_zero
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bitwise import bitwise_and, BitwiseBuiltin

struct thing:
    member thingId : felt
    member name : felt
    member wins : felt
    member losses : felt
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

func _processWin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt
) -> (updated : thing):
    alloc_locals
    let (player : thing) = things.read(owner)
    let updated = thing(player.name, player.thingId, player.wins, player.losses + 1)
    things.write(owner, updated)
    return (updated)
end

func _processLoss{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt
) -> (updated : thing):
    alloc_locals
    let (player : thing) = things.read(owner)
    let updated = thing(player.name, player.thingId, player.wins, player.losses + 1)
    things.write(owner, updated)
    return (updated)
end

@external
func fight{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(opponentId : felt) -> (fight : felt):
    alloc_locals
    # get the caller thing
    let (caller : felt) = get_caller_address()
    let (player : thing) = things.read(caller)

    # assert we got a valid thing
    assert_not_zero(player.thingId)

    let (opponent : thing) = _thingFromThingId(opponentId)
    assert_not_zero(opponent.thingId)

    let (opponentOwnerId : felt) = owners.read(opponentId)
    assert_not_zero(opponentOwnerId)

    let (player_stuff : felt) = _stuff{bitwise_ptr=bitwise_ptr}(player)
    let (opponent_stuff : felt) = _stuff{bitwise_ptr=bitwise_ptr}(opponent)
    let (player_won : felt) = sign(player_stuff - opponent_stuff)

    if player_won == 1:
        _processWin(caller)
        _processLoss(opponentOwnerId)
        Fight.emit(caller, opponentOwnerId)
        let fight = 'you won'
        return (fight)
    else:
        _processLoss(caller)
        _processWin(opponentOwnerId)
        Fight.emit(caller, opponentOwnerId)
        let fight = 'you lost'
        return (fight)
    end
end

func _stuff{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(player : thing) -> (_stuff : felt):
    alloc_locals

    let (numThings) = league_size.read()
    let prod = player.thingId * (numThings + 123)

    let (_intermediate : felt) = hash2{hash_ptr=pedersen_ptr}(prod, numThings)
    let (_stuff : felt) = bitwise_and(_intermediate, 0xfffffffffffffffff)
    return (_stuff)
end

@external
func mint{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(to : felt, name : felt) -> (thingId : felt):
    alloc_locals

    # get caller address
    let (sizeLeague : felt) = league_size.read()

    # calc thingId
    let (thingId : felt) = _thingId(name, to)
    assert_not_zero(name)
    assert_not_zero(thingId)

    # create player
    let player = thing(thingId, name, 0, 0)

    # write player
    things.write(to, player)
    owners.write(thingId, to)

    league_size.write(sizeLeague + 1)

    Mint.emit(to, thingId)

    return (thingId)
end

func _thingFromThingId{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(thingId : felt) -> (_thing : thing):
    let (owner : felt) = owners.read(thingId)
    assert_not_zero(owner)
    let (_thing : thing) = things.read(owner)
    assert_not_zero(_thing.thingId)
    return (_thing)
end

@view
func thingOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt) -> (t : thing):
    let (t : thing) = things.read(owner)
    return (t)
end

func _thingId{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr
}(name : felt, addr : felt) -> (_thingId : felt):
    let intermediate = addr / name
    let intermediate1 = intermediate / addr
    let (thingNum : felt) = league_size.read()
    let (intermediate2 : felt) = hash2{hash_ptr=pedersen_ptr}(intermediate1, intermediate)
    let (thingId : felt) = bitwise_and(intermediate2, 0xfffffffffffffffffffffffffffff)
    return (thingId)
end

@storage_var
func things(owner : felt) -> (things : thing):
end

@storage_var
func league() -> (league : felt):
end

@storage_var
func league_size() -> (league_size : felt):
end

@storage_var
func owners(thingId : felt) -> (owners : felt):
end

@event
func Fight(winner : felt, loser : felt):
end

@event
func Mint(owner : felt, thingId : felt):
end
