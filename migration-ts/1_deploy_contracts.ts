import { Coin, Sticker, Package, Exchange } from "../shared-ts/utils";

const migrations: Truffle.Migration = (deployer) => {
  deployer.deploy(Coin);
  deployer.deploy(Sticker);
  deployer.deploy(Package);
  deployer.deploy(Exchange);
};

export default migrations;
