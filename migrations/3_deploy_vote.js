const Vote = artifacts.require("Voting");

module.exports = function (deployer) {
    deployer.deploy(Vote);
};

