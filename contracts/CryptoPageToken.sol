// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Stakeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PageToken is ERC20("PageToken", "PAGE"), Stakeable, Ownable {
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyOwner {
        _burn(to, amount);
    }

    function stake(uint256 _amount) public {
        // Make sure staker actually is good for it
        require(
            _amount < balanceOf(msg.sender),
            "PageToken: Cannot stake more than you own"
        );

        _stake(_amount);
        // Burn the amount of tokens on the sender
        _burn(msg.sender, _amount);
    }

    /**
     * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdrawStake(uint256 amount, uint256 stakeIndex) public {
        uint256 amountToMint = _withdrawStake(amount, stakeIndex);
        // Return staked tokens to user
        _mint(msg.sender, amountToMint);
    }
}
