const { ethers } = require("ethers")
const { mnemonic } = require("/home/carl/.aragon/mnemonic.json")
const wallet = new ethers.Wallet.fromMnemonic(mnemonic)
                    .connect(new ethers.providers.InfuraProvider('rinkeby'))
const abi = require("../build/contracts/Template.json").abi
const template = new ethers.Contract("0xF898A0Fb9c94a6C9570B35d24dDc04a00e4d9DdC", abi, wallet);

async function main(){
  let tx = await template.newInstance()
  console.log(tx)
  let block = await tx.wait()
  console.log(block)
}
main()
