const BigNumber = require("bignumber.js");
const TronWeb = require("tronweb");
const { ethers } = require("ethers");

// NOTE: "@noble/secp256k1" needs to be @ "1.7.1"
// TODO: RM PK
const tronWeb = new TronWeb({
  fullHost: "https://api.trongrid.io",
  headers: { "TRON-PRO-API-KEY": process.env.TRONGRID_API_KEY },
  privateKey: process.env.TRON_PK, // as hex string without the 0x
});

// let fraxAbi = require("./ERC20PermissionedMint-abi.json");
let msigAbi = require("./FraxMultisigWallet-abi.json");

let fraxAddress = "TQZTkTMbkC9923LtVHZcSrdqcW5rVhkZHP";
let msigAddress = "TWtG5rwf67UUkywcZvF1c24MXXRD8LDBjf";
let deployerAddress = "TLNe6KF1dUSYBcZ4fzTstoKB8bkzQewz42";

async function load() {
  // let frax = await tronWeb.contract(fraxAbi, fraxAddress);
  let msig = await tronWeb.contract(msigAbi, msigAddress);
  return msig;
}

async function transfer() {
  let msig = await load();
  let abiCoder = ethers.AbiCoder.defaultAbiCoder();
  let selector = "0xa9059cbb";

  let args = process.argv.slice(2);
  if (args.length != 3) {
    console.log("arguments passed should be `{token symbol} {amount} {decimals}`");
    return;
  }

  let erc20;
  let recipient;

  let token = args[0].toUpperCase();
  if (token === "FRAX") {
    erc20 = fraxAddress;
    recipient = deployerAddress; // TODO: should be fraxFerry
  } else {
    console.log("argument 0 should be one of ['frax', 'sfrx', 'fxs']");
    return;
  }
  let recipientEncoded = "0000000000000000000000".concat(tronWeb.address.toHex(deployerAddress));

  // imported values
  let amount = parseInt(args[1], 10);
  let numZeros = parseInt(args[2], 10);
  let amountWithZeros = amount * 10 ** numZeros;

  let amountEncoded = abiCoder.encode(["uint"], [amountWithZeros.toString()]).substr(2); // rm the "0x"

  let payload = selector.concat(recipientEncoded).concat(amountEncoded);

  console.log(`Submit Transfer of ${amount} * 10**${numZeros} ${token} to FraxFerry ${recipient}`);
  await msig.submitTransaction(erc20, 0, payload).send();
}

(async function () {
  await transfer();
})();
