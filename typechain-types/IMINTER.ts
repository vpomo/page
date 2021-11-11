/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import {
    ethers,
    EventFilter,
    Signer,
    BigNumber,
    BigNumberish,
    PopulatedTransaction,
    BaseContract,
    ContractTransaction,
    Overrides,
    CallOverrides,
} from "ethers";
import { BytesLike } from "@ethersproject/bytes";
import { Listener, Provider } from "@ethersproject/providers";
import { FunctionFragment, EventFragment, Result } from "@ethersproject/abi";
import type {
    TypedEventFilter,
    TypedEvent,
    TypedListener,
    OnEvent,
} from "./common";

export interface IMINTERInterface extends ethers.utils.Interface {
    functions: {
        "amountMint(string,uint256)": FunctionFragment;
        "burn(address,uint256)": FunctionFragment;
        "getAdmin()": FunctionFragment;
        "getBurnNFTCost()": FunctionFragment;
        "getMinter(string)": FunctionFragment;
        "getPageToken()": FunctionFragment;
        "mint(string,address[])": FunctionFragment;
        "mint1(string,address)": FunctionFragment;
        "mint2(string,address,address)": FunctionFragment;
        "mint3(string,address,address,address)": FunctionFragment;
        "mintX(string,address[],uint256)": FunctionFragment;
        "removeMinter(string)": FunctionFragment;
        "setBurnNFTCost(uint256)": FunctionFragment;
        "setMinter(string,address,uint256,bool)": FunctionFragment;
    };

    encodeFunctionData(
        functionFragment: "amountMint",
        values: [string, BigNumberish]
    ): string;
    encodeFunctionData(
        functionFragment: "burn",
        values: [string, BigNumberish]
    ): string;
    encodeFunctionData(
        functionFragment: "getAdmin",
        values?: undefined
    ): string;
    encodeFunctionData(
        functionFragment: "getBurnNFTCost",
        values?: undefined
    ): string;
    encodeFunctionData(functionFragment: "getMinter", values: [string]): string;
    encodeFunctionData(
        functionFragment: "getPageToken",
        values?: undefined
    ): string;
    encodeFunctionData(
        functionFragment: "mint",
        values: [string, string[]]
    ): string;
    encodeFunctionData(
        functionFragment: "mint1",
        values: [string, string]
    ): string;
    encodeFunctionData(
        functionFragment: "mint2",
        values: [string, string, string]
    ): string;
    encodeFunctionData(
        functionFragment: "mint3",
        values: [string, string, string, string]
    ): string;
    encodeFunctionData(
        functionFragment: "mintX",
        values: [string, string[], BigNumberish]
    ): string;
    encodeFunctionData(
        functionFragment: "removeMinter",
        values: [string]
    ): string;
    encodeFunctionData(
        functionFragment: "setBurnNFTCost",
        values: [BigNumberish]
    ): string;
    encodeFunctionData(
        functionFragment: "setMinter",
        values: [string, string, BigNumberish, boolean]
    ): string;

    decodeFunctionResult(
        functionFragment: "amountMint",
        data: BytesLike
    ): Result;
    decodeFunctionResult(functionFragment: "burn", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "getAdmin", data: BytesLike): Result;
    decodeFunctionResult(
        functionFragment: "getBurnNFTCost",
        data: BytesLike
    ): Result;
    decodeFunctionResult(
        functionFragment: "getMinter",
        data: BytesLike
    ): Result;
    decodeFunctionResult(
        functionFragment: "getPageToken",
        data: BytesLike
    ): Result;
    decodeFunctionResult(functionFragment: "mint", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "mint1", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "mint2", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "mint3", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "mintX", data: BytesLike): Result;
    decodeFunctionResult(
        functionFragment: "removeMinter",
        data: BytesLike
    ): Result;
    decodeFunctionResult(
        functionFragment: "setBurnNFTCost",
        data: BytesLike
    ): Result;
    decodeFunctionResult(
        functionFragment: "setMinter",
        data: BytesLike
    ): Result;

    events: {};
}

export interface IMINTER extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;

    interface: IMINTERInterface;

    queryFilter<TEvent extends TypedEvent>(
        event: TypedEventFilter<TEvent>,
        fromBlockOrBlockhash?: string | number | undefined,
        toBlock?: string | number | undefined
    ): Promise<Array<TEvent>>;

    listeners<TEvent extends TypedEvent>(
        eventFilter?: TypedEventFilter<TEvent>
    ): Array<TypedListener<TEvent>>;
    listeners(eventName?: string): Array<Listener>;
    removeAllListeners<TEvent extends TypedEvent>(
        eventFilter: TypedEventFilter<TEvent>
    ): this;
    removeAllListeners(eventName?: string): this;
    off: OnEvent<this>;
    on: OnEvent<this>;
    once: OnEvent<this>;
    removeListener: OnEvent<this>;

    functions: {
        amountMint(
            _key: string,
            _addressCount: BigNumberish,
            overrides?: CallOverrides
        ): Promise<
            [BigNumber, BigNumber] & { amountEach: BigNumber; fee: BigNumber }
        >;

        burn(
            from: string,
            amount: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        getAdmin(overrides?: CallOverrides): Promise<[string]>;

        getBurnNFTCost(overrides?: CallOverrides): Promise<[BigNumber]>;

        getMinter(
            _key: string,
            overrides?: CallOverrides
        ): Promise<
            [BigNumber, string, BigNumber, boolean] & {
                id: BigNumber;
                author: string;
                amount: BigNumber;
                xmint: boolean;
            }
        >;

        getPageToken(overrides?: CallOverrides): Promise<[string]>;

        mint(
            _key: string,
            _to: string[],
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        mint1(
            _key: string,
            _to: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        mint2(
            _key: string,
            _to1: string,
            _to2: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        mint3(
            _key: string,
            _to1: string,
            _to2: string,
            _to3: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        mintX(
            _key: string,
            _to: string[],
            _multiplier: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        removeMinter(
            _key: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        setBurnNFTCost(
            _cost: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;

        setMinter(
            _key: string,
            _account: string,
            _pageamount: BigNumberish,
            _xmint: boolean,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<ContractTransaction>;
    };

    amountMint(
        _key: string,
        _addressCount: BigNumberish,
        overrides?: CallOverrides
    ): Promise<
        [BigNumber, BigNumber] & { amountEach: BigNumber; fee: BigNumber }
    >;

    burn(
        from: string,
        amount: BigNumberish,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    getAdmin(overrides?: CallOverrides): Promise<string>;

    getBurnNFTCost(overrides?: CallOverrides): Promise<BigNumber>;

    getMinter(
        _key: string,
        overrides?: CallOverrides
    ): Promise<
        [BigNumber, string, BigNumber, boolean] & {
            id: BigNumber;
            author: string;
            amount: BigNumber;
            xmint: boolean;
        }
    >;

    getPageToken(overrides?: CallOverrides): Promise<string>;

    mint(
        _key: string,
        _to: string[],
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    mint1(
        _key: string,
        _to: string,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    mint2(
        _key: string,
        _to1: string,
        _to2: string,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    mint3(
        _key: string,
        _to1: string,
        _to2: string,
        _to3: string,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    mintX(
        _key: string,
        _to: string[],
        _multiplier: BigNumberish,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    removeMinter(
        _key: string,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    setBurnNFTCost(
        _cost: BigNumberish,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    setMinter(
        _key: string,
        _account: string,
        _pageamount: BigNumberish,
        _xmint: boolean,
        overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    callStatic: {
        amountMint(
            _key: string,
            _addressCount: BigNumberish,
            overrides?: CallOverrides
        ): Promise<
            [BigNumber, BigNumber] & { amountEach: BigNumber; fee: BigNumber }
        >;

        burn(
            from: string,
            amount: BigNumberish,
            overrides?: CallOverrides
        ): Promise<void>;

        getAdmin(overrides?: CallOverrides): Promise<string>;

        getBurnNFTCost(overrides?: CallOverrides): Promise<BigNumber>;

        getMinter(
            _key: string,
            overrides?: CallOverrides
        ): Promise<
            [BigNumber, string, BigNumber, boolean] & {
                id: BigNumber;
                author: string;
                amount: BigNumber;
                xmint: boolean;
            }
        >;

        getPageToken(overrides?: CallOverrides): Promise<string>;

        mint(
            _key: string,
            _to: string[],
            overrides?: CallOverrides
        ): Promise<void>;

        mint1(
            _key: string,
            _to: string,
            overrides?: CallOverrides
        ): Promise<void>;

        mint2(
            _key: string,
            _to1: string,
            _to2: string,
            overrides?: CallOverrides
        ): Promise<void>;

        mint3(
            _key: string,
            _to1: string,
            _to2: string,
            _to3: string,
            overrides?: CallOverrides
        ): Promise<void>;

        mintX(
            _key: string,
            _to: string[],
            _multiplier: BigNumberish,
            overrides?: CallOverrides
        ): Promise<void>;

        removeMinter(_key: string, overrides?: CallOverrides): Promise<void>;

        setBurnNFTCost(
            _cost: BigNumberish,
            overrides?: CallOverrides
        ): Promise<void>;

        setMinter(
            _key: string,
            _account: string,
            _pageamount: BigNumberish,
            _xmint: boolean,
            overrides?: CallOverrides
        ): Promise<void>;
    };

    filters: {};

    estimateGas: {
        amountMint(
            _key: string,
            _addressCount: BigNumberish,
            overrides?: CallOverrides
        ): Promise<BigNumber>;

        burn(
            from: string,
            amount: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        getAdmin(overrides?: CallOverrides): Promise<BigNumber>;

        getBurnNFTCost(overrides?: CallOverrides): Promise<BigNumber>;

        getMinter(_key: string, overrides?: CallOverrides): Promise<BigNumber>;

        getPageToken(overrides?: CallOverrides): Promise<BigNumber>;

        mint(
            _key: string,
            _to: string[],
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        mint1(
            _key: string,
            _to: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        mint2(
            _key: string,
            _to1: string,
            _to2: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        mint3(
            _key: string,
            _to1: string,
            _to2: string,
            _to3: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        mintX(
            _key: string,
            _to: string[],
            _multiplier: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        removeMinter(
            _key: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        setBurnNFTCost(
            _cost: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;

        setMinter(
            _key: string,
            _account: string,
            _pageamount: BigNumberish,
            _xmint: boolean,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<BigNumber>;
    };

    populateTransaction: {
        amountMint(
            _key: string,
            _addressCount: BigNumberish,
            overrides?: CallOverrides
        ): Promise<PopulatedTransaction>;

        burn(
            from: string,
            amount: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        getAdmin(overrides?: CallOverrides): Promise<PopulatedTransaction>;

        getBurnNFTCost(
            overrides?: CallOverrides
        ): Promise<PopulatedTransaction>;

        getMinter(
            _key: string,
            overrides?: CallOverrides
        ): Promise<PopulatedTransaction>;

        getPageToken(overrides?: CallOverrides): Promise<PopulatedTransaction>;

        mint(
            _key: string,
            _to: string[],
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        mint1(
            _key: string,
            _to: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        mint2(
            _key: string,
            _to1: string,
            _to2: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        mint3(
            _key: string,
            _to1: string,
            _to2: string,
            _to3: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        mintX(
            _key: string,
            _to: string[],
            _multiplier: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        removeMinter(
            _key: string,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        setBurnNFTCost(
            _cost: BigNumberish,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;

        setMinter(
            _key: string,
            _account: string,
            _pageamount: BigNumberish,
            _xmint: boolean,
            overrides?: Overrides & { from?: string | Promise<string> }
        ): Promise<PopulatedTransaction>;
    };
}
