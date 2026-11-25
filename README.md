# Document Notary

An on-chain registry that timestamps document hashes in a separate namespace for each author.

## How it works

1. Hash the exact document bytes off-chain with Keccak-256.
2. Call `register(digest)` from the address that should be associated with those bytes.
3. Read `entries(author, digest)` to verify registration and its block timestamp.

The registry records a claim by an address. Anyone holding the same bytes can make their own claim. Store the original document off-chain.

## Build and test

Install [Foundry](https://getfoundry.sh/) and run these commands from this directory. Forge selects Solidity 0.8.36 from `foundry.toml`. The project has no third-party Solidity dependencies.

```bash
forge build
forge test -vv
forge coverage --exclude-tests
```

## Local deployment

Start a fresh `anvil` node in a separate terminal. Deploy with the first unlocked account on that local node.

```bash
export RPC_URL=http://127.0.0.1:8545
export ANVIL_ACCOUNT=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
forge create src/DocumentNotary.sol:DocumentNotary --rpc-url "$RPC_URL" --from "$ANVIL_ACCOUNT" --unlocked --broadcast
```

## Local example

Set `CONTRACT` to the address printed by `forge create` and keep using the same terminal.

```bash
export ETH_RPC_URL="$RPC_URL"
CONTRACT=0x... # Replace with your deployed address.
DIGEST=$(cast keccak "sample document")
cast send "$CONTRACT" 'register(bytes32)' "$DIGEST" --from "$ANVIL_ACCOUNT" --unlocked
cast call "$CONTRACT" 'entries(address,bytes32)(bool,uint256)' "$ANVIL_ACCOUNT" "$DIGEST"
```

## Test cases

Foundry reports 4 passing tests and 100% coverage on contract lines, statements, branches and functions.

- Independent registrations for the same digest, timestamp retrieval and event payload.
- Empty and duplicate digest rejection.
- Fuzzed round trips for nonzero digests.
