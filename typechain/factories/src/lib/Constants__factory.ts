/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../common";
import type { Constants, ConstantsInterface } from "../../../src/lib/Constants";

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
    name: "BalancerV2_rETH_ETH_POOL_ID",
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
    name: "Curve_frxETH_ETH_POOL_ADDRESS",
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
    name: "Curve_frxETH_ETH_POOL_LP_TOKEN_ADDRESS",
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
    name: "Curve_frxETH_ETH_POOL_TOKEN_INDEX_ETH",
    outputs: [
      {
        internalType: "int128",
        name: "",
        type: "int128",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "Curve_frxETH_ETH_POOL_TOKEN_INDEX_frxETH",
    outputs: [
      {
        internalType: "int128",
        name: "",
        type: "int128",
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
    name: "Curve_stETH_ETH_POOL_TOKEN_INDEX_ETH",
    outputs: [
      {
        internalType: "int128",
        name: "",
        type: "int128",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "Curve_stETH_ETH_POOL_TOKEN_INDEX_stETH",
    outputs: [
      {
        internalType: "int128",
        name: "",
        type: "int128",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "DAI",
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
    name: "USDC",
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
  "0x608060405234801561001057600080fd5b506105dc806100206000396000f3fe608060405234801561001057600080fd5b506004361061012c5760003560e01c8063be78e8d9116100ad578063ce06961411610071578063ce069614146101d7578063e0bab4c4146101df578063ebdfda5e146101e7578063f2cd3a12146101ef578063f781b24e146101f757600080fd5b8063be78e8d914610197578063c1fe3e48146101bf578063c9ac8c8e146101c7578063ca8aa0e4146101cf578063cbc74de71461013157600080fd5b80635a33bbbe116100f45780635a33bbbe14610197578063698e07961461019f57806389a30271146101a7578063aa6430c6146101af578063ad5c4648146101b757600080fd5b8063020b627d1461013157806323c34a64146101515780634aa07e64146101675780634bc0dcb614610187578063565d3e6e1461018f575b600080fd5b6101396101ff565b604051600f9190910b81526020015b60405180910390f35b61015961024e565b604051908152602001610148565b61016f61027d565b6040516001600160a01b039091168152602001610148565b61016f6102c1565b61016f6102e4565b610139610328565b61016f610338565b61016f61035b565b61016f61039f565b61016f6103c2565b61016f610406565b61016f61044a565b61016f61046d565b61016f6104b1565b61016f6104f5565b61016f610539565b61015961057d565b61016f6105ac565b60004660010361020f5750600190565b60405162461bcd60e51b815260206004820152601060248201526f1d5b9adb9bdddb8818da185a5b881a5960821b604482015260640160405180910390fd5b60004660010361020f57507f1e19cf2d73a72ef1332c882f20534b6519be027600020000000000000000011290565b6000466001036102a05750737f39c581f595b53c5cb19bd0b3f8da6c935e2ca090565b4660050361020f5750736320cd32aa674d2898a68ec82e869385fc5f7e2f90565b60004660010361020f575073dc24316b9ae028f1497c275eb9192a3ea0f6702290565b6000466001036103075750735e8422345238f34275888049021821e8e08caa1f90565b4660050361020f5750733e04888b1c07a9805861c19551f7ed53145bd8d490565b60004660010361020f5750600090565b60004660010361020f57507306325440d014e39736583c165c2963ba99faf14e90565b60004660010361037e575073a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4890565b4660050361020f5750732f3a40a3db8a7e3d09b0adfefbce4f6f8192755790565b60004660010361020f575073a1f8a6807c402e4a15ef4eba36528a3fed24e57790565b6000466001036103e5575073c02aaa39b223fe8d0a0e5c4f27ead9083c756cc290565b4660050361020f575073b4fbf271143f4fbf7b91a5ded31805e42b2208d690565b600046600103610429575073ae7ab96520de3a18e5e111b5eaab095312d7fe8490565b4660050361020f5750731643e812ae58766192cf7d2cf9567df2c37e9b7f90565b600046600103610307575073ac3e018457b222d93114458476f3e3416abbe38f90565b600046600103610490575073ae78736cd615f374d3085123a210448e74fc639390565b4660050361020f575073ae78736cd615f374d3085123a210448e74fc639390565b6000466001036104d4575073ba12222222228d8ba445958a75a0704d566bf2c890565b4660050361020f575073ba12222222228d8ba445958a75a0704d566bf2c890565b6000466001036105185750736b175474e89094c44da98b954eedeac495271d0f90565b4660050361020f57507373967c6a0904aa032c103b4104747e88c566b1a290565b60004660010361055c575073bafa44efe7901e04e39dad13167d089c559c113890565b4660050361020f5750736421d1ca6cd35852362806a2ded2a49b6fa8bef590565b60004660010361020f57507f32296969ef14eb0c6d29669c550d4a044913023000020000000000000000008090565b60004660010361020f575073f43211935c781d5ca1a41d2041f397b8a7366c7a9056fea164736f6c6343000811000a";

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
