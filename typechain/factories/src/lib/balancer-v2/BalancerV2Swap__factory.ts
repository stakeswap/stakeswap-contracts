/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../common";
import type {
  BalancerV2Swap,
  BalancerV2SwapInterface,
} from "../../../../src/lib/balancer-v2/BalancerV2Swap";

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
    inputs: [
      {
        internalType: "address",
        name: "fromToken",
        type: "address",
      },
      {
        internalType: "address",
        name: "toToken",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "fromTokenAmount",
        type: "uint256",
      },
      {
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
    ],
    name: "BalancerV2_swap",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "payable",
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
  {
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b506110e3806100206000396000f3fe60806040526004361061012e5760003560e01c8063ad5c4648116100ab578063cbc74de71161006f578063cbc74de71461013a578063ce0696141461029c578063e0bab4c4146102b1578063ebdfda5e146102c6578063f2cd3a12146102db578063f781b24e146102f057600080fd5b8063ad5c464814610248578063be78e8d9146101e1578063c1fe3e481461025d578063c9ac8c8e14610272578063ca8aa0e41461028757600080fd5b80635a33bbbe116100f25780635a33bbbe146101e1578063698e0796146101f657806380f907c41461020b57806389a302711461021e578063aa6430c61461023357600080fd5b8063020b627d1461013a57806323c34a64146101675780634aa07e641461018a5780634bc0dcb6146101b7578063565d3e6e146101cc57600080fd5b3661013557005b600080fd5b34801561014657600080fd5b5061014f610305565b604051600f9190910b81526020015b60405180910390f35b34801561017357600080fd5b5061017c610355565b60405190815260200161015e565b34801561019657600080fd5b5061019f610384565b6040516001600160a01b03909116815260200161015e565b3480156101c357600080fd5b5061019f6103c8565b3480156101d857600080fd5b5061019f6103eb565b3480156101ed57600080fd5b5061014f61042f565b34801561020257600080fd5b5061019f61043f565b61017c610219366004610d1b565b610462565b34801561022a57600080fd5b5061019f61075a565b34801561023f57600080fd5b5061019f61079e565b34801561025457600080fd5b5061019f6107c1565b34801561026957600080fd5b5061019f610805565b34801561027e57600080fd5b5061019f610849565b34801561029357600080fd5b5061019f61086c565b3480156102a857600080fd5b5061019f6108b0565b3480156102bd57600080fd5b5061019f6108f4565b3480156102d257600080fd5b5061019f610938565b3480156102e757600080fd5b5061017c61097c565b3480156102fc57600080fd5b5061019f6109ab565b6000466001036103155750600190565b60405162461bcd60e51b815260206004820152601060248201526f1d5b9adb9bdddb8818da185a5b881a5960821b60448201526064015b60405180910390fd5b60004660010361031557507f1e19cf2d73a72ef1332c882f20534b6519be027600020000000000000000011290565b6000466001036103a75750737f39c581f595b53c5cb19bd0b3f8da6c935e2ca090565b466005036103155750736320cd32aa674d2898a68ec82e869385fc5f7e2f90565b600046600103610315575073dc24316b9ae028f1497c275eb9192a3ea0f6702290565b60004660010361040e5750735e8422345238f34275888049021821e8e08caa1f90565b466005036103155750733e04888b1c07a9805861c19551f7ed53145bd8d490565b6000466001036103155750600090565b60004660010361031557507306325440d014e39736583c165c2963ba99faf14e90565b60008061046d6108b0565b60408051600180825281830190925291925060009190816020015b6104bd6040518060a0016040528060008019168152602001600081526020016000815260200160008152602001606081525090565b8152602001906001900390816104885790505090506040518060a001604052808581526020016000815260200160018152602001868152602001604051806020016040528060008152508152508160008151811061051d5761051d610d73565b602090810291909101015260408051600280825260608201909252600091816020016020820280368337019050509050878160008151811061056157610561610d73565b60200260200101906001600160a01b031690816001600160a01b031681525050868160018151811061059557610595610d73565b6001600160a01b039290921660209283029190910182015260408051600280825260608201835260009391929091830190803683370190505090506001600160ff1b03816000815181106105eb576105eb610d73565b6020026020010181815250506001600160ff1b038160018151811061061257610612610d73565b602090810291909101015260006001600160a01b038a1661063457503461063f565b61063f8a868a6109ce565b60408051608081018252308082526000602083018190528284019190915260608201819052915163945bcec960e01b81526001600160a01b0388169163945bcec991859161069a9186918b918b91908b904290600401610e4d565b60006040518083038185885af11580156106b8573d6000803e3d6000fd5b50505050506040513d6000823e601f3d908101601f191682016040526106e19190810190610f7d565b90506000816001815181106106f8576106f8610d73565b602002602001015112610725578060018151811061071857610718610d73565b6020026020010151610749565b8060018151811061073857610738610d73565b60200260200101516107499061103b565b96505050505050505b949350505050565b60004660010361077d575073a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4890565b466005036103155750732f3a40a3db8a7e3d09b0adfefbce4f6f8192755790565b600046600103610315575073a1f8a6807c402e4a15ef4eba36528a3fed24e57790565b6000466001036107e4575073c02aaa39b223fe8d0a0e5c4f27ead9083c756cc290565b46600503610315575073b4fbf271143f4fbf7b91a5ded31805e42b2208d690565b600046600103610828575073ae7ab96520de3a18e5e111b5eaab095312d7fe8490565b466005036103155750731643e812ae58766192cf7d2cf9567df2c37e9b7f90565b60004660010361040e575073ac3e018457b222d93114458476f3e3416abbe38f90565b60004660010361088f575073ae78736cd615f374d3085123a210448e74fc639390565b46600503610315575073ae78736cd615f374d3085123a210448e74fc639390565b6000466001036108d3575073ba12222222228d8ba445958a75a0704d566bf2c890565b46600503610315575073ba12222222228d8ba445958a75a0704d566bf2c890565b6000466001036109175750736b175474e89094c44da98b954eedeac495271d0f90565b4660050361031557507373967c6a0904aa032c103b4104747e88c566b1a290565b60004660010361095b575073bafa44efe7901e04e39dad13167d089c559c113890565b466005036103155750736421d1ca6cd35852362806a2ded2a49b6fa8bef590565b60004660010361031557507f32296969ef14eb0c6d29669c550d4a044913023000020000000000000000008090565b600046600103610315575073f43211935c781d5ca1a41d2041f397b8a7366c7a90565b801580610a485750604051636eb1769f60e11b81523060048201526001600160a01b03838116602483015284169063dd62ed3e90604401602060405180830381865afa158015610a22573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610a469190611065565b155b610ab35760405162461bcd60e51b815260206004820152603660248201527f5361666545524332303a20617070726f76652066726f6d206e6f6e2d7a65726f60448201527520746f206e6f6e2d7a65726f20616c6c6f77616e636560501b606482015260840161034c565b604080516001600160a01b038416602482015260448082018490528251808303909101815260649091019091526020810180516001600160e01b031663095ea7b360e01b179052610b05908490610b0a565b505050565b6000610b5f826040518060400160405280602081526020017f5361666545524332303a206c6f772d6c6576656c2063616c6c206661696c6564815250856001600160a01b0316610bdc9092919063ffffffff16565b805190915015610b055780806020019051810190610b7d919061107e565b610b055760405162461bcd60e51b815260206004820152602a60248201527f5361666545524332303a204552433230206f7065726174696f6e20646964206e6044820152691bdd081cdd58d8d9595960b21b606482015260840161034c565b6060610752848460008585600080866001600160a01b03168587604051610c0391906110a7565b60006040518083038185875af1925050503d8060008114610c40576040519150601f19603f3d011682016040523d82523d6000602084013e610c45565b606091505b5091509150610c5687838387610c61565b979650505050505050565b60608315610cd0578251600003610cc9576001600160a01b0385163b610cc95760405162461bcd60e51b815260206004820152601d60248201527f416464726573733a2063616c6c20746f206e6f6e2d636f6e7472616374000000604482015260640161034c565b5081610752565b6107528383815115610ce55781518083602001fd5b8060405162461bcd60e51b815260040161034c91906110c3565b80356001600160a01b0381168114610d1657600080fd5b919050565b60008060008060808587031215610d3157600080fd5b610d3a85610cff565b9350610d4860208601610cff565b93969395505050506040820135916060013590565b634e487b7160e01b600052604160045260246000fd5b634e487b7160e01b600052603260045260246000fd5b60005b83811015610da4578181015183820152602001610d8c565b50506000910152565b60008151808452610dc5816020860160208601610d89565b601f01601f19169290920160200192915050565b600081518084526020808501945080840160005b83811015610e125781516001600160a01b031687529582019590820190600101610ded565b509495945050505050565b600081518084526020808501945080840160005b83811015610e1257815187529582019590820190600101610e31565b600061012080830160028a10610e7357634e487b7160e01b600052602160045260246000fd5b89845260208085019290925288519081905261014080850192600583901b8601909101918a820160005b82811015610f005787850361013f190186528151805186528481015185870152604080820151908701526060808201519087015260809081015160a091870182905290610eec81880183610dad565b978601979650505090830190600101610e9d565b505050508381036040850152610f168189610dd9565b915050610f56606084018780516001600160a01b039081168352602080830151151590840152604080830151909116908301526060908101511515910152565b82810360e0840152610f688186610e1d565b91505082610100830152979650505050505050565b60006020808385031215610f9057600080fd5b825167ffffffffffffffff80821115610fa857600080fd5b818501915085601f830112610fbc57600080fd5b815181811115610fce57610fce610d5d565b8060051b604051601f19603f83011681018181108582111715610ff357610ff3610d5d565b60405291825284820192508381018501918883111561101157600080fd5b938501935b8285101561102f57845184529385019392850192611016565b98975050505050505050565b6000600160ff1b820161105e57634e487b7160e01b600052601160045260246000fd5b5060000390565b60006020828403121561107757600080fd5b5051919050565b60006020828403121561109057600080fd5b815180151581146110a057600080fd5b9392505050565b600082516110b9818460208701610d89565b9190910192915050565b6020815260006110a06020830184610dad56fea164736f6c6343000811000a";

type BalancerV2SwapConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: BalancerV2SwapConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class BalancerV2Swap__factory extends ContractFactory {
  constructor(...args: BalancerV2SwapConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<BalancerV2Swap> {
    return super.deploy(overrides || {}) as Promise<BalancerV2Swap>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): BalancerV2Swap {
    return super.attach(address) as BalancerV2Swap;
  }
  override connect(signer: Signer): BalancerV2Swap__factory {
    return super.connect(signer) as BalancerV2Swap__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): BalancerV2SwapInterface {
    return new utils.Interface(_abi) as BalancerV2SwapInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): BalancerV2Swap {
    return new Contract(address, _abi, signerOrProvider) as BalancerV2Swap;
  }
}
