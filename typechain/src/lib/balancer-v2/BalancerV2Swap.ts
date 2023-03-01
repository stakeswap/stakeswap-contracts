/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../../../common";

export interface BalancerV2SwapInterface extends utils.Interface {
  functions: {
    "BalancerV2Vault()": FunctionFragment;
    "BalancerV2_rETH_ETH_POOL_ID()": FunctionFragment;
    "BalancerV2_swap(address,address,uint256,bytes32)": FunctionFragment;
    "BalancerV2_wstETH_WETH_POOL_ID()": FunctionFragment;
    "Curve_frxETH_ETH_POOL_ADDRESS()": FunctionFragment;
    "Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS()": FunctionFragment;
    "Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH()": FunctionFragment;
    "Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH()": FunctionFragment;
    "Curve_stETH_ETH_POOL_ADDRESS()": FunctionFragment;
    "Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS()": FunctionFragment;
    "Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH()": FunctionFragment;
    "Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH()": FunctionFragment;
    "DAI()": FunctionFragment;
    "USDC()": FunctionFragment;
    "WETH()": FunctionFragment;
    "frxETH()": FunctionFragment;
    "frxETHMinter()": FunctionFragment;
    "rETH()": FunctionFragment;
    "sfrxETH()": FunctionFragment;
    "stETH()": FunctionFragment;
    "wstETH()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "BalancerV2Vault"
      | "BalancerV2_rETH_ETH_POOL_ID"
      | "BalancerV2_swap"
      | "BalancerV2_wstETH_WETH_POOL_ID"
      | "Curve_frxETH_ETH_POOL_ADDRESS"
      | "Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS"
      | "Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH"
      | "Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH"
      | "Curve_stETH_ETH_POOL_ADDRESS"
      | "Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS"
      | "Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH"
      | "Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH"
      | "DAI"
      | "USDC"
      | "WETH"
      | "frxETH"
      | "frxETHMinter"
      | "rETH"
      | "sfrxETH"
      | "stETH"
      | "wstETH"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "BalancerV2Vault",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "BalancerV2_rETH_ETH_POOL_ID",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "BalancerV2_swap",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "BalancerV2_wstETH_WETH_POOL_ID",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_frxETH_ETH_POOL_ADDRESS",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_stETH_ETH_POOL_ADDRESS",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "DAI", values?: undefined): string;
  encodeFunctionData(functionFragment: "USDC", values?: undefined): string;
  encodeFunctionData(functionFragment: "WETH", values?: undefined): string;
  encodeFunctionData(functionFragment: "frxETH", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "frxETHMinter",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "rETH", values?: undefined): string;
  encodeFunctionData(functionFragment: "sfrxETH", values?: undefined): string;
  encodeFunctionData(functionFragment: "stETH", values?: undefined): string;
  encodeFunctionData(functionFragment: "wstETH", values?: undefined): string;

  decodeFunctionResult(
    functionFragment: "BalancerV2Vault",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "BalancerV2_rETH_ETH_POOL_ID",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "BalancerV2_swap",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "BalancerV2_wstETH_WETH_POOL_ID",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_frxETH_ETH_POOL_ADDRESS",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_stETH_ETH_POOL_ADDRESS",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "DAI", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "USDC", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "WETH", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "frxETH", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "frxETHMinter",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "rETH", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "sfrxETH", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "stETH", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "wstETH", data: BytesLike): Result;

  events: {};
}

export interface BalancerV2Swap extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: BalancerV2SwapInterface;

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
    BalancerV2Vault(overrides?: CallOverrides): Promise<[string]>;

    BalancerV2_rETH_ETH_POOL_ID(overrides?: CallOverrides): Promise<[string]>;

    BalancerV2_swap(
      fromToken: PromiseOrValue<string>,
      toToken: PromiseOrValue<string>,
      fromTokenAmount: PromiseOrValue<BigNumberish>,
      poolId: PromiseOrValue<BytesLike>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    BalancerV2_wstETH_WETH_POOL_ID(
      overrides?: CallOverrides
    ): Promise<[string]>;

    Curve_frxETH_ETH_POOL_ADDRESS(overrides?: CallOverrides): Promise<[string]>;

    Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<[string]>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH(
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    Curve_stETH_ETH_POOL_ADDRESS(overrides?: CallOverrides): Promise<[string]>;

    Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<[string]>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH(
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    DAI(overrides?: CallOverrides): Promise<[string]>;

    USDC(overrides?: CallOverrides): Promise<[string]>;

    WETH(overrides?: CallOverrides): Promise<[string]>;

    frxETH(overrides?: CallOverrides): Promise<[string]>;

    frxETHMinter(overrides?: CallOverrides): Promise<[string]>;

    rETH(overrides?: CallOverrides): Promise<[string]>;

    sfrxETH(overrides?: CallOverrides): Promise<[string]>;

    stETH(overrides?: CallOverrides): Promise<[string]>;

    wstETH(overrides?: CallOverrides): Promise<[string]>;
  };

  BalancerV2Vault(overrides?: CallOverrides): Promise<string>;

  BalancerV2_rETH_ETH_POOL_ID(overrides?: CallOverrides): Promise<string>;

  BalancerV2_swap(
    fromToken: PromiseOrValue<string>,
    toToken: PromiseOrValue<string>,
    fromTokenAmount: PromiseOrValue<BigNumberish>,
    poolId: PromiseOrValue<BytesLike>,
    overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  BalancerV2_wstETH_WETH_POOL_ID(overrides?: CallOverrides): Promise<string>;

  Curve_frxETH_ETH_POOL_ADDRESS(overrides?: CallOverrides): Promise<string>;

  Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS(
    overrides?: CallOverrides
  ): Promise<string>;

  Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH(
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH(
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  Curve_stETH_ETH_POOL_ADDRESS(overrides?: CallOverrides): Promise<string>;

  Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS(
    overrides?: CallOverrides
  ): Promise<string>;

  Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH(
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH(
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  DAI(overrides?: CallOverrides): Promise<string>;

  USDC(overrides?: CallOverrides): Promise<string>;

  WETH(overrides?: CallOverrides): Promise<string>;

  frxETH(overrides?: CallOverrides): Promise<string>;

  frxETHMinter(overrides?: CallOverrides): Promise<string>;

  rETH(overrides?: CallOverrides): Promise<string>;

  sfrxETH(overrides?: CallOverrides): Promise<string>;

  stETH(overrides?: CallOverrides): Promise<string>;

  wstETH(overrides?: CallOverrides): Promise<string>;

  callStatic: {
    BalancerV2Vault(overrides?: CallOverrides): Promise<string>;

    BalancerV2_rETH_ETH_POOL_ID(overrides?: CallOverrides): Promise<string>;

    BalancerV2_swap(
      fromToken: PromiseOrValue<string>,
      toToken: PromiseOrValue<string>,
      fromTokenAmount: PromiseOrValue<BigNumberish>,
      poolId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    BalancerV2_wstETH_WETH_POOL_ID(overrides?: CallOverrides): Promise<string>;

    Curve_frxETH_ETH_POOL_ADDRESS(overrides?: CallOverrides): Promise<string>;

    Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<string>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_stETH_ETH_POOL_ADDRESS(overrides?: CallOverrides): Promise<string>;

    Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<string>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    DAI(overrides?: CallOverrides): Promise<string>;

    USDC(overrides?: CallOverrides): Promise<string>;

    WETH(overrides?: CallOverrides): Promise<string>;

    frxETH(overrides?: CallOverrides): Promise<string>;

    frxETHMinter(overrides?: CallOverrides): Promise<string>;

    rETH(overrides?: CallOverrides): Promise<string>;

    sfrxETH(overrides?: CallOverrides): Promise<string>;

    stETH(overrides?: CallOverrides): Promise<string>;

    wstETH(overrides?: CallOverrides): Promise<string>;
  };

  filters: {};

  estimateGas: {
    BalancerV2Vault(overrides?: CallOverrides): Promise<BigNumber>;

    BalancerV2_rETH_ETH_POOL_ID(overrides?: CallOverrides): Promise<BigNumber>;

    BalancerV2_swap(
      fromToken: PromiseOrValue<string>,
      toToken: PromiseOrValue<string>,
      fromTokenAmount: PromiseOrValue<BigNumberish>,
      poolId: PromiseOrValue<BytesLike>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    BalancerV2_wstETH_WETH_POOL_ID(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_frxETH_ETH_POOL_ADDRESS(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_stETH_ETH_POOL_ADDRESS(overrides?: CallOverrides): Promise<BigNumber>;

    Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH(
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    DAI(overrides?: CallOverrides): Promise<BigNumber>;

    USDC(overrides?: CallOverrides): Promise<BigNumber>;

    WETH(overrides?: CallOverrides): Promise<BigNumber>;

    frxETH(overrides?: CallOverrides): Promise<BigNumber>;

    frxETHMinter(overrides?: CallOverrides): Promise<BigNumber>;

    rETH(overrides?: CallOverrides): Promise<BigNumber>;

    sfrxETH(overrides?: CallOverrides): Promise<BigNumber>;

    stETH(overrides?: CallOverrides): Promise<BigNumber>;

    wstETH(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    BalancerV2Vault(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    BalancerV2_rETH_ETH_POOL_ID(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    BalancerV2_swap(
      fromToken: PromiseOrValue<string>,
      toToken: PromiseOrValue<string>,
      fromTokenAmount: PromiseOrValue<BigNumberish>,
      poolId: PromiseOrValue<BytesLike>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    BalancerV2_wstETH_WETH_POOL_ID(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_frxETH_ETH_POOL_ADDRESS(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_stETH_ETH_POOL_ADDRESS(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    DAI(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    USDC(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    WETH(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    frxETH(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    frxETHMinter(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    rETH(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    sfrxETH(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    stETH(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    wstETH(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}
