// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@uniswap/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageCalcUserRate.sol";
import "./interfaces/ICryptoPageOracle.sol";

import {DataTypes} from './libraries/DataTypes.sol';

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
    bytes32 public constant VOTE_FOR_EARN_ROLE = keccak256("VOTE_FOR_EARN_ROLE");

    uint256 public FOR_MINT_GAS_AMOUNT = 145000;
    uint256 public FOR_BURN_GAS_AMOUNT = 95000;

    IUniswapV3Pool private wethPagePool;
    IPageOracle public oracle;
    uint256 public staticWETHPagePrice = 600;

    /// Address of Crypto.Page treasury
    address public treasury;
    /// Address of CryptoPageNFT contract
    address public nft;

    uint256 public ALL_PERCENT = 10000;
    /// Treasury fee (1000 is 10%, 100 is 1% 10 is 0.1%)
    uint256 public treasuryFee = 1000;

    /// CryptoPageToken interface
    IPageToken public token;
    IPageCalcUserRate public calcUserRate;

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

    // user -> communityId -> finished time
    mapping(address => mapping(uint256 => uint256)) private endPrivacyTime;
    // communityId -> balance of PAGE tokens
    mapping(uint256 => uint256) private communityBalance;
    // communityId -> price for privacy access
    mapping(uint256 => uint256) private privacyPrice;

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
    event TransferFromCommunity(address indexed user, uint256 amount);
    event AddedBalance(address indexed user, uint256 amount);

    event PaidForPrivacyAccess(address indexed user, uint256 indexed communityId, uint256 amount);
    event SetPriceForPrivacyAccess(uint256 oldValue, uint256 newValue);

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

    event SetOracle(address indexed newOracle);

    event SetForMintGasAmount(uint256 oldValue, uint256 newValue);
    event SetForBurnGasAmount(uint256 oldValue, uint256 newValue);

    event SetToken(address indexed token);
    event SetTreasuryFee(uint256 treasuryFee, uint256 newTreasuryFee);

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _treasury Address of our treasury
     * @param _admin Address of admin
     * @param _calcUserRate Address of calcUserRate
     */
    function initialize(address _treasury, address _admin, address _calcUserRate)
        public
        initializer
    {
        __Ownable_init();

        require(_treasury != address(0), "PageBank: wrong address");
        require(_admin != address(0), "PageBank: wrong address");
        require(_calcUserRate != address(0), "PageBank: wrong address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(BURNER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(UPDATER_FEE_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(CHANGE_PRICE_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(VOTE_FOR_EARN_ROLE, DEFAULT_ADMIN_ROLE);

        initDefaultFee();

        treasury = _treasury;
        calcUserRate = IPageCalcUserRate(_calcUserRate);
    }

    /**
     * @dev Returns the smart contract version
     *
     */
    function version() external pure override returns (string memory) {
        return "1";
    }

    /**
     * @dev Accepts ether to the balance of the contract
     * Required for testing
     *
     */
    receive() external payable {
        // React to receiving ether
        // Uncomment for production
        //revert("PageBank: asset transfer prohibited");
    }

    /**
     * @dev Sets the default commission values for creating and removing posts.
     * These values will be automatically assigned when a new community is created.
     *
     * @param communityId An identification number of community
     */
    function definePostFeeForNewCommunity(uint256 communityId) external override onlyRole(MINTER_ROLE) returns(bool) {
        CommunityFee storage fee = communityFee[communityId];

        fee.createPostOwnerFee = defaultCreatePostOwnerFee;
        fee.createPostCreatorFee = defaultCreatePostCreatorFee;
        fee.removePostOwnerFee = defaultRemovePostOwnerFee;
        fee.removePostCreatorFee = defaultRemovePostCreatorFee;
        return true;
    }

    /**
     * @dev Sets the default commission values for creating and removing comments.
     * These values will be automatically assigned when a new community is created.
     *
     * @param communityId An identification number of community
     */
    function defineCommentFeeForNewCommunity(uint256 communityId) external override onlyRole(MINTER_ROLE) returns(bool) {
        CommunityFee storage fee = communityFee[communityId];

        fee.createCommentOwnerFee = defaultCreateCommentOwnerFee;
        fee.createCommentCreatorFee = defaultCreateCommentCreatorFee;
        fee.removeCommentOwnerFee = defaultRemoveCommentOwnerFee;
        fee.removeCommentCreatorFee = defaultRemoveCommentCreatorFee;
        return true;
    }

    /**
     * @dev Reads the values of commissions from the community for creating and removing posts.
     *
     * @param communityId An identification number of community
     */
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

    /**
     * @dev Reads the values of commissions from the community for creating and removing comments.
     *
     * @param communityId An identification number of community
     */
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

    /**
     * @dev Changes the commission values for creating and removing posts.
     *
     * @param communityId An identification number of community
     */
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

    /**
     * @dev Changes the commission values for creating and removing comments.
     *
     * @param communityId An identification number of community
     */
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

    /**
     * @dev Calculates the equivalent number of tokens for gas consumption. Makes a mint of new tokens.
     *
     * @param communityId An identification number of community
     * @param owner The owner address
     * @param creator The creator address
     * @param gas Gas used
     */
    function mintTokenForNewPost(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external override onlyRole(MINTER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_MINT_GAS_AMOUNT);
        int256 creatorPercent = calcUserRate.checkCommunityActivity(communityId, creator, DataTypes.ActivityType.POST);
        amount = correctAmount(amount, creatorPercent);
        require(amount > 0, "PageBank: wrong amount");

        mintUserPageToken(owner, amount, communityFee[communityId].createPostOwnerFee);
        mintUserPageToken(creator, amount, communityFee[communityId].createPostCreatorFee);
        mintTreasuryPageToken(amount);

        emit MintForPost(communityId, owner, creator, amount);
    }

    /**
     * @dev Calculates the equivalent number of tokens for gas consumption. Makes a mint of new tokens.
     *
     * @param communityId An identification number of community
     * @param owner The owner address
     * @param creator The creator address
     * @param gas Gas used
     */
    function mintTokenForNewComment(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external override onlyRole(MINTER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_MINT_GAS_AMOUNT);
        int256 creatorPercent = calcUserRate.checkCommunityActivity(communityId, creator, DataTypes.ActivityType.MESSAGE);
        amount = correctAmount(amount, creatorPercent);
        require(amount > 0, "PageBank: wrong amount");

        mintUserPageToken(owner, amount, communityFee[communityId].createCommentOwnerFee);
        mintUserPageToken(creator, amount, communityFee[communityId].createCommentCreatorFee);
        mintTreasuryPageToken(amount);

        emit MintForComment(communityId, owner, creator, amount);
    }

    function addUpDownActivity(
        uint256 communityId,
        address postCreator,
        bool isUp
    ) external override onlyRole(MINTER_ROLE) {
        if (isUp) {
            calcUserRate.checkCommunityActivity(communityId, postCreator, DataTypes.ActivityType.UP);
        } else {
            calcUserRate.checkCommunityActivity(communityId, postCreator, DataTypes.ActivityType.DOWN);
        }
    }

    /**
     * @dev Calculates the equivalent number of tokens for gas consumption. Makes a burn of new tokens.
     *
     * @param communityId An identification number of community
     * @param owner The owner address
     * @param creator The creator address
     * @param gas Gas used
     */
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

    /**
     * @dev Calculates the equivalent number of tokens for gas consumption. Makes a burn of new tokens.
     *
     * @param communityId An identification number of community
     * @param owner The owner address
     * @param creator The creator address
     * @param gas Gas used
     */
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

    /**
     * @dev Withdraw amount from the bank.
     *
     * @param amount An amount of tokens
     */
    function withdraw(uint256 amount) external override {
        require(_balances[_msgSender()] >= amount, "PageBank: not enough balance of tokens");
        _balances[_msgSender()] -= amount;
        require(token.transfer(_msgSender(),  amount), "PageBank: wrong transfer of tokens");
        emit Withdraw(_msgSender(), amount);
    }

    /**
     * @dev Adds tokens to the user's balance in the contract.
     *
     * @param amount An amount of tokens
     */
    function addBalance(uint256 amount) external override {
        require(amount > 0, "PageBank: wrong amount");
        require(token.transferFrom(_msgSender(), address(this), amount), "PageBank: wrong transfer of tokens");
        _balances[_msgSender()] += amount;
        emit AddedBalance(_msgSender(), amount);
    }

    /**
     * @dev Set the new value of price for privacy access.
     *
     * @param communityId ID of community
     * @param newValue New value for price
     */
    function setPriceForPrivacyAccess(uint256 communityId, uint256 newValue) external override
        onlyRole(VOTE_FOR_EARN_ROLE)
    {
        uint256 oldValue = privacyPrice[communityId];
        require(oldValue != newValue, "PageBank: wrong value for price");
        emit SetPriceForPrivacyAccess(oldValue, newValue);
        privacyPrice[communityId] = newValue;
    }

    /**
     * @dev Transfer of earned tokens.
     *
     * @param communityId ID of community
     * @param amount Value for amount of tokens
     * @param wallet Address for transferring tokens
     */
    function transferFromCommunity(uint256 communityId, uint256 amount, address wallet) external override
        onlyRole(VOTE_FOR_EARN_ROLE) returns(bool)
    {
        require(communityBalance[communityId] >= amount, "PageBank: not enough balance of tokens");
        communityBalance[communityId] -= amount;
        require(token.transfer(wallet,  amount), "PageBank: wrong transfer of tokens");
        emit TransferFromCommunity(wallet, amount);
        return true;
    }

    /**
     * @dev Pay tokens for privacy access.
     *
     * @param amount An amount of tokens
     * @param communityId ID of community
     */
    function payForPrivacyAccess(uint256 amount, uint256 communityId) external override {
        address sender = _msgSender();
        uint256 price = privacyPrice[communityId];
        require(amount > 0, "PageBank: wrong amount");
        require(price > 0, "PageBank: wrong price");

        uint256 daysCount = amount / price;
        uint256 payAmount = daysCount * price;
        require(_balances[sender] >= payAmount, "PageBank: incorrect amount on the user's balance");

        _balances[sender] -= payAmount;
        communityBalance[communityId] += payAmount;
        endPrivacyTime[sender][communityId] += block.timestamp + (daysCount * 1 days);

        emit PaidForPrivacyAccess(_msgSender(), communityId, amount);
    }

    /**
     * @dev Bank balance of community.
     *
     * @param communityId ID of community
     */
    function balanceOfCommunity(uint256 communityId) external view override returns (uint256) {
        return communityBalance[communityId];
    }

    /**
     * @dev Bank balance of the user's address.
     *
     * @param user An address of user
     */
    function balanceOf(address user) external view override returns (uint256) {
        return _balances[user];
    }

    /**
     * @dev Changes default commission values for all new communities.
     *
     * @param index Order number of the commission
     * @param newValue New commission value
     */
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

    /**
     * @dev Changes the value of the FOR_MINT_GAS_AMOUNT.
     *
     * @param newValue New value for FOR_MINT_GAS_AMOUNT
     */
    function setMintGasAmount(uint256 newValue) external override onlyOwner {
        require(FOR_MINT_GAS_AMOUNT != newValue, "PageBank: wrong value for FOR_MINT_GAS_AMOUNT");
        emit SetForMintGasAmount(FOR_MINT_GAS_AMOUNT, newValue);
        FOR_MINT_GAS_AMOUNT = newValue;
    }

    /**
     * @dev Changes the value of the FOR_MINT_GAS_AMOUNT.
     *
     * @param newValue New value for FOR_MINT_GAS_AMOUNT
     */
    function setBurnGasAmount(uint256 newValue) external override onlyOwner {
        require(FOR_BURN_GAS_AMOUNT != newValue, "PageBank: wrong value for FOR_BURN_GAS_AMOUNT");
        emit SetForBurnGasAmount(FOR_BURN_GAS_AMOUNT, newValue);
        FOR_BURN_GAS_AMOUNT = newValue;
    }

    /**
     * @dev Changes the address of the oracle.
     *
     * @param newOracle New oracle address value
     */
    function setOracle(address newOracle) external override onlyOwner {
        require(newOracle != address(0), "PageBank: wrong address");

        oracle = IPageOracle(newOracle);
        emit SetOracle(newOracle);
    }

    /**
     * @dev Changes the address of the token.
     *
     * @param newToken New address value
     */
    function setToken(address newToken) external override onlyOwner {
        token = IPageToken(newToken);
        emit SetToken(newToken);
    }

    /**
     * @dev Changes the value of the fee for the Treasury.
     *
     * @param newTreasuryFee New fee value for the Treasury
     */
    function setTreasuryFee(uint256 newTreasuryFee) external override onlyOwner {
        require(newTreasuryFee != treasuryFee, "PageBank: wrong treasury value");
        emit SetTreasuryFee(treasuryFee, newTreasuryFee);
        treasuryFee = newTreasuryFee;
    }

    /**
     * @dev Checks for privacy access.
     *
     * @param user Address of user
     * @param communityId ID of community
     */
    function isPrivacyAvailable(address user, uint256 communityId) external view override returns(bool) {
        return endPrivacyTime[user][communityId] > block.timestamp;
    }

    // *** --- Private area --- ***

    /**
     * @dev Returns gas multiplied by token's prices and gas price.
     *
     * @param gas Gas used
     * @return PAGE token's count
     */
    function convertGasToTokenAmount(uint256 gas) private view returns (uint256) {
        return oracle.getFromWethToPageAmount(gas * tx.gasprice);
    }

    /**
     * @dev Mints PAGE tokens for Treasury.
     *
     * @param amount Amount of tokens
     */
    function mintTreasuryPageToken(uint256 amount) private {
        require(treasury != address(0), "PageBank: wrong treasury address");
        token.mint(treasury, amount * treasuryFee / ALL_PERCENT);
    }

    /**
     * @dev Mints PAGE tokens for user.
     *
     * @param user Address of user
     * @param amount Amount of tokens
     * @param userFee Fee for operation
     */
    function mintUserPageToken(address user, uint256 amount, uint256 userFee) private {
        require(user != address(0), "PageBank: wrong user address");

        uint256 userAmount = amount * userFee / ALL_PERCENT;
        token.mint(address(this), userAmount);
        _balances[user] += userAmount;
    }

    /**
     * @dev Burns PAGE tokens for user.
     *
     * @param user Address of user
     * @param amount Amount of tokens
     * @param userFee Fee for operation
     */
    function burnUserPageToken(address user, uint256 amount, uint256 userFee) private {
        require(user != address(0), "PageBank: wrong user address");

        uint256 userAmount = amount * userFee / ALL_PERCENT;
        token.burn(address(this), userAmount);
        _balances[user] -= userAmount;
    }

    function correctAmount(uint256 currentAmount, int256 percent) private view returns(uint256 newAmount) {
        int256 creatorAmount = int256(currentAmount) * percent / int256(ALL_PERCENT);
        if (creatorAmount > 0) {
            newAmount = currentAmount + uint256(creatorAmount);
        } else {
            uint256 positiveCreatorAmount = uint256(-creatorAmount);
            if (currentAmount >= positiveCreatorAmount) {
                newAmount = currentAmount - positiveCreatorAmount;
            } else {
                newAmount = 0;
            }
        }
    }

    function initDefaultFee() private {
        defaultCreatePostOwnerFee = 4500;
        defaultCreatePostCreatorFee = 4500;
        defaultRemovePostOwnerFee = 0;
        defaultRemovePostCreatorFee = 9000;

        defaultCreateCommentOwnerFee = 4500;
        defaultCreateCommentCreatorFee = 4500;
        defaultRemoveCommentOwnerFee = 0;
        defaultRemoveCommentCreatorFee = 9000;
    }
}
