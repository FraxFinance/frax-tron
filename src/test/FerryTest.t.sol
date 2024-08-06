// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseTest.t.sol";

contract FerryTest is BaseTest {
    uint256 bridgeAmount = 1000 * 1e18;
    bytes32 hashZero = 0x0000000000000000000000000000000000000000000000000000000000000000;

    function setUp() public virtual override {
        super.setUp();

        maxApproveFerries();
    }

    function maxApproveFerries() internal {
        maxApproveFerries(userA);
        maxApproveFerries(userB);
    }

    function maxApproveFerries(address who) internal {
        vm.startPrank(who);
        token0.approve(address(ferry0To1), type(uint256).max);
        token1.approve(address(ferry1To0), type(uint256).max);
        vm.stopPrank();
    }

    function test_embark() public {
        uint256 userBalanceBefore = token0.balanceOf(userA);
        uint256 ferryBalanceBefore = token0.balanceOf(address(ferry0To1));

        vm.prank(userA);
        ferry0To1.embark(bridgeAmount);

        assertEq({
            a: userBalanceBefore - token0.balanceOf(userA),
            b: bridgeAmount,
            err: "Bridge amount not transferred"
        });
        assertEq({
            a: token0.balanceOf(address(ferry0To1)) - ferryBalanceBefore,
            b: bridgeAmount,
            err: "Ferry did not receive bridge amount"
        });
        assertEq({ a: ferry0To1.noTransactions(), b: 1, err: "Ferry should have one tx" });

        uint256 fee = min(
            max((bridgeAmount * ferry0To1.FEE_RATE()) / 10_000, ferry0To1.FEE_MIN()),
            ferry0To1.FEE_MAX()
        );
        (address user, uint64 amount, uint32 timestamp) = ferry0To1.transactions(0);

        assertEq({ a: user, b: userA, err: "userA != tx.user" });
        assertEq({
            a: uint256(amount) * ferry0To1.REDUCED_DECIMALS(),
            b: bridgeAmount - fee,
            err: "bridgeAmount != tx.amount"
        });
        assertEq({ a: uint256(timestamp), b: block.timestamp, err: "block.timestamp != tx.timestamp" });
    }

    function min(uint256 a, uint256 b) internal returns (uint256) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function max(uint256 a, uint256 b) internal returns (uint256) {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }
}
