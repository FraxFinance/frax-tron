const BigNumber = require("bignumber.js");
const TronWeb = require("tronweb");
// NOTE: "@noble/secp256k1" needs to be @ "1.7.1"
const tronWeb = new TronWeb({
  fullHost: "https://api.trongrid.io",
  headers: { "TRON-PRO-API-KEY": process.env.TRONGRID_API_KEY },
  privateKey: process.env.TRON_PK, // as hex string without the 0x
});

let fraxAbi = require("./ERC20PermissionedMint-abi.json");
let ferryAbi = require("./Fraxferry-abi.json");
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
  /// @dev: fraxAsEVMHex does NOT work here. Must use tron address
  let frax = await tronWeb.contract(fraxAbi, fraxAddress);
  let ferry = await tronWeb.contract(ferryAbi, ferryAddress);

  // View frax balance
  let balance = await frax.balanceOf(ferryAddress).call();

  // frax transfer
  // await frax.transfer(ferryAddress, 123456).send();
  // https://tronscan.org/#/transaction/a8a22abfda01745cf6475b826a0cc1bfb21ccc7e86be7d87fe76c3fed2976020

  let amount500 = "500000000000000000000";

  // Approve ferry to spend amount500
  // await frax.approve(ferryAddress, amount500).send();
  // https://tronscan.org/#/transaction/4b340859fc81fad541c692b5dea1c94b463a49e2e2861211b6b9a69a5d509786

  // embark 500 FRAX
  // await ferry.embark(amount500).send();
  // https://tronscan.org/#/transaction/cccdc0051cc707f7cc32ac85802edc2abe4a25fc08fbdb8107a12b605b271c67

  // let amount200 = "200000000000000000000";
  // await frax.approve(ferryAddress, amount200).send();
  // await ferry.embark(amount200).send();

  // From tx 0 on fraxtal
  // await ferry.depart(0, 0, "0x440440273a8244ffd45d7e29a27cf70cbbe0f7bb71d34b8d6f51fadf20ca1f2b");

  // @dev these two hashes submitted on fraxtal ferry as `depart(0, 0, 0xf4..)`, `depart(1, 1, 0x00..)`
  // await ferry.getTransactionsHash(0,0) = 0xf4c84d93ec6532053d3ae296cf8bdac74b1f54cd0f1918e66c948e5ce2a040f0
  // await ferry.getTransactionsHash(1,1) = 0x00d0d1c4d700f745611e9ee8aa9b76e02c6b8a7b84354eb41e2a7627be9e52be

  let batchNo = 0;
  // Converted 0xb0e to tron-hex
  let user = "TS6TwX43hqn6qCQMz7nBAxHqvZuaWYY9mM"; // 0xb0e1650a9760e0f383174af042091fc544b8356f
  let amount = 9500000000;
  let timestamp = 1722460387;

  let batchData = [batchNo.toString(), [[user, amount.toString(), timestamp.toString()]]];
  await ferry.disembark(batchData).send();

  /// @dev: ferry.getBatchData on tron returns "41b0e1650a9760e0f383174af042091fc544b8356f" for `user` (41 + evm hex)
  let batchDataOld = await ferry.getBatchData(0, 0).call();
  console.log("data[0]");
  console.log(batchDataOld[0]);
}

(async function () {
  await main();
})();
