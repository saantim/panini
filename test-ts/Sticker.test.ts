import { Sticker } from "../shared-ts/utils";
import { QatarStickerInstance } from "../types/truffle-contracts";

contract(Sticker.contractName, (accounts) => {
  let [alice] = accounts;
  let stickerInstance: QatarStickerInstance;
  let owner: string;

  beforeEach(async () => {
    stickerInstance = await Sticker.new();
    owner = await stickerInstance.owner();
    await stickerInstance.setPackageContractAddress(owner, { from: owner });
  });

  it("Start with 0 stickers", async () => {
    const balance = await stickerInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(0);
  });

  it("Create a sticker", async () => {
    const expectedBalance = 1;
    await stickerInstance.createStickers(alice, expectedBalance, {
      from: owner,
    });
    const balance = await stickerInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(expectedBalance);
    const ownerOfToken = await stickerInstance.ownerOf(0);
    expect(ownerOfToken).to.eq(alice);
  });

  it("Create 5 stickers", async () => {
    const expectedBalance = 5;
    await stickerInstance.createStickers(alice, expectedBalance, {
      from: owner,
    });
    const balance = await stickerInstance.balanceOf(alice);
    expect(balance.toNumber()).to.eq(expectedBalance);
  });

  it("Only allowed address can create stickers", async () => {
    await stickerInstance
      .createStickers(alice, 1, { from: alice })
      .then(() => expect.fail())
      .catch((err) => expect(err));
  });

  it("Get stickers from account", async () => {
    await stickerInstance.createStickers(alice, 5, { from: owner });
    const stickersIds = await stickerInstance.getStickersFromWallet(alice);
    expect(stickersIds.length).to.eq(5);
  });

  it("Get playerId from stickers", async () => {
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
