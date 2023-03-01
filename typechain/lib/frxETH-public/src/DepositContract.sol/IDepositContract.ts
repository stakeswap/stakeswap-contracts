/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../../../../common";

export interface IDepositContractInterface extends utils.Interface {
  functions: {
    "deposit(bytes,bytes,bytes,bytes32)": FunctionFragment;
    "get_deposit_count()": FunctionFragment;
    "get_deposit_root()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic: "deposit" | "get_deposit_count" | "get_deposit_root"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "deposit",
    values: [
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "get_deposit_count",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "get_deposit_root",
    values?: undefined
  ): string;

  decodeFunctionResult(functionFragment: "deposit", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "get_deposit_count",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "get_deposit_root",
    data: BytesLike
  ): Result;

  events: {
    "DepositEvent(bytes,bytes,bytes,bytes,bytes)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "DepositEvent"): EventFragment;
}

export interface DepositEventEventObject {
  pubkey: string;
  withdrawal_credentials: string;
  amount: string;
  signature: string;
  index: string;
}
export type DepositEventEvent = TypedEvent<
  [string, string, string, string, string],
  DepositEventEventObject
>;

export type DepositEventEventFilter = TypedEventFilter<DepositEventEvent>;

export interface IDepositContract extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDepositContractInterface;

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
    deposit(
      pubkey: PromiseOrValue<BytesLike>,
      withdrawal_credentials: PromiseOrValue<BytesLike>,
      signature: PromiseOrValue<BytesLike>,
      deposit_data_root: PromiseOrValue<BytesLike>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    get_deposit_count(overrides?: CallOverrides): Promise<[string]>;

    get_deposit_root(overrides?: CallOverrides): Promise<[string]>;
  };

  deposit(
    pubkey: PromiseOrValue<BytesLike>,
    withdrawal_credentials: PromiseOrValue<BytesLike>,
    signature: PromiseOrValue<BytesLike>,
    deposit_data_root: PromiseOrValue<BytesLike>,
    overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  get_deposit_count(overrides?: CallOverrides): Promise<string>;

  get_deposit_root(overrides?: CallOverrides): Promise<string>;

  callStatic: {
    deposit(
      pubkey: PromiseOrValue<BytesLike>,
      withdrawal_credentials: PromiseOrValue<BytesLike>,
      signature: PromiseOrValue<BytesLike>,
      deposit_data_root: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    get_deposit_count(overrides?: CallOverrides): Promise<string>;

    get_deposit_root(overrides?: CallOverrides): Promise<string>;
  };

  filters: {
    "DepositEvent(bytes,bytes,bytes,bytes,bytes)"(
      pubkey?: null,
      withdrawal_credentials?: null,
      amount?: null,
      signature?: null,
      index?: null
    ): DepositEventEventFilter;
    DepositEvent(
      pubkey?: null,
      withdrawal_credentials?: null,
      amount?: null,
      signature?: null,
      index?: null
    ): DepositEventEventFilter;
  };

  estimateGas: {
    deposit(
      pubkey: PromiseOrValue<BytesLike>,
      withdrawal_credentials: PromiseOrValue<BytesLike>,
      signature: PromiseOrValue<BytesLike>,
      deposit_data_root: PromiseOrValue<BytesLike>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    get_deposit_count(overrides?: CallOverrides): Promise<BigNumber>;

    get_deposit_root(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    deposit(
      pubkey: PromiseOrValue<BytesLike>,
      withdrawal_credentials: PromiseOrValue<BytesLike>,
      signature: PromiseOrValue<BytesLike>,
      deposit_data_root: PromiseOrValue<BytesLike>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    get_deposit_count(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    get_deposit_root(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}
