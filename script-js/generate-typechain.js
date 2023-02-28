const { runTypeChain, glob } = require('typechain')
const path = require('path')

const cwd = process.cwd()

const solSrcDir = path.join(__dirname, '../src') // solidity directory
const foundryOutDir = path.join(__dirname, '../out') // foundry build otuput directory

const typechainOutDir = 'typechain'
const typechainTarget = 'ethers-v5'

async function main() {
  const solFiles = glob(solSrcDir, ['**/*.sol'])
  const solFileNames = solFiles.map((f) => path.basename(f)) // a list of .sol basenames

  // foundry build output includes `abi` field in json format, so typechain is compatible
  const jsonFiles = glob(foundryOutDir, ['**/*.json']).filter((outFile) => {
    const dirBaseName = path.basename(path.dirname(outFile))
    return solFileNames.includes(dirBaseName)
  })

  const result = await runTypeChain({
    cwd,
    filesToProcess: jsonFiles,
    allFiles: jsonFiles,
    outDir: typechainOutDir,
    target: typechainTarget
  })

  console.log('typechain bindings for %s generated: %s files', typechainTarget, result.filesGenerated)
}

main().catch(console.error)
