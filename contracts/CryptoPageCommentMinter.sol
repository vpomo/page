// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "./CryptoPageComment.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract PageCommentMinter {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    mapping(address => EnumerableMap.UintToAddressMap) private commentsByERC721;

    // mapping(uint256 => address) private commentsByTokenId;
    // mapping(address => bool) private commentsActivate;
    // mapping(uint256 => address) private commentsById;

    function _exists(address _nft, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return commentsByERC721[_nft].contains(_tokenId);
    }

    function _get(address _nft, uint256 _tokenId)
        public
        view
        returns (PageComment)
    {
        return PageComment(commentsByERC721[_nft].get(_tokenId));
    }

    function _set(address _nft, uint256 _tokenId) public returns (PageComment) {
        // IERC721 nft = IERC721(_nft);
        // address owner = nft.ownerOf(_tokenId);
        PageComment comment = new PageComment();
        commentsByERC721[_nft].set(_tokenId, address(comment));
        return comment; // new PageComment();
    }

    /*
    function _getOrCreateCommentContract(address _nft, uint256 _tokenId) private returns ( PageComment ) {
        bool exist = commentsByERC721[_nft].contains(_tokenId);
        if (exist) {
            return PageComment(commentsByERC721[_nft].get(_tokenId));
        } else {
            IERC721 nft = IERC721(_nft);
            address owner = nft.ownerOf(_tokenId);
            PageComment comment = PageComment(owner); 
            commentsByERC721[_nft].set(_tokenId, address(comment));
            return new PageComment();
        }
    }
    */

    /*
    function commentActiveToggle(address _nft, uint256 _tokenId) public {
        PageComment comment = _getOrCreateCommentContract(_nft, _tokenId);
        comment.toggleActive();
    }
    */

    function activated(address _nft, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return _exists(_nft, _tokenId);
    }

    function activateComment(address _nft, uint256 _tokenId) public {
        // bool exists = _exists(_nft, _tokenId);
        // require(exists);
        _set(_nft, _tokenId);
    }

    function createComment(
        address _nft,
        uint256 _tokenId,
        address _author,
        string memory _text,
        bool _like
    ) public {
        bool exists = _exists(_nft, _tokenId);
        if (exists) {
            _get(_nft, _tokenId).createComment(_author, _text, _like);
        } else {
            _set(_nft, _tokenId).createComment(_author, _text, _like);
        }
    }

    /*    
    function getCommentsIds(address _nft, uint256 _tokenId) public view returns (uint256[] memory) {
        PageComment comment = _getOrCreateCommentContract(_nft, _tokenId);
        return comment.getCommentsIds();
    }
    */

    /*
        // IERC721 nft = IERC721(_nft);contains
        // require(nft.ownerOf(_tokenId), "Only owner can activate comments  for this NFT");
        // PageComment comment = new PageComment();
        bool exist = commentsByERC721[_nft].contains(_tokenId);
        // bool exist = comments[_tokenId].contains();
        if (exist) {
            address comment = commentsByERC721[_nft].get(_tokenId);
            PageComment commentContract = PageComment(comment);
            commentContract.toggleActive();
            // commentContract.toggleActive()
            // commentActivate[_nft] = false
        } else {
            // commentsByERC721[_nft].add(comment);
            // commentsByTokenId[_tokenId] = comment;
            // comment = commentsByERC721[_nft];
            // PageComment commentContract = PageComment(comment);
            // commentContract.toggleActive();
        }

        
        // bool active = commentsActivate[address(comment)];
        // commentsByERC721[address(nft)].add(comment);
        // commentsById[_tokenId] = address(newComment);
        // IERC721 public nft;
        // require(commentsById[_tokenId] == address(0), "Comments alredy setup");
        /*
        require(
            ownerOf(_tokenId) == msg.sender,
            "It's possible only for owner"
        );
        PageComment newComment = new PageComment();
        commentsById[_tokenId] = address(newComment);
        uint256 amount = 10000000000000000000;
        pageMinter.mint(msg.sender, amount); // MINT
        
    }
    */

    /*
    function createComment(address _nft, uint256 _tokenId, string _text, bool _like) {
        address commentContract = commentByNFT[_nft];
        // PageComment commentContract = PageComment(commentsById[_tokenId]);

        if (commentContract) {
            // comment = commentByNFT[_nft];
            commentContract.createComment()
            
        } else {
            comment = new PageComment();
            commentByNFT[_nft] = comment;
        };
        comment.createComment
    }
    */
    // using EnumerableSet for EnumerableSet.UintSet;
    // using Counters for Counters.Counter;
    // mapping(address => uint256) public tokenIdByNFTAddress;
    // mapping(uint256 => bool) public activatedCommentByTokenId;
    // function hasActivatedComments(_nftContract, _tokenID) {

    // }

    /*
    // NEW COMMENTS
    struct Comment {
        uint256 id;
        address author;
        string text;
        bool like;
    }
    event NewComment(uint256 id, address author, string text, bool like);
    mapping(uint256 => Comment) public commentsById;
    mapping(address => EnumerableSet.UintSet) private commentsIdsOf;
    uint256[] public commentsIds;
    Counters.Counter private _totalLikes;
    Counters.Counter private _totalDislikes;

    function createComment(
        address author,
        string memory text,
        bool like
    ) public onlyOwner {
        uint256 id = commentsIds.length;
        commentsIdsOf[author].add(id);
        commentsIds.push(id);
        commentsById[id] = Comment(id, author, text, like);

        emit NewComment(id, author, text, like);

        _incrementStatistic(like);
    }

    function getCommentsIds() public view returns (uint256[] memory) {
        return commentsIds;
    }

    function getCommentsByIds(uint256[] memory _ids)
        public
        view
        returns (
            uint256[] memory,
            address[] memory,
            string[] memory,
            bool[] memory
        )
    {
        require(_ids.length > 0, "_ids length must be more than zero");
        require(
            _ids.length <= commentsIds.length,
            "_ids length must be less or equal commentsIds"
        );
        uint256[] memory ids = new uint256[](_ids.length);
        address[] memory authors = new address[](_ids.length);
        string[] memory texts = new string[](_ids.length);
        bool[] memory likes = new bool[](_ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            require(_ids[i] <= commentsIds.length, "No comment with this ID");
            Comment storage comment = commentsById[_ids[i]];
            ids[i] = comment.id;
            authors[i] = comment.author;
            texts[i] = comment.text;
            likes[i] = comment.like;
        }
        return (ids, authors, texts, likes);
    }

    function getComments()
        public
        view
        returns (
            uint256[] memory,
            address[] memory,
            string[] memory,
            bool[] memory
        )
    {
        return getCommentsByIds(commentsIds);
    }

    function getCommentById(uint256 id)
        public
        view
        returns (
            uint256,
            address,
            string memory,
            bool
        )
    {
        require(id <= commentsIds.length, "No comment with this ID");
        return (
            commentsById[id].id,
            commentsById[id].author,
            commentsById[id].text,
            commentsById[id].like
        );
    }

    function getStatistic()
        public
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes
        )
    {
        total = commentsIds.length;
        likes = _totalLikes.current();
        dislikes = _totalDislikes.current();
    }

    function _incrementStatistic(bool like) private {
        if (like) {
            _totalLikes.increment();
        } else {
            _totalDislikes.increment();
        }
    }
    */
}
