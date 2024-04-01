const {
  time,
  loadFixture
} = require('@nomicfoundation/hardhat-network-helpers')
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs')
const { expect } = require('chai')

describe('Token', function () {
  let MyToken
  let myToken
  let owner
  let addr1
  let addr2

  beforeEach(async function () {
    ;[owner, addr1, addr2] = await ethers.getSigners()

    MyToken = await ethers.getContractFactory('MyToken')
    myToken = await MyToken.deploy(
      'My Token',
      'MT',
      ethers.utils.parseEther('1000000')
    )
    await myToken.deployed()
  })

  it('should have correct max cap', async function () {
    expect(await myToken.cap()).to.equal(ethers.utils.parseEther('1000000'))
  })

  it('should mint tokens', async function () {
    await myToken
      .connect(owner)
      .mint(addr1.address, ethers.utils.parseEther('1000'))
    expect(await myToken.balanceOf(addr1.address)).to.equal(
      ethers.utils.parseEther('1000')
    )
  })

  it('should not allow minting above the cap', async function () {
    await expect(
      myToken
        .connect(owner)
        .mint(addr1.address, ethers.utils.parseEther('1000001'))
    ).to.be.reverted
  })

  it('should not allow minting from non-minter', async function () {
    await expect(
      myToken.connect(addr1).mint(addr2.address, ethers.utils.parseEther('100'))
    ).to.be.revertedWith('Caller is not a minter')
  })
})
