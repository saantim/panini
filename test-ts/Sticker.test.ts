import { Sticker } from "../shared-ts/utils";
import { QatarStickerInstance } from "../types/truffle-contracts";

contract(Sticker.contractName, function (accounts) {
  let [alice] = accounts;
  let stickerInstance: QatarStickerInstance;
  let owner: string;

  beforeEach(async function () {
    stickerInstance = await Sticker.new();
    owner = await stickerInstance.owner();
    await stickerInstance.setPackageContractAddress(owner);
  });

  it("Start with 0 stickers", async function () {
    const balance = await stickerInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(0);
  });

  it("Create a sticker", async function () {
    const expectedBalance = 1;
    await stickerInstance.createStickers(alice, expectedBalance, {
      from: owner,
    });
    const balance = await stickerInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(expectedBalance);
  });

  it("Create 5 stickers", async function () {
    const expectedBalance = 5;
    await stickerInstance.createStickers(alice, expectedBalance, {
      from: owner,
    });
    const balance = await stickerInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(expectedBalance);
  });

  it("Only allowed address can create stickers", async function () {
    await stickerInstance
      .createStickers(alice, 1, { from: alice })
      .then(() => expect.fail())
      .catch((err) => expect(err));
  });

  it("Get stickers from account", async function () {
    await stickerInstance.createStickers(alice, 5, { from: owner });
    const stickersIds = await stickerInstance.getStickersFromWallet(alice);
    expect(stickersIds.length).to.eq(5);
  });

  it("Get playerId from stickers", async function () {
    await stickerInstance.createStickers(alice, 2, { from: owner });
    const stickersIds = await stickerInstance.getStickersFromWallet(alice);
    const firstPlayerId = await stickerInstance.getPlayerIdFromStickerId(
      stickersIds[0]
    );
    const secondPlayerId = await stickerInstance.getPlayerIdFromStickerId(
      stickersIds[1]
    );
    expect(firstPlayerId).to.not.eq(secondPlayerId);
  });
});
