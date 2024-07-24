# Frax Tron

Good afternoon team,
I've successfully deployed the FRAX mintable ERC20 with Ferry on Tron.

## Resources
- https://tronscan.org
- https://www.btcschools.net/tron/tron_tool_base58check_hex.php
  - Ignore the "41" at the start when decoding Base58

## Addresses
- Deployer / Authorized Minter
  - `TLNe6KF1dUSYBcZ4fzTstoKB8bkzQewz42`
  - `0x721fc501d1fe305065dc88da0cf90406a79dfd69`
- FRAX Mintable ERC20 (test)
  - `TQZTkTMbkC9923LtVHZcSrdqcW5rVhkZHP`
  - `0xa00c37011018b4b11cffbbf0305a771d9d4066cf`
- FRAX Ferry
  - `TGxtcNUY9q19FATX3tFxzkmBhQigVDTFJs`
  - `0x4cb9873f50f69f7a3e4dcd5d2fe94c531623a298`

## Optional Setup
Add:
```
function profile() {
  FOUNDRY_PROFILE=$1 "${@:2}"}
```
To easily execute specific foundry profiles like `profile test forge test -w`

## Installation
`pnpm i`

## Compile
`forge build`

## Test
`profile test forge test`

`profile test forge test -w` watch for file changes

`profile test forge test -vvv` show stack traces for failed tests

## Deploy
- Update environment variables where needed
- `source .env`
```
`forge script src/script/{ScriptName}.s.sol \
  --rpc-url ${mainnet || fraxtal || fraxtal_testnet || polygon} \
  --etherscan-api-key {$ETHERSCAN_API_KEY || FRAXSCAN_API_KEY || POLYGONSCAN_API_KEY} \
  --broadcast --verify --watch
```

## Tooling
This repo uses the following tools:
- frax-standard-solidity for testing and scripting helpers
- forge fmt & prettier for code formatting
- lint-staged & husky for pre-commit formatting checks
- solhint for code quality and style hints
- foundry for compiling, testing, and deploying
