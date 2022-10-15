const Panini = artifacts.require("Panini");

module.exports = function (deployer) {
    deployer.deploy(Panini);
}