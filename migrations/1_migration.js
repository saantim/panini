// @ts-nocheck
const FiubaCoin = artifacts.require("FiubaCoin");
const QatanSticker = artifacts.require("QatanSticker");
const QatanStickerExchange = artifacts.require("QatanStickerExchange");
const QatanStickerPackage = artifacts.require("QatanStickerPackage");

module.exports = async function (_deployer) {
  await _deployer.deploy(FiubaCoin);
  await _deployer.deploy(QatanStickerExchange);
  const qatanSticker = await _deployer.deploy(QatanSticker);
  const qatanStickerPackage = await _deployer.deploy(QatanStickerPackage);

  qatanStickerPackage.setCoinAddress(FiubaCoin.address);
  qatanStickerPackage.setStickerAddress(QatanSticker.address);
  qatanSticker.setPackageAddress(QatanStickerPackage.address);
};
