/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../common";
import type { Constants, ConstantsInterface } from "../Constants";

const _abi = [
  {
    inputs: [],
    name: "BalancerV2Vault",
    outputs: [
      {
        internalType: "contract BalancerV2VaultInterface",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "BalancerV2_wstETH_WETH_POOL_ID",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "Curve_stETH_ETH_POOL_ADDRESS",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "Curve_stETH_ETH_POOL_LP_TOKEN_ADDRESS",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "WETH",
    outputs: [
      {
        internalType: "contract WETHInterface",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "frxETH",
    outputs: [
      {
        internalType: "contract IERC20",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "frxETHMinter",
    outputs: [
      {
        internalType: "contract frxETHMinter",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "rETH",
    outputs: [
      {
        internalType: "contract IrETH",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "sfrxETH",
    outputs: [
      {
        internalType: "contract sfrxETH",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "stETH",
    outputs: [
      {
        internalType: "contract ILido",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "wstETH",
    outputs: [
      {
        internalType: "contract IWstETH",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b5061041a806100206000396000f3fe608060405234801561001057600080fd5b50600436106100a95760003560e01c8063c1fe3e4811610071578063c1fe3e48146100f3578063c9ac8c8e146100fb578063ca8aa0e414610103578063ce0696141461010b578063ebdfda5e14610113578063f2cd3a121461011b57600080fd5b80634aa07e64146100ae5780634bc0dcb6146100d3578063565d3e6e146100db578063698e0796146100e3578063ad5c4648146100eb575b600080fd5b6100b6610131565b6040516001600160a01b0390911681526020015b60405180910390f35b6100b66101b4565b6100b66101d7565b6100b661021b565b6100b661023e565b6100b6610282565b6100b66102c6565b6100b66102e9565b6100b661032d565b6100b6610371565b6101236103b5565b6040519081526020016100ca565b6000466001036101545750737f39c581f595b53c5cb19bd0b3f8da6c935e2ca090565b466005036101755750736320cd32aa674d2898a68ec82e869385fc5f7e2f90565b60405162461bcd60e51b815260206004820152601060248201526f1d5b9adb9bdddb8818da185a5b881a5960821b604482015260640160405180910390fd5b600046600103610175575073dc24316b9ae028f1497c275eb9192a3ea0f6702290565b6000466001036101fa5750735e8422345238f34275888049021821e8e08caa1f90565b466005036101755750733e04888b1c07a9805861c19551f7ed53145bd8d490565b60004660010361017557507306325440d014e39736583c165c2963ba99faf14e90565b600046600103610261575073c02aaa39b223fe8d0a0e5c4f27ead9083c756cc290565b46600503610175575073b4fbf271143f4fbf7b91a5ded31805e42b2208d690565b6000466001036102a5575073ae7ab96520de3a18e5e111b5eaab095312d7fe8490565b466005036101755750731643e812ae58766192cf7d2cf9567df2c37e9b7f90565b6000466001036101fa575073ac3e018457b222d93114458476f3e3416abbe38f90565b60004660010361030c575073ae78736cd615f374d3085123a210448e74fc639390565b46600503610175575073ae78736cd615f374d3085123a210448e74fc639390565b600046600103610350575073ba12222222228d8ba445958a75a0704d566bf2c890565b46600503610175575073ba12222222228d8ba445958a75a0704d566bf2c890565b600046600103610394575073bafa44efe7901e04e39dad13167d089c559c113890565b466005036101755750736421d1ca6cd35852362806a2ded2a49b6fa8bef590565b60004660010361017557507f32296969ef14eb0c6d29669c550d4a04491302300002000000000000000000809056fea264697066735822122006c5e556bf35ce67c7821a67fc134c134df5a8f6349b1022af8fd81b22df536b64736f6c63430008110033";

type ConstantsConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ConstantsConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class Constants__factory extends ContractFactory {
  constructor(...args: ConstantsConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<Constants> {
    return super.deploy(overrides || {}) as Promise<Constants>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): Constants {
    return super.attach(address) as Constants;
  }
  override connect(signer: Signer): Constants__factory {
    return super.connect(signer) as Constants__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ConstantsInterface {
    return new utils.Interface(_abi) as ConstantsInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): Constants {
    return new Contract(address, _abi, signerOrProvider) as Constants;
  }
}
