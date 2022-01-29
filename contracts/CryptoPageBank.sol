// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

// import "hardhat/console.sol";

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
contract PageBank is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPageBank
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    using SafeMathUpgradeable for uint256;

    event Withdraw(address indexed _to, uint256 indexed _amount);
    // event Mint(address indexed _to, uint256 indexed _amount);
    // event Burn(address indexed _to, uint256 indexed _amount);
    event Deposit(address indexed _to, uint256 indexed _amount);
    event Burn(address indexed _to, uint256 indexed _amount);
    event SetWETHUSDTPool(address indexed _pool);
    event SetUSDTPAGEPool(address indexed _pool);
    event SetStaticWETHUSDTPrice(uint256 indexed _price);
    event SetStaticUSDTPAGEPrice(uint256 indexed _price);
    event SetToken(address indexed _token);

    uint256 public staticUSDTPAGEPrice = 60;
    uint256 public staticWETHUSDTPrice = 3600;

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
    function calculateMint(
        address sender,
        address receiver,
        uint256 gas
    ) public override onlyRole(MINTER_ROLE) returns (uint256 amount) {
        amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        uint256 senderBalance = _balances[sender];
        if (sender == receiver) {
            amount += senderBalance;
            emit Withdraw(sender, senderBalance);
            token.mint(sender, amount);
        } else {
            amount = amount.div(2);
            uint256 recieverAmount = _balances[receiver].add(amount);
            _balances[receiver] = recieverAmount;
            emit Withdraw(sender, senderBalance);
            emit Deposit(receiver, recieverAmount);
            token.mint(sender, amount += senderBalance);
        }
        _balances[treasury] = _balances[treasury].add(treasuryAmount);
        emit Deposit(treasury, treasuryAmount);
    }

    /// @notice Calculate and call burn
    /// @param receiver The address on which the tokens burn
    /// @param gas The amount of gas spent on the function call
    /// @param commentsReward Reward for comments in PAGE tokens
    function calculateBurn(
        address receiver,
        uint256 gas,
        uint256 commentsReward
    ) public override onlyRole(BURNER_ROLE) returns (uint256 amount) {
        amount = _calculateAmount(gas).add(_balances[receiver]);
        if (commentsReward > amount) {
            commentsReward = commentsReward.sub(amount);
            require(token.balanceOf(receiver) > commentsReward, "");
            _balances[receiver] = 0;
            emit Burn(receiver, _balances[receiver]);
            token.burn(receiver, commentsReward);
        } else {
            amount = amount.sub(commentsReward);
            _balances[receiver] = amount;
            // emit Deposit(receiver, amount - commentsReward);
            // amount - commentsReward;
            // emit Deposit(receiver, amount);
            // emit Burn(receiver, commentsReward);
        }
    }

    /// @notice Withdraw amount from the bank
    function withdraw(uint256 amount) public override {
        require(_balances[_msgSender()] >= amount, "Not enough balance");
        _balances[_msgSender()] -= amount;
        token.mint(_msgSender(), amount);
        emit Withdraw(_msgSender(), amount);
    }

    /// @notice Bank balance of the sender's address
    function balance() public view override returns (uint256) {
        return _balances[_msgSender()];
    }

    /// @notice Returns WETH / USDT price from UniswapV3Pool
    function getWETHUSDTPrice() public view override returns (uint256 price) {
        try wethusdtPool.slot0() returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        ) {
            price = uint256(sqrtPriceX96)
                .mul(sqrtPriceX96)
                .div(10e18)
                .mul(10e6)
                .div(2**192);
        } catch {
            price = staticUSDTPAGEPrice;
        }
    }

    /// @notice Returns USDT / PAGE price from UniswapV3Pool
    function getUSDTPAGEPrice() public view override returns (uint256 price) {
        try usdtpagePool.slot0() returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        ) {
            price = uint256(sqrtPriceX96)
                .mul(sqrtPriceX96)
                .div(10e18)
                .mul(10e6)
                .div(2**192);
        } catch {
            price = staticUSDTPAGEPrice;
        }
        if (price > 100) {
            price = 100;
        }
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _usdtpagePool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setUSDTPAGEPool(address _usdtpagePool) public override onlyOwner {
        usdtpagePool = IUniswapV3Pool(_usdtpagePool);
        emit SetUSDTPAGEPool(_usdtpagePool);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _wethusdtPool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setWETHUSDTPool(address _wethusdtPool) public override onlyOwner {
        wethusdtPool = IUniswapV3Pool(_wethusdtPool);
        emit SetWETHUSDTPool(_wethusdtPool);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    function setStaticUSDTPAGEPrice(uint256 _price) public override onlyOwner {
        staticUSDTPAGEPrice = _price;
        emit SetStaticUSDTPAGEPrice(_price);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    function setStaticWETHUSDTPrice(uint256 _price) public override onlyOwner {
        staticWETHUSDTPrice = _price;
        emit SetStaticWETHUSDTPrice(_price);
    }

    function setToken(address _address) public override onlyOwner {
        token = IPageToken(_address);
        emit SetToken(_address);
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
