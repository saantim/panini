import { expect } from "chai";
import { toWei } from "web3-utils";
import { Coin } from "../shared-ts/utils";
import { FiubaCoinInstance } from "../types/truffle-contracts";

contract(Coin.contractName, (accounts) => {
  let [alice] = accounts;
  let contractInstance: FiubaCoinInstance;
  let price: BN;

  beforeEach(async () => {
    contractInstance = await Coin.new();
    price = await contractInstance.mintPrice();
  });

  it("Start with 0 coins", async () => {
    const balance = await contractInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(0);
  });

  it("A coin has a price setted", async () => {
    const expectedPrice = toWei("0.001", "ether");
    expect(price.toString()).to.eq(expectedPrice);
  });

  it("Buy a coin", async () => {
    const expectedBalance = 1;
    await contractInstance.getFiubaCoin(expectedBalance, {
      from: alice,
      value: price,
    });
    const balance = await contractInstance.balanceOf(alice);
    expect(balance.toString()).to.eq(expectedBalance.toString());
  });

  it("Buy many coins", async () => {
    const expectedBalance = 10;
    await contractInstance.getFiubaCoin(expectedBalance, {
      from: alice,
      value: price.muln(10),
    });
    const balance = await contractInstance.balanceOf(alice);
    expect(balance.toString()).to.eq(expectedBalance.toString());
  });

  it("A coin has no decimals", async () => {
    const decimals = await contractInstance.decimals();
    expect(decimals.toNumber()).to.eq(0);
  });
});
