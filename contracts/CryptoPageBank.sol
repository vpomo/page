// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageToken.sol";

/// @title The contract calculates amount and mint / burn PAGE tokens
/// @author Crypto.Page Team
/// @notice
/// @dev
contract PageBank is OwnableUpgradeable, AccessControlUpgradeable, IPageBank {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    using SafeMathUpgradeable for uint256;

    /// Address of Crypto.Page treasury
    address public treasury;
    /// Address of CryptoPageNFT contract
    address public nft;
    /// Address of CryptoPageCommentDeployer contract
    address public commentDeployer;
    /// Treasury fee (1000 is 10%, 100 is 1% 10 is 0.1%)
    uint256 public treasuryFee;
    /// CryptoPageToken interface
    IPageToken public token;
    // UniswapV3Pool interface for USDT / PAGE pool
    IUniswapV3Pool private usdtpagePool;
    // UniswapV3Pool interface for WETH / USDT pool
    IUniswapV3Pool private wethusdtPool;

    // Storage balance per address
    mapping(address => uint256) private _balances;

    /// @notice Initial function
    /// @param _treasury Address of our treasury
    /// @param _treasuryFee Percent of treasury fee (1000 is 10%; 100 is 1%; 10 is 0.1%)
    function initialize(address _treasury, uint256 _treasuryFee)
        public
        initializer
    {
        __Ownable_init();
        treasury = _treasury;
        treasuryFee = _treasuryFee;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @notice Calculate and call burn
    /// @param sender The address on which the tokens burn
    /// @param receiver The receiver address
    /// @param gas Gas
    /// @return Calculated amount
    function calculateMint(
        address sender,
        address receiver,
        uint256 gas
    ) public override onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        if (sender == receiver) {
            amount += _refund(sender);
            _setBalance(treasury, _addBalance(treasury, treasuryAmount));
            token.mint(sender, amount);
        } else {
            _setBalance(treasury, _addBalance(treasury, treasuryAmount));
            _setBalance(receiver, _addBalance(receiver, amount));
            amount = amount.div(2);
            uint256 newAmount = amount += _refund(sender);
            token.mint(sender, newAmount);
        }
        return amount;
    }

    /// @notice Calculate and call burn
    /// @param receiver The address on which the tokens burn
    /// @param gas The amount of gas spent on the function call
    /// @param commentsReward Reward for comments
    /// @return Calculated amount
    function calculateBurn(
        address receiver,
        uint256 gas,
        uint256 commentsReward
    ) public override onlyRole(BURNER_ROLE) returns (uint256) {
        uint256 amount = _calculateAmount(gas);
        commentsReward = _calculateAmount(commentsReward);
        if (amount > commentsReward) {
            amount = amount.sub(commentsReward);
        }
        token.burn(receiver, amount);
        return amount;
    }

    /// @notice Withdraw amount from the bank
    function withdraw(uint256 amount) public payable override {
        require(_balances[_msgSender()] >= amount, "Not enough balance");
        _subBalance(_msgSender(), amount);
        token.mint(_msgSender(), amount);
    }

    /// @notice Bank balance of the sender's address
    function balanceOf() public view override returns (uint256) {
        return _balances[_msgSender()];
    }

    /// @notice Returns WETH / USDT price from UniswapV3
    /// @return WETH / USDT price
    function getWETHUSDTPrice() public view override returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = wethusdtPool.slot0();
        uint256 price = uint256(sqrtPriceX96)
            .mul(sqrtPriceX96)
            .mul(10e18)
            .div(10e6)
            .div(2**192);
        return price;
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @return USDT / PAGE price
    function getUSDTPAGEPrice() public view override returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = usdtpagePool.slot0();
        uint256 price = uint256(sqrtPriceX96)
            .mul(sqrtPriceX96)
            .div(10e18)
            .mul(10e6)
            .div(2**192);
        if (price > 100) {
            price = 100;
        }
        return price;
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _usdtpagePool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setUSDTPAGEPool(address _usdtpagePool) public override onlyOwner {
        usdtpagePool = IUniswapV3Pool(_usdtpagePool);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _wethusdtPool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setWETHUSDTPool(address _wethusdtPool) public override onlyOwner {
        wethusdtPool = IUniswapV3Pool(_wethusdtPool);
    }

    function setToken(address _address) public override onlyOwner {
        token = IPageToken(_address);
    }

    /// @notice Return amount from _balance and set 0
    /// @param _to Address of tokens holder
    /// @return Amount of PAGE tokens
    function _refund(address _to) private returns (uint256) {
        uint256 balance = _balances[_to];
        _balances[_to] = 0;
        return balance;
    }

    /// @notice Add amount to _balances
    /// @param _to Address to which to add
    /// @param _amount Amount that needs to add
    function _addBalance(address _to, uint256 _amount)
        private
        returns (uint256)
    {
        _balances[_to] = _balances[_to].add(_amount);
        return _balances[_to];
    }

    /// @notice Substraction amount from _balances
    /// @param _to Address to which to substraction
    /// @param _amount Amount that needs to substraction
    function _subBalance(address _to, uint256 _amount)
        private
        returns (uint256)
    {
        _balances[_to] = _balances[_to].sub(_amount);
        return _balances[_to];
    }

    /// @notice Set amount to _balances
    /// @param _to Address to which to set
    /// @param _amount Amount that needs to set
    function _setBalance(address _to, uint256 _amount) private {
        _balances[_to] = _amount;
    }

    /// @notice Returns gas multiplied by token's prices and gas price.
    /// @param _gas Comment author's address
    /// @return PAGE token's count
    function _calculateAmount(uint256 _gas) private view returns (uint256) {
        return
            _gas.mul(tx.gasprice).mul(getWETHUSDTPrice()).mul(
                getUSDTPAGEPrice()
            );
    }

    /// @notice Returns amount divided by treasury fee
    /// @param _amount Amount for dividing
    /// @return PAGE token's count
    function _calculateTreasuryAmount(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.div(10000).mul(treasuryFee);
    }
}
