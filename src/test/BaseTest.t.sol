// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "frax-std/FraxTest.sol";
import "../contracts/Counter.sol";
import "./Helpers.sol";

import { Mainnet } from "src/contracts/chain-constants/Mainnet.sol";
import { FraxtalL1Devnet } from "src/contracts/chain-constants/FraxtalL1Devnet.sol";
import { FraxtalL2 } from "src/contracts/chain-constants/FraxtalL2.sol";
import { FraxtalTestnetL1 } from "src/contracts/chain-constants/FraxtalTestnetL1.sol";
import { FraxtalTestnetL2 } from "src/contracts/chain-constants/FraxtalTestnetL2.sol";

import { ERC20PermissionedMint } from "src/contracts/ERC20WithMinters-flattened.sol";
import { Fraxferry } from "src/contracts/FraxFerry-flattened.sol";

contract BaseTest is FraxTest {
    Counter public counter;

    address timelock = Mainnet.TIMELOCK_ADDRESS;
    // Fraxtal / Fraxtal Testnet L1 & L2 addresses
    address public PROXY_ADMIN;
    address public COMPTROLLER;
    // Fraxtal / Fraxtal Testnet L1 addresses
    address public ADDRESS_MANAGER;
    address public L1_CROSS_DOMAIN_MESSENGER_PROXY;
    address public L1_ERC721_BRIDGE_PROXY;
    address public L1_STANDARD_BRIDGE_PROXY;
    address public L2_OUTPUT_ORACLE_PROXY;
    address public OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY;
    address public OPTIMISM_PORTAL_PROXY;
    address public SYSTEM_CONFIG_PROXY;
    // Fraxtal / Fraxtal Testnet L2 addresses
    address public FRAXSWAP_FACTORY;
    address public FRAXSWAP_ROUTER;
    address public FRAXSWAP_ROUTER_MULTIHOP;

    // test contracts
    ERC20PermissionedMint public token0;
    ERC20PermissionedMint public token1;
    Fraxferry public ferry0To1;
    Fraxferry public ferry1To0;
    uint256 public chainIdToken0 = 111;
    uint256 public chainIdToken1 = 222;

    // test users
    address public captain = address(0x111111);
    address public firstOfficer = address(0x222222);
    address public crewmember = address(0x333333);
    address public owner = address(0x4444444);
    address public userA = address(0x555555);
    address public userB = address(0x666666);

    constructor() {
        // Setup fraxtal / fraxtal testnet L1 addresses
        if (block.chainid == Mainnet.CHAIN_ID) {
            PROXY_ADMIN = Mainnet.PROXY_ADMIN;
            COMPTROLLER = Mainnet.COMPTROLLER;
            ADDRESS_MANAGER = Mainnet.ADDRESS_MANAGER;
            L1_CROSS_DOMAIN_MESSENGER_PROXY = Mainnet.L1_CROSS_DOMAIN_MESSENGER_PROXY;
            L1_ERC721_BRIDGE_PROXY = Mainnet.L1_ERC721_BRIDGE_PROXY;
            L1_STANDARD_BRIDGE_PROXY = Mainnet.L1_STANDARD_BRIDGE_PROXY;
            L2_OUTPUT_ORACLE_PROXY = Mainnet.L2_OUTPUT_ORACLE_PROXY;
            OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY = Mainnet.OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY;
            OPTIMISM_PORTAL_PROXY = Mainnet.OPTIMISM_PORTAL_PROXY;
            SYSTEM_CONFIG_PROXY = Mainnet.SYSTEM_CONFIG_PROXY;
        } else if (block.chainid == FraxtalTestnetL1.CHAIN_ID) {
            PROXY_ADMIN = FraxtalTestnetL1.PROXY_ADMIN;
            COMPTROLLER = FraxtalTestnetL1.COMPTROLLER;
            ADDRESS_MANAGER = FraxtalTestnetL1.ADDRESS_MANAGER;
            L1_CROSS_DOMAIN_MESSENGER_PROXY = FraxtalTestnetL1.L1_CROSS_DOMAIN_MESSENGER_PROXY;
            L1_ERC721_BRIDGE_PROXY = FraxtalTestnetL1.L1_ERC721_BRIDGE_PROXY;
            L1_STANDARD_BRIDGE_PROXY = FraxtalTestnetL1.L1_STANDARD_BRIDGE_PROXY;
            L2_OUTPUT_ORACLE_PROXY = FraxtalTestnetL1.L2_OUTPUT_ORACLE_PROXY;
            OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY = FraxtalTestnetL1.OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY;
            OPTIMISM_PORTAL_PROXY = FraxtalTestnetL1.OPTIMISM_PORTAL_PROXY;
            SYSTEM_CONFIG_PROXY = FraxtalTestnetL1.SYSTEM_CONFIG_PROXY;
        }
        // Setup fraxtal / fraxtal testnet L2 addresses
        if (block.chainid == FraxtalL2.CHAIN_ID) {
            FRAXSWAP_FACTORY = FraxtalL2.FRAXSWAP_FACTORY;
            FRAXSWAP_ROUTER = FraxtalL2.FRAXSWAP_ROUTER;
            FRAXSWAP_ROUTER_MULTIHOP = FraxtalL2.FRAXSWAP_ROUTER_MULTIHOP;
        } else if (block.chainid == FraxtalTestnetL2.CHAIN_ID) {
            FRAXSWAP_FACTORY = FraxtalTestnetL2.FRAXSWAP_FACTORY;
            FRAXSWAP_ROUTER = FraxtalTestnetL2.FRAXSWAP_ROUTER;
            FRAXSWAP_ROUTER_MULTIHOP = FraxtalTestnetL2.FRAXSWAP_ROUTER_MULTIHOP;
        }
    }

    function setUp() public virtual {
        deployTokens();
        deployFerriesAndMint();
    }

    function deployTokens() internal {
        token0 = deployToken({ _name: "Token 0", _symbol: "T0" });
        token1 = deployToken({ _name: "Token 1", _symbol: "T1" });
    }

    function deployToken(string memory _name, string memory _symbol) internal returns (ERC20PermissionedMint token) {
        token = new ERC20PermissionedMint({
            _creator_address: owner,
            _timelock_address: owner,
            _name: _name,
            _symbol: _symbol
        });
    }

    function deployFerriesAndMint() internal {
        ferry0To1 = deployFerryAndMint({
            _tokenFrom: token0,
            _chainIdFrom: chainIdToken0,
            _tokenTo: token1,
            _chainIdTo: chainIdToken1
        });
        ferry1To0 = deployFerryAndMint({
            _tokenFrom: token1,
            _chainIdFrom: chainIdToken1,
            _tokenTo: token0,
            _chainIdTo: chainIdToken0
        });
    }

    function deployFerryAndMint(
        ERC20PermissionedMint _tokenFrom,
        uint256 _chainIdFrom,
        ERC20PermissionedMint _tokenTo,
        uint256 _chainIdTo
    ) internal returns (Fraxferry ferry) {
        ferry = new Fraxferry({
            _token: address(_tokenFrom),
            _chainid: _chainIdFrom,
            _targetToken: address(_tokenTo),
            _targetChain: _chainIdTo
        });

        ferry.setCaptain(captain);
        ferry.setFirstOfficer(firstOfficer);
        ferry.setCrewmember(crewmember, true);
        ferry.nominateNewOwner(owner);

        vm.startPrank(owner);
        _tokenFrom.addMinter(owner);
        _tokenFrom.minter_mint(owner, 1e24);
        _tokenFrom.minter_mint(userA, 1e24);
        _tokenFrom.minter_mint(userB, 1e24);
        _tokenFrom.minter_mint(address(ferry), 1e24);
        vm.stopPrank();
    }
}
