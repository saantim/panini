import { Package, Coin, Sticker } from "../shared-ts/utils";
import {
  FiubaCoinInstance,
  StickerPackageContractInstance,
} from "../types/truffle-contracts";

contract(Package.contractName, (accounts) => {
  let [alice] = accounts;
  let packageInstance: StickerPackageContractInstance;
  let coinInstance: FiubaCoinInstance;
  let coinPrice: BN;
  const packagePrice = 1;

  beforeEach(async () => {
    packageInstance = await Package.new();
    coinInstance = await Coin.new();
    coinPrice = await coinInstance.mintPrice();
    const stickerInstance = await Sticker.new();

    const owner = await packageInstance.owner();
    await packageInstance.setFiubaCoinAddress(coinInstance.address, {
      from: owner,
    });
    await packageInstance.setPrice(packagePrice, { from: owner });
    await packageInstance.setStickerAddress(stickerInstance.address);
    await stickerInstance.setPackageContractAddress(packageInstance.address);
  });

  it("Start with 0 packages", async () => {
    const balance = await packageInstance.getAmountOfPackagesFrom(alice);
    expect(balance.toNumber()).to.eq(0);
  });

  it("Buy a package", async () => {
    const expectedPackages = 1;
    const amount = expectedPackages * packagePrice;
    await coinInstance.getFiubaCoin(amount, {
      from: alice,
      value: coinPrice.muln(amount),
    });
    await coinInstance.approve(packageInstance.address, amount);
    await packageInstance.buyPackages(expectedPackages, { from: alice });
    const balance = await packageInstance.getAmountOfPackagesFrom(alice);
    expect(balance.toNumber()).to.eq(expectedPackages);
  });

  it("Buy 10 packages", async () => {
    const expectedPackages = 10;
    const amount = expectedPackages * packagePrice;
    await coinInstance.getFiubaCoin(amount, {
      from: alice,
      value: coinPrice.muln(amount),
    });
    await coinInstance.approve(packageInstance.address, amount.toString());
    await packageInstance.buyPackages(expectedPackages, { from: alice });
    const balance = await packageInstance.getAmountOfPackagesFrom(alice);
    expect(balance.toNumber()).to.eq(expectedPackages);
  });

  it("Open a package", async () => {
    const expectedPackages = 9;
    const amount = (expectedPackages + 1) * packagePrice;
    await coinInstance.getFiubaCoin(amount, {
      from: alice,
      value: coinPrice.muln(amount),
    });
    await coinInstance.approve(packageInstance.address, amount.toString());
    await packageInstance.buyPackages(expectedPackages + 1, { from: alice });
    await packageInstance.openPackage({ from: alice });
    const balance = await packageInstance.getAmountOfPackagesFrom(alice);
    expect(balance.toNumber()).to.eq(expectedPackages);
  });

  it("Revert open package when account has no packages", async () => {
    await packageInstance
      .openPackage({ from: alice })
      .then(() => expect.fail())
      .catch((err) => expect(err));
  });
});
