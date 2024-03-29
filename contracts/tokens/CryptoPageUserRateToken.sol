// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";

import "../interfaces/ICryptoPageUserRateToken.sol";
import "../interfaces/ICryptoPageBank.sol";

/// @title Contract of PAGE.UserRate token
/// @author Crypto.Page Team
/// @notice
/// @dev //https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/tree/master/contracts
contract PageUserRateToken is OwnableUpgradeable, ERC1155Upgradeable, IPageUserRateToken {

    address public calcUserRate;

    mapping(uint256 => uint256) private _totalSupply;

    modifier onlyCalcUserRate() {
        require(_msgSender() == calcUserRate, "ERC1155: not calcUserRate");
        _;
    }

    /// @notice Initial function
    /// @param _baseURL BaseURL of tokenURI, i.e. https://site.io/api/id=
    function initialize(
        string memory _baseURL
    ) public initializer {
        __Ownable_init();
        __ERC1155_init(_baseURL);
    }

    /**
     * @dev Returns the smart contract version
     *
     */
    function version() external pure returns (string memory) {
        return "1";
    }

    /**
     * @dev Sets the address of the contract that contains the logic and data for managing communities.
     *
     * @param  calcUserRateContract address of the contract
     */
    function setCalcRateContract(address calcUserRateContract) external override onlyOwner {
        require(calcUserRateContract != address(0), "ERC1155: address can't be null");
        calcUserRate = calcUserRateContract;
    }

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) external view override virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `onlyCommunity`.
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external override virtual onlyCalcUserRate {
        _mint(to, id, amount, data);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external override virtual onlyCalcUserRate {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external override virtual onlyCalcUserRate {
        _mintBatch(to, ids, amounts, data);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external override virtual onlyCalcUserRate {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }
}
