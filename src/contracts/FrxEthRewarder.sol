// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

contract FrxEthRewarder is Ownable, ReentrancyGuard {
    uint256 public rewardAmount;
    address public bot;
    mapping(address user => bool yes) public rewarded;

    event RewardBridger(address bridger, uint256 amount);

    constructor() Ownable(msg.sender) {}

    // -----------------------------------------------------------------------
    //                               ONLY-BOT
    // -----------------------------------------------------------------------

    /// @notice reward bridgers a fixed amount of frxETH
    /// @notice On duplicates, the loop continues to the next address to prevent halts
    function rewardBridgers(address[] memory bridgers) external nonReentrant {
        require(msg.sender == bot);

        uint256 length = bridgers.length;
        uint256 rewardAmount_ = rewardAmount;
        for (uint256 i = 0; i < length; ) {
            address bridger = bridgers[i];
            if (!rewarded[bridger]) {
                rewarded[bridger] = true;
                // Do nothing if the recipient is a contract - to only reward EOA
                if (bridger.code.length != 0) continue;
                // Assume the call is a success
                payable(bridger).call{ value: rewardAmount_ }("");

                emit RewardBridger(bridger, rewardAmount_);
            }

            unchecked {
                ++i;
            }
        }
    }

    // -----------------------------------------------------------------------
    //                              ONLY-OWNER
    // -----------------------------------------------------------------------

    function setRewardAmount(uint256 _newRewardAmount) external onlyOwner {
        rewardAmount = _newRewardAmount;
    }

    function setBot(address _newBot) external onlyOwner {
        bot = _newBot;
    }

    function withdrawFrxEth(address recipient, uint256 amount) onlyOwner {
        (bool success, ) = payable(recipient).call{ value: amount }("");
        require(success, "ETH Transfer failed");
    }
}
