import { Package, Coin } from "../shared-ts/utils";
import {
  FiubaCoinInstance,
  StickerPackageContractInstance,
} from "../types/truffle-contracts";

contract(Package.contractName, function (accounts) {
  let [alice] = accounts;
  let packageInstance: StickerPackageContractInstance;
  let coinInstance: FiubaCoinInstance;
  let coinPrice: BN;
  const packagePrice = 1;

  beforeEach(async function () {
    packageInstance = await Package.new();
    coinInstance = await Coin.new();
    coinPrice = await coinInstance.mintPrice();

    const owner = await packageInstance.owner();
    await packageInstance.setFiubaCoinAddress(coinInstance.address, {
      from: owner,
    });
    await packageInstance.setPrice(packagePrice, { from: owner });
  });

  it("Start with 0 packages", async function () {
    const balance = await packageInstance.getAmountOfPackagesFrom(alice);
    expect(balance.toNumber()).to.eq(0);
  });

  it("Buy a package", async function () {
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

  it("Buy 10 packages", async function () {
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
});
