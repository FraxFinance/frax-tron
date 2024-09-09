// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import { BaseScript } from "frax-std/BaseScript.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxtalL2 } from "src/contracts/chain-constants/FraxtalL2.sol";

import { Fraxferry } from "src/contracts/FraxFerry-flattened.sol";

/*
NOTICE:
Deploy Fraxtal ferries for FRAX, sFRAX, and FXS to Tron
TODO:
- differentiate owner, captain, firstOfficer, crewMember
- assert wait periods are as wanted
*/

contract DeployTronFerriesOnFraxtal is BaseScript {
    // TODO: set assets in chain constants
    address public fraxOnTron = 0x09Ac453B58d3eE843675bf0C8B35BFf5eDA46276;
    address public fraxFerry;
    address public sFraxOnTron = 0x2AD6FB1eaF3702485071c2cB8C634015BEBC8b3A;
    address public sFraxFerry;
    address public fxsOnTron = 0x03AF0C5ceCFB2d1e78158E6946BE8A54A99cC6cc;
    address public fxsFerry;

    address public timelock = 0xb0E1650A9760e0f383174af042091fc544b8356f;

    uint256 public constant TRON_CHAIN_ID = 728_126_428;

    function run() public broadcaster {
        deployFerries();
    }

    function deployFerries() public {
        fraxFerry = deployFerry({ _token: FraxtalL2.FRAX, _remoteToken: fraxOnTron });
        sFraxFerry = deployFerry({ _token: FraxtalL2.SFRAX, _remoteToken: sFraxOnTron });
        fxsFerry = deployFerry({ _token: FraxtalL2.FXS, _remoteToken: fxsOnTron });
    }

    function deployFerry(address _token, address _remoteToken) public returns (address) {
        Fraxferry ferry = new Fraxferry({
            _token: _token,
            _chainid: FraxtalL2.CHAIN_ID,
            _targetToken: _remoteToken,
            _targetChain: TRON_CHAIN_ID
        });

        // ferry.nominateNewOwner(timelock);

        console.log("Ferry: %s", address(ferry));
        return address(ferry);
    }
}
