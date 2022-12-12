const FiubaCoin = artifacts.require("FiubaCoin");
const expect = require("chai").expect;

contract("FiubaCoin", (accounts) => {
    let [alice, bob] = accounts;
    let contractInstance;
    beforeEach(async() => {
        contractInstance = await FiubaCoin.new();
    })
    it("start with 0 coins", async () => {
        const result = await contractInstance.balanceOf(alice, {from: alice});
        assert.equal(result, 0);
    });
});