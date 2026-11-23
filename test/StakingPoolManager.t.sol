
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./../src/backend/contracts/StakingPoolManager.sol";
import "./../src/backend/contracts/StakingPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingPoolManagerTest is Test {
    StakingPoolManager manager;

    MockERC20 stakedToken;
    MockERC20 rewardToken;

    address owner = address(1);
    address alice = address(2);
    address bob = address(3);

    uint256 rewardPerBlock = 1 ether;
    uint256 rewardStartBlock;
    uint256 rewardEndBlock;

    event CreateStakingPool(
        address indexed user,
        address stakingPool
    );

    function setUp() public {
        manager = new StakingPoolManager();

        stakedToken = new MockERC20("Staked Token", "STK");
        rewardToken = new MockERC20("Reward Token", "RWD");

        rewardStartBlock = block.number + 10;
        rewardEndBlock = block.number + 1000;
    }

    // ============================================
    // TEST 1: Create staking pool successfully
    // ============================================

    function test_CreateStakingPoolSuccessfully() public {
        vm.prank(owner);

        StakingPool pool = manager.createStakingPool(
            stakedToken,
            rewardToken,
            rewardPerBlock,
            rewardStartBlock,
            rewardEndBlock
        );

        assertTrue(address(pool) != address(0));
        assertGt(address(pool).code.length, 0);
    }

    // ============================================
    // TEST 2: Pool ownership transferred to caller
    // ============================================

    function test_PoolOwnershipTransferredToCaller() public {
        vm.prank(alice);

        StakingPool pool = manager.createStakingPool(
            stakedToken,
            rewardToken,
            rewardPerBlock,
            rewardStartBlock,
            rewardEndBlock
        );

        assertEq(pool.owner(), alice);
    }

    // ============================================
    // TEST 3: Pool registered in factory
    // ============================================

    function test_PoolAddedToStakingPools() public {
        vm.prank(alice);

        StakingPool pool = manager.createStakingPool(
            stakedToken,
            rewardToken,
            rewardPerBlock,
            rewardStartBlock,
            rewardEndBlock
        );

        assertEq(manager.stakingPools(0), address(pool));
    }

    // ============================================
    // TEST 4: Multiple pools can be created
    // ============================================

    function test_CreateMultipleStakingPools() public {
        vm.startPrank(alice);

        StakingPool pool1 = manager.createStakingPool(
            stakedToken,
            rewardToken,
            rewardPerBlock,
            rewardStartBlock,
            rewardEndBlock
        );

        StakingPool pool2 = manager.createStakingPool(
            stakedToken,
            rewardToken,
            rewardPerBlock,
            rewardStartBlock,
            rewardEndBlock
        );

        vm.stopPrank();

        assertTrue(address(pool1) != address(pool2));
        assertEq(manager.stakingPools(0), address(pool1));
        assertEq(manager.stakingPools(1), address(pool2));
    }

    // ============================================
    // TEST 5: Different callers own their pools
    // ============================================

    function test_DifferentCallersOwnTheirPools() public {
        vm.prank(alice);

        StakingPool pool1 = manager.createStakingPool(
            stakedToken,
            rewardToken,
            rewardPerBlock,
            rewardStartBlock,
            rewardEndBlock
        );

        vm.prank(bob);

        StakingPool pool2 = manager.createStakingPool(
            stakedToken,
            rewardToken,
            rewardPerBlock,
            rewardStartBlock,
            rewardEndBlock
        );

        assertEq(pool1.owner(), alice);
        assertEq(pool2.owner(), bob);
    }
}
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
    {}
}