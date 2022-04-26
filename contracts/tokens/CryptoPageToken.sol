// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20Upgradeable.sol";

import "../interfaces/ICryptoPageToken.sol";

    /**
     * @dev Only bank can mint and burn tokens
     *
     */
contract PageToken is ERC20Upgradeable, IPageToken {
    address public bank;

    modifier onlyBank() {
        require(
            _msgSender() == bank,
            "PageToken. Only bank can call this function"
        );
        _;
    }

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _treasury Address of our treasury
     * @param _bank Address of our PageBank contract
     */
    function initialize(address _treasury, address _bank) public initializer {
        __ERC20_init("Crypto.Page", "PAGE");
        require(_treasury != address(0), "PageToken: address cannot be zero");
        require(_bank != address(0), "PageToken: address cannot be zero");
        _mint(_treasury, 5e25);
        bank = _bank;
    }

    /**
     * @dev Returns the smart contract version
     *
     */
    function version() public pure returns (string memory) {
        return "1";
    }

    /**
     * @dev Mint PAGE tokens.
     *
     * @param to Address of token holder
     * @param amount How many tokens to be minted
     */
    function mint(address to, uint256 amount) public override onlyBank {
        _mint(to, amount);
    }

    /**
     * @dev Burn PAGE tokens.
     *
     * @param to Address of token holder
     * @param amount How many tokens to be burned
     */
    function burn(address to, uint256 amount) public override onlyBank {
        _burn(to, amount);
    }
}
