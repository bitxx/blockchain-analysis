var BodhiToken = artifacts.require("./tokens/BodhiToken.sol");
var CrowdsaleBodhiToken = artifacts.require("./tokens/CrowdsaleBodhiToken.sol");
var config = require('../config/config')(web3);

module.exports = function(deployer) {
    deployer.deploy(BodhiToken);
    deployer.deploy(CrowdsaleBodhiToken, config.startBlock, config.endBlock, config.initialExchangeRate,
        config.presaleAmount);
};
