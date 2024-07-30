const TronWeb = require("tronweb");
// NOTE: "@noble/secp256k1" needs to be @ "1.7.1"
const tronWeb = new TronWeb({
  fullHost: "https://api.trongrid.io",
  headers: { "TRON-PRO-API-KEY": process.env.TRONGRID_API_KEY },
  privateKey: process.env.TRON_PK, // as hex string without the 0x
});

let abi = require("./ERC20PermissionedMint-abi.json");
let fraxAddress = "TQZTkTMbkC9923LtVHZcSrdqcW5rVhkZHP";
let ferryAddress = "TGxtcNUY9q19FATX3tFxzkmBhQigVDTFJs";

let fraxAsFullHex = tronWeb.address.toHex(fraxAddress);
let fraxAsEVMHex = "0x".concat(fraxAsFullHex.substr(2));
console.log(fraxAsEVMHex); // 0xa00c37011018b4b11cffbbf0305a771d9d4066cf

let deployerAsEVMHex = "0x721fc501d1fe305065dc88da0cf90406a79dfd69";
let deployerAsFullHex = "41".concat(deployerAsEVMHex.substr(2));
let deployerAddress = tronWeb.address.fromHex(deployerAsFullHex);
console.log(deployerAddress); // TLNe6KF1dUSYBcZ4fzTstoKB8bkzQewz42

async function main() {
  let ctr = await tronWeb.contract(abi, fraxAddress);
  // View call
  let balance = await ctr.balanceOf(ferryAddress).call();
  // ERC20.transfer() call
  // https://tronscan.org/#/transaction/a8a22abfda01745cf6475b826a0cc1bfb21ccc7e86be7d87fe76c3fed2976020
  await ctr.transfer(ferryAddress, 123456).send();
}

(async function () {
  await main();
})();
