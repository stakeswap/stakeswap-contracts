import fs, { promises as fsAsync } from "fs";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import path from "path";

const FILE = path.join(__dirname, "../contract-deployment.json");

// export contract deployment to `contract-deployment.json` file
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const networkName = deployments.getNetworkName();

  // // short circuit for hardhat network
  // if (networkName === "hardhat") return;

  const contracts = await deployments.all();
  const namedAccounts = await getNamedAccounts();
  const { chainId } = await ethers.provider.getNetwork();

  const content = fs.existsSync(FILE) ? await fsAsync.readFile(FILE, "utf-8") : "";
  const parsed = content ? JSON.parse(content) : {};
  parsed[networkName] = {
    chainId,
    namedAccounts,
    contracts: Object.entries(contracts).reduce(
      (acc, [name, deployment]) => ({ ...acc, [name]: deployment.address }),
      {}
    ),
  };

  console.log("update %s", FILE);
  await fsAsync.writeFile(FILE, JSON.stringify(parsed, null, 2));
};
export default func;
func.tags = ["export-json"];
