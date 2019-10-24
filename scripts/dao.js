const { ethers } = require("ethers")
const homedir = require("homedir")
const { mnemonic } = require(`${homedir()}/.aragon/mnemonic.json`)
const wallet = new ethers.Wallet("a8a54b2d8197bc0b19bb8a084031be71835580a01e70a45a13babd16c9bc1563")
                    .connect(new ethers.providers.InfuraProvider('rinkeby'))
const abi = require("../build/contracts/Template.json").abi
const template = new ethers.Contract("0xdE96C59bbf851e78FA83224DFCbdEcC00bA5EB12", abi, wallet);

async function main(){
  let tx = await template.newInstance()
  console.log(tx.hash)
  let block = await tx.wait()
  // console.log(block)
}
main()
