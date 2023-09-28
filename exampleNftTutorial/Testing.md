# Running tests

## Forge tests

To run the stock shipyard-core tests, just switch to the `tutorial` Foundry profile (`export FOUNDRY_PROFILE='tutorial'`) and run `forge test`. Forge will notice if you're missing dependencies and install them. It'll compile the contracts if you haven't already done `forge build`. And then it'll run the tests. You'll see stuff like `[PASS] testName() (gas: 28286)` near the end, showing you which tests passed and which failed. And the last line will be something like `Ran 1 test suites: 150 tests passed, 0 failed, 0 skipped (150 total tests)`.

The [shipyard-core tests](https://github.com/ProjectOpenSea/shipyard-core/tree/main/test) test that the functionality we inherited through `AbstractNFT` works as expected. You can run them because it's interesting and you can reference them for ideas on writing tests, but they're not directly pertinent to Dockmaster.

To run the Dockmaster-specific tests, switch back to the default foundry profile (`FOUNDRY_PROFILE='default'`) and try tampering with the `Dockmaster.sol` tests or with some of the code they cover. Try to trigger some failures. When you succeed, you'll see something like `[FAIL. Reason: Assertion failed. Counterexample: ...` (for fuzz tests) or `[FAIL. Reason: Assertion failed.]` for normal tests. If you do something the EVM can't cope with at all, you might see `EVM: Revert` `[FAIL. Reason: Index out of bounds]` or something like `[FAIL. Reason: Arithmetic over/underflow]`. You can speed up your cycles by targeting specific tests with [`--match-path` or `match-test`](https://book.getfoundry.sh/forge/tests?highlight=match-path#tests).

And if you're making tweaks steadily and you want Forge to keep running the tests continually without you pressing up and enter over and over, add the `--watch` flag. For example, `forge test --match-test testSomething --watch -vvvv` will run just the test named `testSomething`, it'll rerun every time you save, and it'll show traces for both failing and passing tests.

## Forge ffi tests

If you're writing a custom contract based on ExampleNFT, you'll likely need to write [ffi](https://book.getfoundry.sh/cheatcodes/ffi) tests to make sure it's outputting the json and svg values that you expect.  See [shipyard-core's ffi test setup](https://github.com/ProjectOpenSea/shipyard-core/tree/main/test-ffi) for an example of how to approach ffi testing for this type of purpose.

### Testing your custom functionality with `ffi`

Currently, the ffi tests are the only way to test the output of Dockmaster's tokenURI response.

In general, it's wise to be especially wary of ffi code. In the words of the Foundrybook, "It is generally advised to use this cheat code as a last resort, and to not enable it by default, as anyone who can change the tests of a project will be able to execute arbitrary commands on devices that run the tests."

There's nothing to be worried about in this case, but you should still be vigilant.

### Environment configuration

To run the ffi tests locally, set `FOUNDRY_PROFILE='ffi'` in your `.env` file, and then source the `.env` file. Using the `ffi` profile will permit Forge to make foreign calls (`ffi = true`) and read and write within the `./test-ffi/` directory (`fs_permissions = [{ access = 'read-write', path = './test-ffi/' }]`). It also tells Forge to run the tests in the `./test-ffi/` directory (`test = 'test-ffi'`) instead of the tests in the `./test/` directory, which are run by default.

Check out the `foundry.toml` file, where all of this and more is configured.

Both the local profile (`profile.ffi`) and the CI profile (`profile.ci-ffi`) for the ffi tests use a low number of fuzz runs, because the ffi lifecycle is slow. Before yeeting a project to mainnet, it's advisable to crank up the number of fuzz runs to increase the likelihood of catching an issue. It'll take more time, but it increases the likelihood of catching an issue.

### Expected local behavior

The `Dockmaster.t.sol` file will call `Dockmaster.sol`'s `tokenURI` function, decode the base64 encoded response, write the decoded version to `./test-ffi/tmp/temp.json`, and then call the `process_json.js` file a few times to get string values. If the expected values and the actual values match, the test will pass and the files will be cleaned up. If they fail, a `temp-*.json` file will be left behind for reference. You can ignore it or delete it after you're done inspecting it. Forge makes a new one on the fly if it's not there. And it's ignored in the `.gitignore` file, so there's no need to worry about pushing cruft or top secret metadata to a shared/public repo.

The `ValidateDockmasterSvg.t.sol` file behaves along similar lines, but it checks that the contract is churning out valid svg.

## Up next:

[Changing the behavior of your NFT](CustomNFTFunctionality.md)