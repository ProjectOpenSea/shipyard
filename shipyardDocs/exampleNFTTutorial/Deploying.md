# Deploying for real

- [Getting your head into the code](ERC721Concepts.md)
- [Setting up your environment](EnvironmentSetup.md)
- [Running tests](Testing.md)
- [Changing the behavior of your NFT](CustomNFTFunctionality.md)
- [Testing](Testing.md)
- [Deploying for real](Deploying.md)

OK, here's the big moment. Now that you've [gotten your head into ERC721s](ERC721Concepts.md), [set up your environment](EnvironmentSetup.md), [ran some tests](Testing.md), [made your custom contract](CustomNFTFunctionality.md), ideally tested its exciting new functionality, and now it's time to deploy. The process is basically identical to the example from earlier.

```
forge create --rpc-url $ETH_RPC_URL \
    --private-key $MY_ACTUAL_PK_BE_CAREFUL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify \
    src/Dockmaster.sol:Dockmaster \
    --constructor-args "Dockmaster NFT" "DM"
```

Forge compiles (or skips compiling bc you've got a clean build from all those tests you ran, right? right?),  logs the address you deployed from, shows the transaction hash of the deployment transaction, and then automatically verifies the contract on Etherscan. It's definitely worth configuring your Etherscan API key and getting verification over with at this phase. It's way easier to do in Forge than in the Etherscan UI.

And that's it! 

## Optional bonus step: deploying to a hip, gas-efficient address

Ever notice how Seaport is deployed to [an address](https://etherscan.io/address/0x00000000000000adc04c56bf30ac9d3c0aaf14dc) that starts with a bunch of `0`s? Ever wonder how that works? Ever wonder why?

The short version of "why?" is simple: gas efficiency. The technical nuance of "why?" is meatier, but the heart of it lies in the fact that Ethereum charges you less for schlepping a zero around than for a non-zero. Check out [this article by 0age](https://medium.com/coinmonks/on-efficient-ethereum-addresses-3fef0596e263) and [this article by 0xfoobar](https://0xfoobar.substack.com/p/vanity-addresses) if your interest is piqued.

So, want to deploy your own contract to a cool address instead of just taking what you get? Fortunately, it's pretty straightforward.

### Get create2crunch

We'll be using [create2crunch](https://github.com/0age/create2crunch) to "mine" a vanity address. Go to [https://github.com/0age/create2crunch](https://github.com/0age/create2crunch), read the docs, and clone the repo.

### Get set up

First, `cd` into your local create2crunch repo. Then, you'll need to set up your environment variables. The create2crunch repo recommends doing this from the comand line, but I recommend setting up a .env file. Initially, it should looks like this:

```
export FACTORY="0x0000000000FFe8B47B3e2130213B802212439497"
export CALLER="<your_deployer_address>"
export INIT_CODE=""
export INIT_CODE_HASH=""
```

Now, we need to generate the value for that `INIT_CODE_HASH` variable, which will be a three step process:

- Refresh your `out/` directory
- Find the contract's deployment bytecode
- Hash it

First, clear out the contents of your `out` directory by running `rm -rf out/*`. Then run `forge clean && forge build` to repopulate it.

Next, we'll find the bytecode buried deep in a big, dense file in our NFT directory. For me, the command to run is `cat out/Dockmaster.sol/Dockmaster.json`. For you, it'll be analogous, but with your NFT contract name swapped in. Then I `cmd` + `f` for `"bytecode"` (note: make sure you're getting the bytecode used for deployment and not the `deployedBytecode`, which lacks constructor arguments, if they exist). We want to grab the whole massive `bytecode` hex string and set it as the value of our `INIT_CODE` variable.

Then, source the `.env` file and run `cast keccak $INIT_CODE`. It should print a 32 byte value in response. Set that as the value of `INIT_CODE_HASH`, and then source your .env again.

### Mining

Now that everything's configured, mining is as simple as running `cargo run --release $FACTORY $CALLER $INIT_CODE_HASH 2 2 4` and waiting. You should get a hit almost instantly, since that command accepts addresses that have 2 leading or 4 total zeroes.

As soon as you get a hit, take it over to [the create2 factory](https://etherscan.io/address/0x0000000000FFe8B47B3e2130213B802212439497) and check that it's working. Call the `findCreate2Address` (not `findCreate2AddressViaHash`) with the `salt` provided by create2crunch. The output from create2crunch will look like this:

```
0x22...26 => 0x0000F5f864d1cc53dC66efE16B98ceeC2c497695 => 0 (2 / 2)
0x22...ff => 0x0000aE343783fcDF5f8Fc7d00C5b082136177048 => 0 (2 / 2)
0x22...4c => 0x00008E5917BDa2fd65cBF0E1705403f1bd5C512C => 0 (2 / 2)
0x22...26 => 0x0000389A4A66fD7AA80221b8D193ae6B478c4c17 => 0 (2 / 2)
```

Paste one of those 32 byte salts from the left column into the `salt` field and the full `$INIT_CODE` value into the `initCode` field, then click the "Query" button. If things are working as expected, when you paste in the `0x22...ff` salt, you'll get the `0x0000aE343783fcDF5f8Fc7d00C5b082136177048` address as a response. If you get some other address, you need to double check all your values and configuration end to end.

Once you're reasonably confident that everything is working as expected, you can run the command with jacked up expectations: `cargo run --release $FACTORY $CALLER $INIT_CODE_HASH 2 4 6`. You might have to wait longer, but you'll get better results.

Remember that if you make any changes once you're sitting around waiting to for a super cool address, you'll need to reset your `$INIT_CODE` and `$INIT_CODE_HASH` values.

### Deploying like a cool kid

Once you've got a salt that produces a deploy address you're happy with, deploying is as simple as going to [the "Write Contract" tab](https://etherscan.io/address/0x0000000000FFe8B47B3e2130213B802212439497#writeContract), and calling the `safeCreate2` function with your preferred salt and `initCode`. You don't have to enter anything in the top field (unless you decided to do payable constructor for some reason).

Since you're fluent with the Foundry toolset now, you could also use [`cast send`](https://book.getfoundry.sh/reference/cast/cast-send?highlight=cast%20send#cast-send) to send the transaction from the command line:

```
cast send 0x0000000000FFe8B47B3e2130213B802212439497 "safeCreate2(bytes32, bytes)" 0x... 0x...
```

Finally, verify your contract [on Etherscan](https://etherscan.io/verifyContract) or [using Forge](https://book.getfoundry.sh/forge/deploying?highlight=verify#verifying-a-pre-existing-contract).

To be clear, this is mostly about the cool factor. But it also gives you gas efficiency benefits, sceurity benefits, cross-chain consistency, and more. And since you know the address before you deploy, you can code it into your frontend, etc. before you've revealed it to the rest of the world.

## Back to the table of contents

[Take it from the top](Overview.md)