import { Exchange } from "../shared-ts/utils";
import { ExchangeOfQatarStickerInstance } from "../types/truffle-contracts";

contract(Exchange.contractName, (accounts) => {
  let [alice, bob] = accounts;
  let owner: string;
  let exchangeInstance: ExchangeOfQatarStickerInstance;

  beforeEach(async () => {
    exchangeInstance = await Exchange.new();
    owner = await exchangeInstance.owner();
    await exchangeInstance.setPackageContractAddress(owner);
  });

  it("Start with 0 exchanges", async () => {
    const balance = await exchangeInstance.activeExchanges();
    expect(balance.toNumber()).to.eq(0);
  });

  it("Create an exchange", async () => {
    await exchangeInstance.createStickers(alice, 1, { from: owner });
    await exchangeInstance.iWantToExchange(0, 1, { from: alice });
    const balance = await exchangeInstance.activeExchanges();
    expect(balance.toNumber()).to.eq(1);
    const exchangeIds = await exchangeInstance.getAllExchanges();
    expect(exchangeIds[0].toNumber()).to.eq(0);
  });

  it("Can't create exchange with token account doesn't own", async () => {
    await exchangeInstance.createStickers(alice, 1, { from: owner });
    await exchangeInstance
      .iWantToExchange(0, 1, { from: bob })
      .then(() => expect.fail())
      .catch((err) => expect(err));
  });

  it("Accept an exchange", async () => {
    await exchangeInstance.createStickers(alice, 1, { from: owner });
    await exchangeInstance.createStickers(bob, 1, { from: owner });
    const playerId = await exchangeInstance.getPlayerIdFromStickerId(1);
    await exchangeInstance.iWantToExchange(0, playerId, {
      from: alice,
    });
    await exchangeInstance.acceptExchange(0, { from: bob });
    const balance = await exchangeInstance.activeExchanges();
    expect(balance.toNumber()).to.eq(0);

    const ownerOfToken0 = await exchangeInstance.ownerOf(0);
    const ownerOfToken1 = await exchangeInstance.ownerOf(1);
    expect(ownerOfToken0).to.eq(bob);
    expect(ownerOfToken1).to.eq(alice);
  });

  it("Exchange is valid once", async () => {
    await exchangeInstance.createStickers(alice, 1, { from: owner });
    await exchangeInstance.createStickers(bob, 1, { from: owner });
    const playerId = await exchangeInstance.getPlayerIdFromStickerId(1);
    await exchangeInstance.iWantToExchange(0, playerId, {
      from: alice,
    });
    await exchangeInstance.acceptExchange(0, { from: bob });
    await exchangeInstance.iWantToExchange(0, playerId, {
      from: bob,
    });
    await exchangeInstance.acceptExchange(1, { from: alice });
    await exchangeInstance
      .acceptExchange(0, { from: bob })
      .then(() => expect.fail())
      .catch((err) => expect(err));
  });
});
