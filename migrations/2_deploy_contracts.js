/* eslint-disable no-undef */
const FiubaCoin = artifacts.require("FiubaCoin");
const QatanStickerExchange = artifacts.require("QatanStickerExchange");

module.exports = async function (_deployer) {
  _deployer.deploy(FiubaCoin);
  _deployer.deploy(QatanStickerExchange);
};
