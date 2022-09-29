%lang starknet
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.bool import TRUE, FALSE

from contracts.settling_game.utils.game_structs import RealmData

const FAKE_OWNER_ADDR = 20;
const MODULE_CONTROLLER_ADDR = 120325194214501;

@contract_interface
namespace Realms {
    func initializer(name: felt, symbol: felt, proxy_admin: felt) {
    }

    func mint(to: felt, tokenId: Uint256) {
    }

    func approve(to: felt, tokenId: Uint256) {
    }

    func set_realm_data(tokenId: Uint256, _realm_data: felt) {
    }
}

@contract_interface
namespace Relics {
    func initializer(address_of_controller: felt, proxy_admin: felt) {
    }

    func set_relic_holder(winner_token_id: Uint256, loser_token_id: Uint256) {
    }

    func return_relics(realm_token_id: Uint256) {
    }

    func get_current_relic_holder(relic_id: Uint256) -> (token_id: Uint256) {
    }
}

@contract_interface
namespace Settling {
    func initializer(address_of_controller: felt, proxy_admin: felt) {
    }

    func settle(token_id: Uint256) -> (success: felt) {
    }
}

@external
func __setup__{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;

    %{
        import os, sys
        sys.path.append(os.path.abspath(os.path.dirname(".")))
    %}

    local Relics_address;
    local Realms_token_address;
    local S_Realms_token_address;
    local Settling_address;
    local Module_controller_address;
    %{
        context.Relics_address = deploy_contract("./contracts/settling_game/modules/relics/Relics.cairo", []).contract_address
        ids.Relics_address = context.Relics_address
        context.Realms_token_address = deploy_contract("./contracts/settling_game/tokens/Realms_ERC721_Mintable.cairo", []).contract_address
        ids.Realms_token_address = context.Realms_token_address
        context.S_Realms_token_address = deploy_contract("./contracts/settling_game/tokens/S_Realms_ERC721_Mintable.cairo", []).contract_address
        ids.S_Realms_token_address = context.S_Realms_token_address
        context.Settling_address = deploy_contract("./contracts/settling_game/modules/settling/Settling.cairo", []).contract_address
        ids.Settling_address = context.Settling_address
    %}
    Relics.initializer(Relics_address, MODULE_CONTROLLER_ADDR, 1);
    Realms.initializer(Realms_token_address, 1, 1, 1);

    return ();
}

@external
func test_set_relic_holder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() {
    alloc_locals;

    local Relics_address;
    local Realms_token_address;
    local realms_1_data;
    local realms_2_data;
    %{
        from tests.protostar.settling_game.relics import utils
        ids.Relics_address = context.Relics_address
        ids.Realms_token_address = context.Realms_token_address
        mock_call(ids.MODULE_CONTROLLER_ADDR, "get_external_contract_address", [ids.Realms_token_address])
        ids.realms_1_data = utils.pack_realm(utils.build_default_realm(1))
        ids.realms_2_data = utils.pack_realm(utils.build_default_realm(2))
        store(ids.Realms_token_address, "Ownable_owner", [ids.FAKE_OWNER_ADDR])
        stop_prank_callable = start_prank(ids.FAKE_OWNER_ADDR, ids.Realms_token_address)
    %}
    Realms.set_realm_data(Realms_token_address, Uint256(1, 0), realms_1_data);
    Realms.set_realm_data(Realms_token_address, Uint256(2, 0), realms_2_data);
    %{ 
        stop_prank_callable()
        stop_prank_callable = start_prank(ids.FAKE_OWNER_ADDR, context.Relics_address) 
    %}
    Relics.set_relic_holder(Relics_address, Uint256(2, 0), Uint256(1, 0));
    let (owner_id) = Relics.get_current_relic_holder(Relics_address, Uint256(1, 0));
    assert owner_id = Uint256(2, 0);
    return ();
}