# Running tests

## Forge tests

To run the stock shipyard-core tests, just run `forge test` (with the `tutorial` foundry profile active). Forge will notice if you're missing dependencies and install them. It'll compile the contracts if you haven't already done `forge build`. And then it'll run the tests. You'll see stuff like `[PASS] testName() (gas: 28286)` near the end, showing you which tests passed and which failed. And the last line will be something like `Ran 1 test suites: 150 tests passed, 0 failed, 0 skipped (150 total tests)`.

Now switch back to the default foundry profile (`FOUNDRY_PROFILE='default'`) and try tampering with the `Counter.sol` tests or with some of the code they cover to trigger failures. In that case, you'll see something like `[FAIL. Reason: Assertion failed. Counterexample: ...` (for fuzz tests) or `[FAIL. Reason: Assertion failed.]` for normal tests. If you do something the EVM can't cope with at all, you might see `EVM: Revert` `[FAIL. Reason: Index out of bounds]` or something like `[FAIL. Reason: Arithmetic over/underflow]`. You can speed up your cycles by targeting specific tests with [`--match-path` or `match-test`](https://book.getfoundry.sh/forge/tests?highlight=match-path#tests).

And if you're making tweaks steadily and you want Forge to keep running the tests continually without you pressing up and enter over and over, add the `--watch` flag. For example, `forge test --match-test testSomething --watch -vvvv` will run just the test named `testSomething`, it'll rerun every time you save, and it'll show traces for both failing and passing tests.

## Forge ffi tests

If you're writing a custom contract based on ExampleNFT, you'll likely need to write [ffi](https://book.getfoundry.sh/cheatcodes/ffi) tests to make sure it's outputting the json and svg values that you expect.  See [shipyard-core's ffi test setup](https://github.com/ProjectOpenSea/shipyard-core/tree/main/test-ffi) for an example of how to approach ffi testing for this type of purpose.

## Up next:

[Changing the behavior of your NFT](CustomNFTFunctionality.md)