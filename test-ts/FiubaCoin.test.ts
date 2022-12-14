const FiubaCoin = artifacts.require("FiubaCoin");
import { expect } from "chai";
import { toWei } from "web3-utils";
import { FiubaCoinInstance } from "../types/truffle-contracts";

contract("FiubaCoin", function (accounts) {
  let [alice] = accounts;
  let contractInstance: FiubaCoinInstance;

  beforeEach(async function () {
    contractInstance = await FiubaCoin.new();
  });

  it("Start with 0 coins", async function () {
    const balance = await contractInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(0);
  });

  it("Buy 1 coin", async function () {
    const expectedCoins = 1;
    await contractInstance.getFiubaCoin(expectedCoins, {
      from: alice,
      value: toWei("0.001", "ether"),
    });
    const balance = await contractInstance.balanceOf(alice);
    const decimals = await contractInstance.decimals();
    const expectedBalance = expectedCoins * 10 ** decimals.toNumber();
    expect(balance.toString()).to.eq(expectedBalance.toString());
  });
});
