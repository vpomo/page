// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/INFTMINT.sol";
import "./interfaces/IMINTER.sol";
import "./interfaces/IERCMINT.sol";

contract PageNFTMarket {
    INFTMINT public PAGE_NFT;
    IMINTER public PAGE_MINTER;
    IERCMINT public PAGE_TOKEN;

    constructor(address _PAGE_NFT, address _PAGE_MINTER) {
        PAGE_NFT = INFTMINT(_PAGE_NFT);
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
    }
    // DEPOSIT
}

interface IBeacon {
    function childImplementation() external view returns (address);

    function upgradeChildTo(address newImplementation) external;
}

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
        // +
    }
}

contract BeaconProxy is Proxy {
    bytes32 private constant _BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) payable {
        assert(
            _BEACON_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1)
        );
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {
        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation()
        internal
        view
        virtual
        override
        returns (address)
    {
        return IBeacon(_beacon()).childImplementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {
        /*
        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).childImplementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        */
        bytes32 slot = _BEACON_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            // Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}
