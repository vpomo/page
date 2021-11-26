// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Stakeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PageToken is
    ERC20("PageToken", "PAGE"),
    Stakeable,
    AccessControl,
    Ownable
{
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyRole(BURNER_ROLE) {
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
