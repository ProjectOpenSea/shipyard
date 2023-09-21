# Setting up your environment

## Initial dev environment setup

First, you'll need to create a new directory and `cd` into it:
```
mkdir my-shipyard-based-project &&
cd my-shipyard-based-project
```

Install the `foundryup` up command and run it, which in turn installs forge, cast, anvil, and chisel:
```
curl -L https://foundry.paradigm.xyz | bash &&
foundryup
```

Create a new Foundry project based on Shipyard, which also initializes a new git repository.
```
forge init --template projectopensea/shipyard
```

Run `forge build` to install depencencies and compile the contracts. This will also create an populate the `out` and `cache` directories at the top level of the project.
```
forge build
```

## Deployment environment setup

Then, check out [Foundrybook's take on deploying](https://book.getfoundry.sh/forge/deploying).

And then check out the `sample.env` file. You can see how the environment variables would fit into a command like this:

```
forge create --rpc-url $GOERLI_RPC_URL \
    --private-key $MY_ACTUAL_PK_BE_CAREFUL \
    src/reference/ExampleNFT.sol:ExampleNFT \
    --constructor-args "Tutorial Example NFT" "TENFT"
```

I mean, you could just make a `.env` file based on the sample, source it (`. .env` or `source .env`), and run that command. You could be an NFT creator in like the next 3 minutes. Forge would compile the necessary files (`Compiler run successful!`), log the address you deployed from (`Deployer: <your_address>`), show you the transaction hash of the deployment transaction (`Transaction hash: 0x...`). You'd have a contract to your name. You'd be able to link your friends and coworkers to it on Etherscan. You could even yeet a contract straight to mainnet just by switching out `$GOERLI_RPC_URL` with `$ETH_RPC_URL`!

Alternatively, instead of running the `forge create` command above, you could run `forge script script/Deploy.s.sol:Deploy --rpc-url $ETH_RPC_URL --broadcast -vvvv`, which would also result in an example contract being deployed.

But hold out, it's not time yet! Or go ahead, we're not the deploy police. But you'll definitely feel better about the contract if you run some test, make some innovative or at least fun changes, write some new tests, run them some more, and *then* deploy. Or do it right now. It's comforting to know that it actually works before you invest real time. For real, doing something at your terminal and then seeing a corresponding change on a block explorer is magical. Do it! Or don't. Either way.

## Testing environment setup

Anyway, let's take a look at the portion of the `sample.env` file that's pertinent to testing.

The `FOUNDRY_PROFILE='tutorial'` line selects the `tutorial` profile from shipyard's `foundry.toml` file, which will allow you to run shipyard-core's tests from the shipyard directory.

`FOUNDRY_VERBOSITY=3` is like running your tests with the `-vvv` flag all the time. It's usually the exact sweet spot. When tests pass, they're not going to spam you with stack traces, but when they fail, you'll likely have all the info you need to debug.

`FOUNDRY_FUZZ_RUNS=128` means that [fuzz tests](https://book.getfoundry.sh/forge/fuzz-testing) will run 128 times each, with Foundry picking randomish numbers for each run.

## Next up: 

[Running tests](Testing.md)