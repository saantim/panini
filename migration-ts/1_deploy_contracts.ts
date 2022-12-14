const FiubaCoin = artifacts.require("FiubaCoin");
const Sticker = artifacts.require("QatarSticker");
const Package = artifacts.require("StickerPackageContract");
const Exchange = artifacts.require("ExchangeOfQatarSticker");

const migrations: Truffle.Migration = (deployer) => {
  deployer.deploy(FiubaCoin);
  deployer.deploy(Sticker);
  deployer.deploy(Package);
  deployer.deploy(Exchange);
};

export default migrations;
