const contract= artifacts.require("contract.sol");
const matricula = 20181615;
const pass = 12345;
module.exports = function (deployer) {
  deployer.deploy(contract, matricula, pass);
};