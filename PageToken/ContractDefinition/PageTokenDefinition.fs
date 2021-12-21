namespace CryptoPage.Contracts.PageToken.ContractDefinition

open System
open System.Threading.Tasks
open System.Collections.Generic
open System.Numerics
open Nethereum.Hex.HexTypes
open Nethereum.ABI.FunctionEncoding.Attributes
open Nethereum.Web3
open Nethereum.RPC.Eth.DTOs
open Nethereum.Contracts.CQS
open Nethereum.Contracts
open System.Threading

    
    
    type PageTokenDeployment(byteCode: string) =
        inherit ContractDeploymentMessage(byteCode)
        
        static let BYTECODE = "60806040523480156200001157600080fd5b5060405162001d0038038062001d00833981016040819052620000349162000379565b604080518082018252600b81526a43727970746f2e5061676560a81b6020808301918252835180850190945260048452635041474560e01b9084015281519192916200008391600391620002d3565b50805162000099906004906020840190620002d3565b505050620000b6620000b0620000e160201b60201c565b620000e5565b620000c360003362000137565b620000da816a084595161401484a00000062000147565b506200040f565b3390565b600680546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b6200014382826200022f565b5050565b6001600160a01b038216620001a25760405162461bcd60e51b815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f206164647265737300604482015260640160405180910390fd5b8060026000828254620001b69190620003ab565b90915550506001600160a01b03821660009081526020819052604081208054839290620001e5908490620003ab565b90915550506040518181526001600160a01b038316906000907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9060200160405180910390a35050565b60008281526005602090815260408083206001600160a01b038516845290915290205460ff16620001435760008281526005602090815260408083206001600160a01b03851684529091529020805460ff191660011790556200028f3390565b6001600160a01b0316816001600160a01b0316837f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45050565b828054620002e190620003d2565b90600052602060002090601f01602090048101928262000305576000855562000350565b82601f106200032057805160ff191683800117855562000350565b8280016001018555821562000350579182015b828111156200035057825182559160200191906001019062000333565b506200035e92915062000362565b5090565b5b808211156200035e576000815560010162000363565b6000602082840312156200038c57600080fd5b81516001600160a01b0381168114620003a457600080fd5b9392505050565b60008219821115620003cd57634e487b7160e01b600052601160045260246000fd5b500190565b600181811c90821680620003e757607f821691505b602082108114156200040957634e487b7160e01b600052602260045260246000fd5b50919050565b6118e1806200041f6000396000f3fe608060405234801561001057600080fd5b50600436106101cf5760003560e01c80635bee559e116101045780639dc29fac116100a2578063d547741f11610071578063d547741f146103d3578063dc5c0eb1146103e6578063dd62ed3e146103ee578063f2fde38b1461042757600080fd5b80639dc29fac14610392578063a217fddf146103a5578063a457c2d7146103ad578063a9059cbb146103c057600080fd5b80638da5cb5b116100de5780638da5cb5b1461035357806391d148541461036457806395d89b41146103775780639c7b5b261461037f57600080fd5b80635bee559e1461030f57806370a0823114610322578063715018a61461034b57600080fd5b8063248a9ca31161017157806336568abe1161014b57806336568abe146102ce57806336ab348a146102e157806339509351146102e957806340c10f19146102fc57600080fd5b8063248a9ca3146102895780632f2ff15d146102ac578063313ce567146102bf57600080fd5b80630bbffd1b116101ad5780630bbffd1b1461022457806318160ddd1461024f57806323b872dd1461026157806323c2b41f1461027457600080fd5b806301ffc9a7146101d457806306fdde03146101fc578063095ea7b314610211575b600080fd5b6101e76101e236600461135a565b61043a565b60405190151581526020015b60405180910390f35b610204610471565b6040516101f391906113b0565b6101e761021f3660046113f8565b610503565b600754610237906001600160a01b031681565b6040516001600160a01b0390911681526020016101f3565b6002545b6040519081526020016101f3565b6101e761026f366004611424565b610519565b610287610282366004611465565b6105c8565b005b610253610297366004611482565b60009081526005602052604090206001015490565b6102876102ba36600461149b565b610614565b604051601281526020016101f3565b6102876102dc36600461149b565b61063f565b6102536106bd565b6101e76102f73660046113f8565b61077a565b61028761030a3660046113f8565b6107b6565b600854610237906001600160a01b031681565b610253610330366004611465565b6001600160a01b031660009081526020819052604090205490565b6102876107eb565b6006546001600160a01b0316610237565b6101e761037236600461149b565b610821565b61020461084c565b61028761038d366004611465565b61085b565b6102876103a03660046113f8565b6108a7565b610253600081565b6101e76103bb3660046113f8565b6108dc565b6101e76103ce3660046113f8565b610975565b6102876103e136600461149b565b610982565b6102536109a8565b6102536103fc3660046114cb565b6001600160a01b03918216600090815260016020908152604080832093909416825291909152205490565b610287610435366004611465565b610a58565b60006001600160e01b03198216637965db0b60e01b148061046b57506301ffc9a760e01b6001600160e01b03198316145b92915050565b606060038054610480906114f9565b80601f01602080910402602001604051908101604052809291908181526020018280546104ac906114f9565b80156104f95780601f106104ce576101008083540402835291602001916104f9565b820191906000526020600020905b8154815290600101906020018083116104dc57829003601f168201915b5050505050905090565b6000610510338484610af3565b50600192915050565b6000610526848484610c17565b6001600160a01b0384166000908152600160209081526040808320338452909152902054828110156105b05760405162461bcd60e51b815260206004820152602860248201527f45524332303a207472616e7366657220616d6f756e74206578636565647320616044820152676c6c6f77616e636560c01b60648201526084015b60405180910390fd5b6105bd8533858403610af3565b506001949350505050565b6006546001600160a01b031633146105f25760405162461bcd60e51b81526004016105a790611534565b600880546001600160a01b0319166001600160a01b0392909216919091179055565b6000828152600560205260409020600101546106308133610de7565b61063a8383610e4b565b505050565b6001600160a01b03811633146106af5760405162461bcd60e51b815260206004820152602f60248201527f416363657373436f6e74726f6c3a2063616e206f6e6c792072656e6f756e636560448201526e103937b632b9903337b91039b2b63360891b60648201526084016105a7565b6106b98282610ed1565b5050565b600080600760009054906101000a90046001600160a01b03166001600160a01b0316633850c7bd6040518163ffffffff1660e01b815260040160e060405180830381865afa158015610713573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906107379190611580565b505050505050905060006002600160601b83610753919061163a565b61075d919061178d565b6001600160a01b03169050606481111561046b5750606492915050565b3360008181526001602090815260408083206001600160a01b038716845290915281205490916105109185906107b19086906117a5565b610af3565b7f9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a66107e18133610de7565b61063a8383610f38565b6006546001600160a01b031633146108155760405162461bcd60e51b81526004016105a790611534565b61081f6000611017565b565b60009182526005602090815260408084206001600160a01b0393909316845291905290205460ff1690565b606060048054610480906114f9565b6006546001600160a01b031633146108855760405162461bcd60e51b81526004016105a790611534565b600780546001600160a01b0319166001600160a01b0392909216919091179055565b7f3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a8486108d28133610de7565b61063a8383611069565b3360009081526001602090815260408083206001600160a01b03861684529091528120548281101561095e5760405162461bcd60e51b815260206004820152602560248201527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f77604482015264207a65726f60d81b60648201526084016105a7565b61096b3385858403610af3565b5060019392505050565b6000610510338484610c17565b60008281526005602052604090206001015461099e8133610de7565b61063a8383610ed1565b600080600860009054906101000a90046001600160a01b03166001600160a01b0316633850c7bd6040518163ffffffff1660e01b815260040160e060405180830381865afa1580156109fe573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610a229190611580565b505050505050905060006002600160601b83610a3e919061163a565b610a48919061178d565b6001600160a01b03169392505050565b6006546001600160a01b03163314610a825760405162461bcd60e51b81526004016105a790611534565b6001600160a01b038116610ae75760405162461bcd60e51b815260206004820152602660248201527f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160448201526564647265737360d01b60648201526084016105a7565b610af081611017565b50565b6001600160a01b038316610b555760405162461bcd60e51b8152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f206164646044820152637265737360e01b60648201526084016105a7565b6001600160a01b038216610bb65760405162461bcd60e51b815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f206164647265604482015261737360f01b60648201526084016105a7565b6001600160a01b0383811660008181526001602090815260408083209487168084529482529182902085905590518481527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925910160405180910390a3505050565b6001600160a01b038316610c7b5760405162461bcd60e51b815260206004820152602560248201527f45524332303a207472616e736665722066726f6d20746865207a65726f206164604482015264647265737360d81b60648201526084016105a7565b6001600160a01b038216610cdd5760405162461bcd60e51b815260206004820152602360248201527f45524332303a207472616e7366657220746f20746865207a65726f206164647260448201526265737360e81b60648201526084016105a7565b6001600160a01b03831660009081526020819052604090205481811015610d555760405162461bcd60e51b815260206004820152602660248201527f45524332303a207472616e7366657220616d6f756e7420657863656564732062604482015265616c616e636560d01b60648201526084016105a7565b6001600160a01b03808516600090815260208190526040808220858503905591851681529081208054849290610d8c9084906117a5565b92505081905550826001600160a01b0316846001600160a01b03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef84604051610dd891815260200190565b60405180910390a35b50505050565b610df18282610821565b6106b957610e09816001600160a01b031660146111b7565b610e148360206111b7565b604051602001610e259291906117bd565b60408051601f198184030181529082905262461bcd60e51b82526105a7916004016113b0565b610e558282610821565b6106b95760008281526005602090815260408083206001600160a01b03851684529091529020805460ff19166001179055610e8d3390565b6001600160a01b0316816001600160a01b0316837f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45050565b610edb8282610821565b156106b95760008281526005602090815260408083206001600160a01b0385168085529252808320805460ff1916905551339285917ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b9190a45050565b6001600160a01b038216610f8e5760405162461bcd60e51b815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f20616464726573730060448201526064016105a7565b8060026000828254610fa091906117a5565b90915550506001600160a01b03821660009081526020819052604081208054839290610fcd9084906117a5565b90915550506040518181526001600160a01b038316906000907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9060200160405180910390a35050565b600680546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b6001600160a01b0382166110c95760405162461bcd60e51b815260206004820152602160248201527f45524332303a206275726e2066726f6d20746865207a65726f206164647265736044820152607360f81b60648201526084016105a7565b6001600160a01b0382166000908152602081905260409020548181101561113d5760405162461bcd60e51b815260206004820152602260248201527f45524332303a206275726e20616d6f756e7420657863656564732062616c616e604482015261636560f01b60648201526084016105a7565b6001600160a01b038316600090815260208190526040812083830390556002805484929061116c908490611832565b90915550506040518281526000906001600160a01b038516907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9060200160405180910390a3505050565b606060006111c6836002611849565b6111d19060026117a5565b67ffffffffffffffff8111156111e9576111e9611868565b6040519080825280601f01601f191660200182016040528015611213576020820181803683370190505b509050600360fc1b8160008151811061122e5761122e61187e565b60200101906001600160f81b031916908160001a905350600f60fb1b8160018151811061125d5761125d61187e565b60200101906001600160f81b031916908160001a9053506000611281846002611849565b61128c9060016117a5565b90505b6001811115611304576f181899199a1a9b1b9c1cb0b131b232b360811b85600f16601081106112c0576112c061187e565b1a60f81b8282815181106112d6576112d661187e565b60200101906001600160f81b031916908160001a90535060049490941c936112fd81611894565b905061128f565b5083156113535760405162461bcd60e51b815260206004820181905260248201527f537472696e67733a20686578206c656e67746820696e73756666696369656e7460448201526064016105a7565b9392505050565b60006020828403121561136c57600080fd5b81356001600160e01b03198116811461135357600080fd5b60005b8381101561139f578181015183820152602001611387565b83811115610de15750506000910152565b60208152600082518060208401526113cf816040850160208701611384565b601f01601f19169190910160400192915050565b6001600160a01b0381168114610af057600080fd5b6000806040838503121561140b57600080fd5b8235611416816113e3565b946020939093013593505050565b60008060006060848603121561143957600080fd5b8335611444816113e3565b92506020840135611454816113e3565b929592945050506040919091013590565b60006020828403121561147757600080fd5b8135611353816113e3565b60006020828403121561149457600080fd5b5035919050565b600080604083850312156114ae57600080fd5b8235915060208301356114c0816113e3565b809150509250929050565b600080604083850312156114de57600080fd5b82356114e9816113e3565b915060208301356114c0816113e3565b600181811c9082168061150d57607f821691505b6020821081141561152e57634e487b7160e01b600052602260045260246000fd5b50919050565b6020808252818101527f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572604082015260600190565b805161ffff8116811461157b57600080fd5b919050565b600080600080600080600060e0888a03121561159b57600080fd5b87516115a6816113e3565b8097505060208801518060020b81146115be57600080fd5b95506115cc60408901611569565b94506115da60608901611569565b93506115e860808901611569565b925060a088015160ff811681146115fe57600080fd5b60c0890151909250801515811461161457600080fd5b8091505092959891949750929550565b634e487b7160e01b600052601160045260246000fd5b60006001600160a01b038381168061166257634e487b7160e01b600052601260045260246000fd5b92169190910492915050565b600181815b808511156116af576001600160a01b0382900482111561169557611695611624565b808516156116a257918102915b93841c9390800290611673565b509250929050565b6000826116c65750600161046b565b816116d35750600061046b565b81600181146116e957600281146116f357611727565b600191505061046b565b60ff84111561170457611704611624565b6001841b91506001600160a01b0382111561172157611721611624565b5061046b565b5060208310610133831016604e8410600b8410161715611761575081810a6001600160a01b0381111561175c5761175c611624565b61046b565b61176b838361166e565b6001600160a01b0381900482111561178557611785611624565b029392505050565b600061135360ff84166001600160a01b0384166116b7565b600082198211156117b8576117b8611624565b500190565b7f416363657373436f6e74726f6c3a206163636f756e74200000000000000000008152600083516117f5816017850160208801611384565b7001034b99036b4b9b9b4b733903937b6329607d1b6017918401918201528351611826816028840160208801611384565b01602801949350505050565b60008282101561184457611844611624565b500390565b600081600019048311821515161561186357611863611624565b500290565b634e487b7160e01b600052604160045260246000fd5b634e487b7160e01b600052603260045260246000fd5b6000816118a3576118a3611624565b50600019019056fea2646970667358221220be887d9a6d7bcfbfc2c1f733f36c35a96f61bce94399fafbd749b03e209a923564736f6c634300080a0033"
        
        new() = PageTokenDeployment(BYTECODE)
        
            [<Parameter("address", "_treasury", 1)>]
            member val public Treasury = Unchecked.defaultof<string> with get, set
        
    
    [<Function("DEFAULT_ADMIN_ROLE", "bytes32")>]
    type DEFAULT_ADMIN_ROLEFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("allowance", "uint256")>]
    type AllowanceFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "owner", 1)>]
            member val public Owner = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "spender", 2)>]
            member val public Spender = Unchecked.defaultof<string> with get, set
        
    
    [<Function("approve", "bool")>]
    type ApproveFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "spender", 1)>]
            member val public Spender = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "amount", 2)>]
            member val public Amount = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("balanceOf", "uint256")>]
    type BalanceOfFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "account", 1)>]
            member val public Account = Unchecked.defaultof<string> with get, set
        
    
    [<Function("burn")>]
    type BurnFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "to", 1)>]
            member val public To = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "amount", 2)>]
            member val public Amount = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("decimals", "uint8")>]
    type DecimalsFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("decreaseAllowance", "bool")>]
    type DecreaseAllowanceFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "spender", 1)>]
            member val public Spender = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "subtractedValue", 2)>]
            member val public SubtractedValue = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("getRoleAdmin", "bytes32")>]
    type GetRoleAdminFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "role", 1)>]
            member val public Role = Unchecked.defaultof<byte[]> with get, set
        
    
    [<Function("getUSDTPAGEPrice", "uint256")>]
    type GetUSDTPAGEPriceFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("getWETHUSDTPrice", "uint256")>]
    type GetWETHUSDTPriceFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("grantRole")>]
    type GrantRoleFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "role", 1)>]
            member val public Role = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("address", "account", 2)>]
            member val public Account = Unchecked.defaultof<string> with get, set
        
    
    [<Function("hasRole", "bool")>]
    type HasRoleFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "role", 1)>]
            member val public Role = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("address", "account", 2)>]
            member val public Account = Unchecked.defaultof<string> with get, set
        
    
    [<Function("increaseAllowance", "bool")>]
    type IncreaseAllowanceFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "spender", 1)>]
            member val public Spender = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "addedValue", 2)>]
            member val public AddedValue = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("mint")>]
    type MintFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "to", 1)>]
            member val public To = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "amount", 2)>]
            member val public Amount = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("name", "string")>]
    type NameFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("owner", "address")>]
    type OwnerFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("renounceOwnership")>]
    type RenounceOwnershipFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("renounceRole")>]
    type RenounceRoleFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "role", 1)>]
            member val public Role = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("address", "account", 2)>]
            member val public Account = Unchecked.defaultof<string> with get, set
        
    
    [<Function("revokeRole")>]
    type RevokeRoleFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes32", "role", 1)>]
            member val public Role = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("address", "account", 2)>]
            member val public Account = Unchecked.defaultof<string> with get, set
        
    
    [<Function("setUSDTPAGEPool")>]
    type SetUSDTPAGEPoolFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "_usdtPool", 1)>]
            member val public UsdtPool = Unchecked.defaultof<string> with get, set
        
    
    [<Function("setWETHUSDTPool")>]
    type SetWETHUSDTPoolFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "_wethPool", 1)>]
            member val public WethPool = Unchecked.defaultof<string> with get, set
        
    
    [<Function("supportsInterface", "bool")>]
    type SupportsInterfaceFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("bytes4", "interfaceId", 1)>]
            member val public InterfaceId = Unchecked.defaultof<byte[]> with get, set
        
    
    [<Function("symbol", "string")>]
    type SymbolFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("totalSupply", "uint256")>]
    type TotalSupplyFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("transfer", "bool")>]
    type TransferFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "recipient", 1)>]
            member val public Recipient = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "amount", 2)>]
            member val public Amount = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("transferFrom", "bool")>]
    type TransferFromFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "sender", 1)>]
            member val public Sender = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "recipient", 2)>]
            member val public Recipient = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "amount", 3)>]
            member val public Amount = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Function("transferOwnership")>]
    type TransferOwnershipFunction() = 
        inherit FunctionMessage()
    
            [<Parameter("address", "newOwner", 1)>]
            member val public NewOwner = Unchecked.defaultof<string> with get, set
        
    
    [<Function("usdtpagePool", "address")>]
    type UsdtpagePoolFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Function("wethusdtPool", "address")>]
    type WethusdtPoolFunction() = 
        inherit FunctionMessage()
    

        
    
    [<Event("Approval")>]
    type ApprovalEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "owner", 1, true )>]
            member val Owner = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "spender", 2, true )>]
            member val Spender = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "value", 3, false )>]
            member val Value = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<Event("OwnershipTransferred")>]
    type OwnershipTransferredEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "previousOwner", 1, true )>]
            member val PreviousOwner = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "newOwner", 2, true )>]
            member val NewOwner = Unchecked.defaultof<string> with get, set
        
    
    [<Event("RoleAdminChanged")>]
    type RoleAdminChangedEventDTO() =
        inherit EventDTO()
            [<Parameter("bytes32", "role", 1, true )>]
            member val Role = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("bytes32", "previousAdminRole", 2, true )>]
            member val PreviousAdminRole = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("bytes32", "newAdminRole", 3, true )>]
            member val NewAdminRole = Unchecked.defaultof<byte[]> with get, set
        
    
    [<Event("RoleGranted")>]
    type RoleGrantedEventDTO() =
        inherit EventDTO()
            [<Parameter("bytes32", "role", 1, true )>]
            member val Role = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("address", "account", 2, true )>]
            member val Account = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "sender", 3, true )>]
            member val Sender = Unchecked.defaultof<string> with get, set
        
    
    [<Event("RoleRevoked")>]
    type RoleRevokedEventDTO() =
        inherit EventDTO()
            [<Parameter("bytes32", "role", 1, true )>]
            member val Role = Unchecked.defaultof<byte[]> with get, set
            [<Parameter("address", "account", 2, true )>]
            member val Account = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "sender", 3, true )>]
            member val Sender = Unchecked.defaultof<string> with get, set
        
    
    [<Event("Transfer")>]
    type TransferEventDTO() =
        inherit EventDTO()
            [<Parameter("address", "from", 1, true )>]
            member val From = Unchecked.defaultof<string> with get, set
            [<Parameter("address", "to", 2, true )>]
            member val To = Unchecked.defaultof<string> with get, set
            [<Parameter("uint256", "value", 3, false )>]
            member val Value = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<FunctionOutput>]
    type DEFAULT_ADMIN_ROLEOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bytes32", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<byte[]> with get, set
        
    
    [<FunctionOutput>]
    type AllowanceOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint256", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<BigInteger> with get, set
        
    
    
    
    [<FunctionOutput>]
    type BalanceOfOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint256", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<BigInteger> with get, set
        
    
    
    
    [<FunctionOutput>]
    type DecimalsOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint8", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<byte> with get, set
        
    
    
    
    [<FunctionOutput>]
    type GetRoleAdminOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bytes32", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<byte[]> with get, set
        
    
    [<FunctionOutput>]
    type GetUSDTPAGEPriceOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint256", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<BigInteger> with get, set
        
    
    [<FunctionOutput>]
    type GetWETHUSDTPriceOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint256", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<BigInteger> with get, set
        
    
    
    
    [<FunctionOutput>]
    type HasRoleOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bool", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<bool> with get, set
        
    
    
    
    
    
    [<FunctionOutput>]
    type NameOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("string", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
        
    
    [<FunctionOutput>]
    type OwnerOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("address", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
        
    
    
    
    
    
    
    
    
    
    
    
    [<FunctionOutput>]
    type SupportsInterfaceOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("bool", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<bool> with get, set
        
    
    [<FunctionOutput>]
    type SymbolOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("string", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
        
    
    [<FunctionOutput>]
    type TotalSupplyOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("uint256", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<BigInteger> with get, set
        
    
    
    
    
    
    
    
    [<FunctionOutput>]
    type UsdtpagePoolOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("address", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
        
    
    [<FunctionOutput>]
    type WethusdtPoolOutputDTO() =
        inherit FunctionOutputDTO() 
            [<Parameter("address", "", 1)>]
            member val public ReturnValue1 = Unchecked.defaultof<string> with get, set
    

