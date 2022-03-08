var truffleAssert = require('truffle-assertions');
var ISK = artifacts.require("./ISK.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var SmartController = artifacts.require("./SmartController.sol");

contract("ISK", accounts => {

  if (web3.version.network <= 100) return;

  let isk;

  beforeEach("setup isk", async () => { 
    isk = await ISK.deployed();
  });

  it("should start with zero tokens", async () => {
    const supply = await isk.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.deployed();
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(ISK.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, ISK.address, "standard controller should be owner");
    await isk.reclaimContract(AcceptingRecipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.deployed();
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(ISK.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(ISK.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(ISK.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await isk.reclaimToken(token.address);
    const balance2 = await token.balanceOf(ISK.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

});
