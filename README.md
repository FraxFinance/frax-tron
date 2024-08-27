# Frax Tron

## Resources
- https://tronscan.org
- https://www.btcschools.net/tron/tron_tool_base58check_hex.php
  - Ignore the "41" at the start when decoding Base58
- [Chain ID](https://github.com/tronprotocol/tips/blob/master/tip-474.md)
  - 728126428

## Addresses
### Official
- FRAX:
  - TRC20: `TArMTLyihUsuscLtL3hzrFF65r8NbWkW9f` / `0x09Ac453B58d3eE843675bf0C8B35BFf5eDA46276`
  - Ferry (Tron): `TTzFDbwrJ1Rp7kQ4JaiBHKWGxCVEe1TJ7p`
  - Ferry (Fraxtal): `0xDFb69DaB5F26FbF721E05dEa82aBb9e809AE080B`

- sFRAX:
  - TRC20: `TDsivFeAJ9pPWJEWvrWotXYiqY85s1EYW4` / `0x2AD6FB1eaF3702485071c2cB8C634015BEBC8b3A`
  - Ferry (Tron): `TTin8JYkKZte3FPVFixXA5jo2QhZe4jp3p`
  - Ferry (Fraxtal): `0x07F6ef67AA9b58f81Aa3aC92f3e7Fd2b93F31efc`

- FXS:
  - TRC20: `TAJgjCjWSQUzkLfxRWU4q2smEBMGZCeWfL` / `0x03af0c5cecfb2d1e78158e6946be8a54a99cc6cc`
  - Ferry (Tron): `TMtpW4xRFzM45vU2fUpbD3p1GtzobcZYnq`
  - Ferry (Fraxtal): `0x45C55fb1805d8AC7E5Ba0F933cB7D4Da0Dabd365`

### Multisig / Minter
- [TNpqBqghn37FLcpWWQVcRAxuBvhUYu2FEB](https://tronscan.org/#/address/TNpqBqghn37FLcpWWQVcRAxuBvhUYu2FEB/permissions?anchorName=anchor_permission_owner&time=1724793291259)


### Test
#### Tron
- Deployer / Authorized Minter
  - `TLNe6KF1dUSYBcZ4fzTstoKB8bkzQewz42`
- FRAX Mintable ERC20 (test)
  - `TQZTkTMbkC9923LtVHZcSrdqcW5rVhkZHP`
- FRAX Ferry
  - `TGxtcNUY9q19FATX3tFxzkmBhQigVDTFJs`

### Fraxtal
- Deployer / Ferry owner
  - `0xb0E1650A9760e0f383174af042091fc544b8356f`
- FRAX Ferry
  - `0xa5677a5bF6e8759D3C904d2da85D1318E398cf3A`

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
