// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@uniswap/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

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
    bytes32 public constant UPDATER_FEE_ROLE = keccak256("UPDATER_FEE_ROLE");
    bytes32 public constant DEFINE_FEE_ROLE = keccak256("DEFINE_FEE_ROLE");
    bytes32 public constant CHANGE_PRICE_ROLE = keccak256("CHANGE_PRICE_ROLE");

    uint256 public FOR_MINT_GAS_AMOUNT = 2800;
    uint256 public FOR_BURN_GAS_AMOUNT = 2800;

    IUniswapV3Pool private wethPagePool;
    uint256 public staticWETHPagePrice = 600;
    uint256 public priceChangePercent = 700;

    /// Address of Crypto.Page treasury
    address public treasury;
    /// Address of CryptoPageNFT contract
    address public nft;
    /// Address of CryptoPageCommentDeployer contract
    address public commentDeployer;

    uint256 public ALL_PERCENT = 10000;
    /// Treasury fee (1000 is 10%, 100 is 1% 10 is 0.1%)
    uint256 public treasuryFee = 1000;

    /// CryptoPageToken interface
    IPageToken public token;

    struct CommunityFee {
        uint64 createPostOwnerFee;
        uint64 createPostCreatorFee;
        uint64 removePostOwnerFee;
        uint64 removePostCreatorFee;

        uint64 createCommentOwnerFee;
        uint64 createCommentCreatorFee;
        uint64 removeCommentOwnerFee;
        uint64 removeCommentCreatorFee;
    }

    mapping(uint256 => CommunityFee) private communityFee;

    uint64 public defaultCreatePostOwnerFee = 4500;
    uint64 public defaultCreatePostCreatorFee = 4500;
    uint64 public defaultRemovePostOwnerFee = 0;
    uint64 public defaultRemovePostCreatorFee = 9000;

    uint64 public defaultCreateCommentOwnerFee = 4500;
    uint64 public defaultCreateCommentCreatorFee = 4500;
    uint64 public defaultRemoveCommentOwnerFee = 0;
    uint64 public defaultRemoveCommentCreatorFee = 9000;

    // Storage balance per address
    mapping(address => uint256) private _balances;

    event Withdraw(address indexed user, uint256 amount);
    event AddedBalance(address indexed user, uint256 amount);

    event MintForPost(uint256 indexed communityId, address owner, address creator, uint256 amount);
    event MintForComment(uint256 indexed communityId, address owner, address creator, uint256 amount);

    event BurnForPost(uint256 indexed communityId, address owner, address creator, uint256 amount);
    event BurnForComment(uint256 indexed communityId, address owner, address creator, uint256 amount);

    event UpdatePostFee(
        uint256 indexed communityId,
        uint64 newCreatePostOwnerFee,
        uint64 newCreatePostCreatorFee,
        uint64 newRemovePostOwnerFee,
        uint64 newRemovePostCreatorFee
    );
    event UpdateCommentFee(
        uint256 indexed communityId,
        uint64 newCreateCommentOwnerFee,
        uint64 newCreateCommentCreatorFee,
        uint64 newRemoveCommentOwnerFee,
        uint64 newRemoveCommentCreatorFee
    );
    event SetDefaultFee(uint256 index, uint256 oldFee, uint256 newFee);

    event SetWETHUSDTPool(address indexed pool);
    event SetStaticWETHPagePrice(uint256 oldPrice, uint256 newPrice);
    event SetPriceChangePercent(uint256 oldPercent, uint256 newPercent);

    event SetToken(address indexed token);
    event SetTreasuryFee(uint256 treasuryFee, uint256 newTreasuryFee);

    /// @notice Initial function
    /// @param _treasury Address of our treasury
    /// @param _admin Address of admin
    function initialize(address _treasury, address _admin)
        public
        initializer
    {
        __Ownable_init();

        require(_treasury != address(0), "PageBank: wrong address");
        require(_admin != address(0), "PageBank: wrong address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(BURNER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(UPDATER_FEE_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(CHANGE_PRICE_ROLE, DEFAULT_ADMIN_ROLE);

        treasury = _treasury;
    }

    function version() external pure override returns (string memory) {
        return "1";
    }

    function definePostFeeForNewCommunity(uint256 communityId) external override onlyRole(MINTER_ROLE) returns(bool) {
        CommunityFee storage fee = communityFee[communityId];

        fee.createPostOwnerFee = defaultCreatePostOwnerFee;
        fee.createPostCreatorFee = defaultCreatePostCreatorFee;
        fee.removePostOwnerFee = defaultRemovePostOwnerFee;
        fee.removePostCreatorFee = defaultRemovePostCreatorFee;
        return true;
    }

    function defineCommentFeeForNewCommunity(uint256 communityId) external override onlyRole(MINTER_ROLE) returns(bool) {
        CommunityFee storage fee = communityFee[communityId];

        fee.createCommentOwnerFee = defaultCreateCommentOwnerFee;
        fee.createCommentCreatorFee = defaultCreateCommentCreatorFee;
        fee.removeCommentOwnerFee = defaultRemoveCommentOwnerFee;
        fee.removeCommentCreatorFee = defaultRemoveCommentCreatorFee;
        return true;
    }

    function readPostFee(uint256 communityId) external override view returns(
        uint64 createPostOwnerFee,
        uint64 createPostCreatorFee,
        uint64 removePostOwnerFee,
        uint64 removePostCreatorFee
    ) {
        CommunityFee memory fee = communityFee[communityId];

        createPostOwnerFee = fee.createPostOwnerFee;
        createPostCreatorFee = fee.createPostCreatorFee;
        removePostOwnerFee = fee.removePostOwnerFee;
        removePostCreatorFee = fee.removePostCreatorFee;
    }

    function readCommentFee(uint256 communityId) external override view returns(
        uint64 createCommentOwnerFee,
        uint64 createCommentCreatorFee,
        uint64 removeCommentOwnerFee,
        uint64 removeCommentCreatorFee
    ) {
        CommunityFee memory fee = communityFee[communityId];

        createCommentOwnerFee = fee.createCommentOwnerFee;
        createCommentCreatorFee = fee.createCommentCreatorFee;
        removeCommentOwnerFee = fee.removeCommentOwnerFee;
        removeCommentCreatorFee = fee.removeCommentCreatorFee;
    }

    function updatePostFee(
        uint256 communityId,
        uint64 newCreatePostOwnerFee,
        uint64 newCreatePostCreatorFee,
        uint64 newRemovePostOwnerFee,
        uint64 newRemovePostCreatorFee
    ) external override onlyRole(UPDATER_FEE_ROLE) {
        CommunityFee storage fee = communityFee[communityId];
        fee.createPostOwnerFee = newCreatePostOwnerFee;
        fee.createPostCreatorFee = newCreatePostCreatorFee;
        fee.removePostOwnerFee = newRemovePostOwnerFee;
        fee.removePostCreatorFee = newRemovePostCreatorFee;

        emit UpdatePostFee(communityId,
            newCreatePostOwnerFee,
            newCreatePostCreatorFee,
            newRemovePostOwnerFee,
            newRemovePostCreatorFee
        );
    }

    function updateCommentFee(
        uint256 communityId,
        uint64 newCreateCommentOwnerFee,
        uint64 newCreateCommentCreatorFee,
        uint64 newRemoveCommentOwnerFee,
        uint64 newRemoveCommentCreatorFee
    ) external override onlyRole(UPDATER_FEE_ROLE) {
        CommunityFee storage fee = communityFee[communityId];
        fee.createCommentOwnerFee = newCreateCommentOwnerFee;
        fee.createCommentCreatorFee = newCreateCommentCreatorFee;
        fee.removeCommentOwnerFee = newRemoveCommentOwnerFee;
        fee.removeCommentCreatorFee = newRemoveCommentCreatorFee;

        emit UpdateCommentFee(communityId,
            newCreateCommentOwnerFee,
            newCreateCommentCreatorFee,
            newRemoveCommentOwnerFee,
            newRemoveCommentCreatorFee
        );
    }

    /// @notice Calculate and call burn
    /// @param communityId The ID for community
    /// @param owner The owner address
    /// @param creator The creator address
    /// @param gas Gas used
    function mintTokenForNewPost(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external override onlyRole(MINTER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_MINT_GAS_AMOUNT);

        mintUserPageToken(owner, amount, communityFee[communityId].createPostOwnerFee);
        mintUserPageToken(creator, amount, communityFee[communityId].createPostCreatorFee);
        mintTreasuryPageToken(amount);

        emit MintForPost(communityId, owner, creator, amount);
    }

    function mintTokenForNewComment(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external override onlyRole(MINTER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_MINT_GAS_AMOUNT);

        mintUserPageToken(owner, amount, communityFee[communityId].createCommentOwnerFee);
        mintUserPageToken(creator, amount, communityFee[communityId].createCommentCreatorFee);
        mintTreasuryPageToken(amount);

        emit MintForComment(communityId, owner, creator, amount);
    }

    /// @dev Calculate and call burn
    /// @param communityId The ID for community
    /// @param owner The owner address
    /// @param creator The creator address
    /// @param gas The amount of gas spent on the function call
    function burnTokenForPost(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external override onlyRole(BURNER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_BURN_GAS_AMOUNT);

        burnUserPageToken(owner, amount, communityFee[communityId].removePostOwnerFee);
        burnUserPageToken(creator, amount, communityFee[communityId].removePostCreatorFee);
        mintTreasuryPageToken(amount);

        emit BurnForPost(communityId, owner, creator, amount);
    }

    function burnTokenForComment(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external override onlyRole(BURNER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_BURN_GAS_AMOUNT);

        burnUserPageToken(owner, amount, communityFee[communityId].removeCommentOwnerFee);
        burnUserPageToken(creator, amount, communityFee[communityId].removeCommentCreatorFee);
        mintTreasuryPageToken(amount);

        emit BurnForComment(communityId, owner, creator, amount);
    }

    /// @notice Withdraw amount from the bank
    function withdraw(uint256 amount) external override {
        require(_balances[_msgSender()] >= amount, "Not enough balance");
        _balances[_msgSender()] -= amount;
        token.mint(_msgSender(), amount);
        emit Withdraw(_msgSender(), amount);
    }

    function addBalance(uint256 amount) external override {
        require(amount > 0, "Wrong amount");
        require(token.transferFrom(_msgSender(), address(this), amount));
        _balances[_msgSender()] += amount;
        emit AddedBalance(_msgSender(), amount);
    }

    /// @notice Bank balance of the sender's address
    function balanceOf(address user) external view override returns (uint256) {
        return _balances[user];
    }

    function getWETHPagePriceFromPool() public view override returns (uint256 price) {
        (uint160 sqrtPriceX96, , , , , , ) = wethPagePool.slot0();
        price = uint256(sqrtPriceX96) * sqrtPriceX96 / 10e18 * 10e6 / 2**192;
    }

    function getWETHPagePrice() public view override returns (uint256 price) {
        try this.getWETHPagePriceFromPool() returns (
            uint256 _price
        ) {
            price = validChangePrice(_price) ? _price : staticWETHPagePrice;
//            if (!validChangePrice(_price)) {
//                price = staticWETHPagePrice;
//            } else {
//                price = _price;
//            }
        } catch {
            price = staticWETHPagePrice;
        }
        if (price == 0) {
            price = staticWETHPagePrice;
        }
    }

    function setDefaultFee(uint256 index, uint64 newValue) external override onlyOwner {
        if (index == 0) {
            emit SetDefaultFee(index, defaultCreatePostOwnerFee, newValue);
            defaultCreatePostOwnerFee = newValue;
        }
        if (index == 1) {
            emit SetDefaultFee(index, defaultCreatePostCreatorFee, newValue);
            defaultCreatePostCreatorFee = newValue;
        }
        if (index == 2) {
            emit SetDefaultFee(index, defaultRemovePostOwnerFee, newValue);
            defaultRemovePostOwnerFee = newValue;
        }
        if (index == 3) {
            emit SetDefaultFee(index, defaultRemovePostCreatorFee, newValue);
            defaultRemovePostCreatorFee = newValue;
        }
        if (index == 4) {
            emit SetDefaultFee(index, defaultCreateCommentOwnerFee, newValue);
            defaultCreateCommentOwnerFee = newValue;
        }
        if (index == 5) {
            emit SetDefaultFee(index, defaultCreateCommentCreatorFee, newValue);
            defaultCreateCommentCreatorFee = newValue;
        }
        if (index == 6) {
            emit SetDefaultFee(index, defaultRemoveCommentOwnerFee, newValue);
            defaultRemoveCommentOwnerFee = newValue;
        }
        if (index == 7) {
            emit SetDefaultFee(index, defaultRemoveCommentCreatorFee, newValue);
            defaultRemoveCommentCreatorFee = newValue;
        }
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param newWethPagePool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setWETHPagePool(address newWethPagePool) external override onlyOwner {
        wethPagePool = IUniswapV3Pool(newWethPagePool);
        emit SetWETHUSDTPool(newWethPagePool);
    }

    function setStaticWETHPagePrice(uint256 price) external override onlyOwner {
        require(price != staticWETHPagePrice, "PageBank: wrong price");
        emit SetStaticWETHPagePrice(staticWETHPagePrice, price);
        staticWETHPagePrice = price;
    }

    function setPriceChangePercent(uint256 percent) external override onlyOwner {
        require(percent <= ALL_PERCENT && percent != priceChangePercent, "PageBank: wrong percent");
        emit SetPriceChangePercent(priceChangePercent, percent);
        priceChangePercent = percent;
    }

    function setToken(address newToken) external override onlyOwner {
        token = IPageToken(newToken);
        emit SetToken(newToken);
    }

    function setTreasuryFee(uint256 newTreasuryFee ) external override onlyOwner {
        require(newTreasuryFee != treasuryFee, "PageBank: wrong treasury value");
        emit SetTreasuryFee(treasuryFee, newTreasuryFee);
        treasuryFee = newTreasuryFee;
    }

    /// @notice Returns gas multiplied by token's prices and gas price.
    /// @param gas Gas used
    /// @return PAGE token's count
    function convertGasToTokenAmount(uint256 gas) private view returns (uint256) {
        return gas * tx.gasprice * getWETHPagePrice();
    }

    function mintTreasuryPageToken(uint256 amount) private {
        require(treasury != address(0), "PageBank: wrong treasury address");
        token.mint(treasury, amount * treasuryFee / ALL_PERCENT);
    }

    function mintUserPageToken(address user, uint256 amount, uint256 userFee) private {
        require(user != address(0), "PageBank: wrong user address");

        uint256 userAmount = amount * userFee / ALL_PERCENT;
        token.mint(address(this), userAmount);
        _balances[user] += userAmount;
    }

    function burnUserPageToken(address user, uint256 amount, uint256 userFee) private {
        require(user != address(0), "PageBank: wrong user address");

        uint256 userAmount = amount * userFee / ALL_PERCENT;
        token.burn(address(this), userAmount);
        _balances[user] -= userAmount;
    }

    function validChangePrice(uint256 currentPrice) private view returns(bool isValid) {
        if (currentPrice <= staticWETHPagePrice) {
            isValid = (staticWETHPagePrice - currentPrice) <= staticWETHPagePrice * priceChangePercent / ALL_PERCENT;
        }
        if (currentPrice > staticWETHPagePrice) {
            isValid = (currentPrice - staticWETHPagePrice) < currentPrice * priceChangePercent / ALL_PERCENT;
        }
    }
}
