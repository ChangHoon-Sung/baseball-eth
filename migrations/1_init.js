// https://medium.com/haloblock/deploy-your-own-smart-contract-with-truffle-and-ganache-cli-beginner-tutorial-c46bce0bd01e
// https://github.com/trufflesuite/truffle/issues/4620#issuecomment-1012784976
https: var baseball = artifacts.require("GameManager");
module.exports = function (deployer, network, accounts) {
  const creatorAddress = "0xE0a68584111D702a141beCB6692631F1Dae4711f";
  deployer.deploy(baseball, { from: creatorAddress });
  //   const param = 123456;
  //   deployer.deploy(contract_name, param, { from: creatorAddress }); // https://trufflesuite.com/docs/truffle/how-to/contracts/run-migrations/#deployerdeploycontract-args-options
};
