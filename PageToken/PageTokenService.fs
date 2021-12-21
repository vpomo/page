namespace CryptoPage.Contracts.PageToken

open System
open System.Threading.Tasks
open System.Collections.Generic
open System.Numerics
open Nethereum.Hex.HexTypes
open Nethereum.ABI.FunctionEncoding.Attributes
open Nethereum.Web3
open Nethereum.RPC.Eth.DTOs
open Nethereum.Contracts.CQS
open Nethereum.Contracts.ContractHandlers
open Nethereum.Contracts
open System.Threading
open CryptoPage.Contracts.PageToken.ContractDefinition


    type PageTokenService (web3: Web3, contractAddress: string) =
    
        member val Web3 = web3 with get
        member val ContractHandler = web3.Eth.GetContractHandler(contractAddress) with get
    
        static member DeployContractAndWaitForReceiptAsync(web3: Web3, pageTokenDeployment: PageTokenDeployment, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> = 
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            web3.Eth.GetContractDeploymentHandler<PageTokenDeployment>().SendRequestAndWaitForReceiptAsync(pageTokenDeployment, cancellationTokenSourceVal)
        
        static member DeployContractAsync(web3: Web3, pageTokenDeployment: PageTokenDeployment): Task<string> =
            web3.Eth.GetContractDeploymentHandler<PageTokenDeployment>().SendRequestAsync(pageTokenDeployment)
        
        static member DeployContractAndGetServiceAsync(web3: Web3, pageTokenDeployment: PageTokenDeployment, ?cancellationTokenSource : CancellationTokenSource) = async {
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            let! receipt = PageTokenService.DeployContractAndWaitForReceiptAsync(web3, pageTokenDeployment, cancellationTokenSourceVal) |> Async.AwaitTask
            return new PageTokenService(web3, receipt.ContractAddress);
            }
    
        member this.DEFAULT_ADMIN_ROLEQueryAsync(dEFAULT_ADMIN_ROLEFunction: DEFAULT_ADMIN_ROLEFunction, ?blockParameter: BlockParameter): Task<byte[]> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<DEFAULT_ADMIN_ROLEFunction, byte[]>(dEFAULT_ADMIN_ROLEFunction, blockParameterVal)
            
        member this.AllowanceQueryAsync(allowanceFunction: AllowanceFunction, ?blockParameter: BlockParameter): Task<BigInteger> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<AllowanceFunction, BigInteger>(allowanceFunction, blockParameterVal)
            
        member this.ApproveRequestAsync(approveFunction: ApproveFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(approveFunction);
        
        member this.ApproveRequestAndWaitForReceiptAsync(approveFunction: ApproveFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(approveFunction, cancellationTokenSourceVal);
        
        member this.BalanceOfQueryAsync(balanceOfFunction: BalanceOfFunction, ?blockParameter: BlockParameter): Task<BigInteger> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameterVal)
            
        member this.BurnRequestAsync(burnFunction: BurnFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(burnFunction);
        
        member this.BurnRequestAndWaitForReceiptAsync(burnFunction: BurnFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationTokenSourceVal);
        
        member this.DecimalsQueryAsync(decimalsFunction: DecimalsFunction, ?blockParameter: BlockParameter): Task<byte> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<DecimalsFunction, byte>(decimalsFunction, blockParameterVal)
            
        member this.DecreaseAllowanceRequestAsync(decreaseAllowanceFunction: DecreaseAllowanceFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(decreaseAllowanceFunction);
        
        member this.DecreaseAllowanceRequestAndWaitForReceiptAsync(decreaseAllowanceFunction: DecreaseAllowanceFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(decreaseAllowanceFunction, cancellationTokenSourceVal);
        
        member this.GetRoleAdminQueryAsync(getRoleAdminFunction: GetRoleAdminFunction, ?blockParameter: BlockParameter): Task<byte[]> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<GetRoleAdminFunction, byte[]>(getRoleAdminFunction, blockParameterVal)
            
        member this.GetUSDTPAGEPriceQueryAsync(getUSDTPAGEPriceFunction: GetUSDTPAGEPriceFunction, ?blockParameter: BlockParameter): Task<BigInteger> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<GetUSDTPAGEPriceFunction, BigInteger>(getUSDTPAGEPriceFunction, blockParameterVal)
            
        member this.GetWETHUSDTPriceQueryAsync(getWETHUSDTPriceFunction: GetWETHUSDTPriceFunction, ?blockParameter: BlockParameter): Task<BigInteger> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<GetWETHUSDTPriceFunction, BigInteger>(getWETHUSDTPriceFunction, blockParameterVal)
            
        member this.GrantRoleRequestAsync(grantRoleFunction: GrantRoleFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(grantRoleFunction);
        
        member this.GrantRoleRequestAndWaitForReceiptAsync(grantRoleFunction: GrantRoleFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(grantRoleFunction, cancellationTokenSourceVal);
        
        member this.HasRoleQueryAsync(hasRoleFunction: HasRoleFunction, ?blockParameter: BlockParameter): Task<bool> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<HasRoleFunction, bool>(hasRoleFunction, blockParameterVal)
            
        member this.IncreaseAllowanceRequestAsync(increaseAllowanceFunction: IncreaseAllowanceFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(increaseAllowanceFunction);
        
        member this.IncreaseAllowanceRequestAndWaitForReceiptAsync(increaseAllowanceFunction: IncreaseAllowanceFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(increaseAllowanceFunction, cancellationTokenSourceVal);
        
        member this.MintRequestAsync(mintFunction: MintFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(mintFunction);
        
        member this.MintRequestAndWaitForReceiptAsync(mintFunction: MintFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(mintFunction, cancellationTokenSourceVal);
        
        member this.NameQueryAsync(nameFunction: NameFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<NameFunction, string>(nameFunction, blockParameterVal)
            
        member this.OwnerQueryAsync(ownerFunction: OwnerFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<OwnerFunction, string>(ownerFunction, blockParameterVal)
            
        member this.RenounceOwnershipRequestAsync(renounceOwnershipFunction: RenounceOwnershipFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(renounceOwnershipFunction);
        
        member this.RenounceOwnershipRequestAndWaitForReceiptAsync(renounceOwnershipFunction: RenounceOwnershipFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(renounceOwnershipFunction, cancellationTokenSourceVal);
        
        member this.RenounceRoleRequestAsync(renounceRoleFunction: RenounceRoleFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(renounceRoleFunction);
        
        member this.RenounceRoleRequestAndWaitForReceiptAsync(renounceRoleFunction: RenounceRoleFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(renounceRoleFunction, cancellationTokenSourceVal);
        
        member this.RevokeRoleRequestAsync(revokeRoleFunction: RevokeRoleFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(revokeRoleFunction);
        
        member this.RevokeRoleRequestAndWaitForReceiptAsync(revokeRoleFunction: RevokeRoleFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(revokeRoleFunction, cancellationTokenSourceVal);
        
        member this.SetUSDTPAGEPoolRequestAsync(setUSDTPAGEPoolFunction: SetUSDTPAGEPoolFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(setUSDTPAGEPoolFunction);
        
        member this.SetUSDTPAGEPoolRequestAndWaitForReceiptAsync(setUSDTPAGEPoolFunction: SetUSDTPAGEPoolFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(setUSDTPAGEPoolFunction, cancellationTokenSourceVal);
        
        member this.SetWETHUSDTPoolRequestAsync(setWETHUSDTPoolFunction: SetWETHUSDTPoolFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(setWETHUSDTPoolFunction);
        
        member this.SetWETHUSDTPoolRequestAndWaitForReceiptAsync(setWETHUSDTPoolFunction: SetWETHUSDTPoolFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(setWETHUSDTPoolFunction, cancellationTokenSourceVal);
        
        member this.SupportsInterfaceQueryAsync(supportsInterfaceFunction: SupportsInterfaceFunction, ?blockParameter: BlockParameter): Task<bool> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameterVal)
            
        member this.SymbolQueryAsync(symbolFunction: SymbolFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<SymbolFunction, string>(symbolFunction, blockParameterVal)
            
        member this.TotalSupplyQueryAsync(totalSupplyFunction: TotalSupplyFunction, ?blockParameter: BlockParameter): Task<BigInteger> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(totalSupplyFunction, blockParameterVal)
            
        member this.TransferRequestAsync(transferFunction: TransferFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(transferFunction);
        
        member this.TransferRequestAndWaitForReceiptAsync(transferFunction: TransferFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(transferFunction, cancellationTokenSourceVal);
        
        member this.TransferFromRequestAsync(transferFromFunction: TransferFromFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(transferFromFunction);
        
        member this.TransferFromRequestAndWaitForReceiptAsync(transferFromFunction: TransferFromFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(transferFromFunction, cancellationTokenSourceVal);
        
        member this.TransferOwnershipRequestAsync(transferOwnershipFunction: TransferOwnershipFunction): Task<string> =
            this.ContractHandler.SendRequestAsync(transferOwnershipFunction);
        
        member this.TransferOwnershipRequestAndWaitForReceiptAsync(transferOwnershipFunction: TransferOwnershipFunction, ?cancellationTokenSource : CancellationTokenSource): Task<TransactionReceipt> =
            let cancellationTokenSourceVal = defaultArg cancellationTokenSource null
            this.ContractHandler.SendRequestAndWaitForReceiptAsync(transferOwnershipFunction, cancellationTokenSourceVal);
        
        member this.UsdtpagePoolQueryAsync(usdtpagePoolFunction: UsdtpagePoolFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<UsdtpagePoolFunction, string>(usdtpagePoolFunction, blockParameterVal)
            
        member this.WethusdtPoolQueryAsync(wethusdtPoolFunction: WethusdtPoolFunction, ?blockParameter: BlockParameter): Task<string> =
            let blockParameterVal = defaultArg blockParameter null
            this.ContractHandler.QueryAsync<WethusdtPoolFunction, string>(wethusdtPoolFunction, blockParameterVal)
            
    

