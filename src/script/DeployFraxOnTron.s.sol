// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import { BaseScript } from "frax-std/BaseScript.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxtalL2 } from "src/contracts/chain-constants/FraxtalL2.sol";

import { ERC20PermitPermissionedOptiMintable} from "fraxtal-contracts/src/contracts/Fraxtal/universal/ERC20PermitPermissionedOptiMintable.sol";
import { FraxFerry } from "frax-contracts/src/hardhat/contracts/FraxFerry/FraxFerry.sol";

/*
NOTICE:
Deploy FRAX, sFRAX, and FXS on Tron using the same requirements as:
https://github.com/FraxFinance/fraxtal-contracts/blob/master/src/contracts/Fraxtal/universal/ERC20PermitPermissionedOptiMintable.sol

With the exception of no bridge minter

*/

contract DeployFraxOnTron is BaseScript {

    address public frax;
    address public fraxFerry;
    address public sFrax;
    address public sFraxFerry;
    address public fxs;
    address public fxsFerry;

    uint256 public deployerPk;
    address public deployerAddr;
    address public timelock;

    uint256 public constant TRON_CHAIN_ID = 1000;

    function setUp() public {
        // TODO

    }

    function run() public broadcaster {
        deployERC20sWithFerries();
    }

    function deployERC20sWithFerries() public {
        (frax, fraxFerry) = deployERC20WithFerry({
            _remoteToken: FraxtalL2.FRAX,
            _name: "Frax",
            _symbol: "FRAX"
        });
        (sFrax, sFraxFerry) = deployERC20WithFerry({
            _remoteToken: FraxtalL2.SFRAX,
            _name: "Staked Frax",
            _symbol: "sFRAX"
        });
        (fxs, fxsFerry) = deployERC20WithFerry({
            _remoteToken: FraxtalL2.FXS,
            _name: "Frax Share",
            _symbol: "FXS"
        });
    }

    function deployErc20WithFerry(
        address _remoteToken,
        string memory _name,
        string memory _symbol
    ) public returns (address) {
        ERC20PermitPermissionedOptiMintable erc20 = new ERC20PermitPermissionedOptiMintable({
            _creator_address: deployerAddr,
            _timelock_address: timelock,
            _bridge: address(1), // unreachable addr
            _remoteToken: _remoteToken,
            _name: _name,
            _symbol: _symbol
        });
        FraxFerry ferry = new FraxFerry({
            _token: address(erc20),
            _chainid: TRON_CHAIN_ID,
            _targetToken: _remoteToken,
            _targetChain: FraxtalL2.CHAIN_ID
        });

        console.log(_symbol);
        console.log(address(erc20));
        console.log("Ferry:");
        console.log(address(ferry));
    }
}
