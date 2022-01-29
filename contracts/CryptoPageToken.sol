// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "./interfaces/ICryptoPageToken.sol";

/// @title Contract of PAGE token
/// @author Crypto.Page Team
/// @notice
/// @dev Only bank can mint and burn tokens
contract PageToken is ERC20Upgradeable, IPageToken {
    address public bank;

    modifier onlyBank() {
        require(
            _msgSender() == bank,
            "PageToken. Only bank can call this function"
        );
        _;
    }

    /// @notice Initial function
    /// @param _treasury treasury address for initial mint
    /// @param _bank Address of our PageBank contract
    function initialize(address _treasury, address _bank) public initializer {
        __ERC20_init("Crypto.Page", "PAGE");
        _mint(_treasury, 5e25);
        bank = _bank;
    }

    /// @notice Mint PAGE tokens
    /// @param to Address of token holder
    /// @param amount How many to be minted
    function mint(address to, uint256 amount) public override onlyBank {
        _mint(to, amount);
    }

    /// @notice Burn PAGE tokens
    /// @param to Address of token holder
    /// @param amount How many to be burned
    function burn(address to, uint256 amount) public override onlyBank {
        _burn(to, amount);
    }
}
