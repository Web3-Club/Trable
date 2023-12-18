import { ethers, run } from 'hardhat';

async function main() {
  const AccountHelper = await ethers.getContractFactory('AccountHelper');
  const ac = await AccountHelper.deploy();
  await ac.deployed();

  if (process.env.VERIFY) {
    await run('verify:verify', {
      address: ac.address,
      constructorArguments: [],
    });
  }

  console.log(`AccountHelper address: ${ac.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
