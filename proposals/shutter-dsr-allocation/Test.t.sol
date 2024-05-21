// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";
import { IDssPsm } from "./interfaces/IDssPsm.sol";

// import interfaces
//  governance contract Shutter
//  ERC20 (USDC, DAI)
//      0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
//      0x6B175474E89094C44Da98b954EedeAC495271d0F
//  Maker PSM
//      0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A
//      0x0A59649758aa4d66E25f08Dd01271e891fe52199
//  Maker DSR (Pot, Vat)
//      0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7
//      0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B

contract Calldata is Test {
    /// @dev Top #1 USDC Holder will be impersonated
    address Alice = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

    // AmountInUSDamountInUSD to be converted
    uint256 amountInUSD = 3_000_000;

    /// @dev Stablecoin configurations
    uint256 constant decimalsUSDC = 10 ** 6;
    uint256 constant decimalsDAI = 10 ** 18;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    /// @dev Maker PSM contract
    IDssPsm DssPsm = IDssPsm(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A);
    address AuthGemJoin5 = 0x0A59649758aa4d66E25f08Dd01271e891fe52199;

    /// @dev Maker DSR contract
    address Pot = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address Vat = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address Vow = 0xA950524441892A31ebddF91d3cEEFa04Bf454466;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        vm.startPrank(Alice);
    }

    /// @dev Basic test. Run it with `yarn test:fork` to see the console log.
    function test_convertToDAI() external {
        // Approve PSM to spend USDC {ERC20-approve}
        bytes memory approveUSDC = abi.encodeWithSelector(0x095ea7b3, AuthGemJoin5, amountInUSD * decimalsUSDC);
        (bool success,) = USDC.call(approveUSDC);
        require(success, "USDC.approve failed");

        // Convert USDC to DAI {DssPsm-sellGem}
        bytes memory sellGem = abi.encodeWithSelector(DssPsm.sellGem.selector, Alice, amountInUSD * decimalsUSDC);
        (success,) = address(DssPsm).call(sellGem);
        require(success, "PSM.sellGem failed");

        // BalanceOf DAI {ERC20-balanceOf}
        bytes memory balanceOf = abi.encodeWithSelector(0x70a08231, Alice);
        bytes memory daiBalance;
        (success, daiBalance) = DAI.staticcall(balanceOf);
        require(success, "DAI.balanceOf failed");
        uint256 daiBalanceAfter = abi.decode(daiBalance, (uint256));

        // Assert increased balance of DAI
        assertEq(daiBalanceAfter, amountInUSD * decimalsDAI);

        // Approve Pot to spend DAI {ERC20-approve}
        bytes memory approve = abi.encodeWithSelector(0x095ea7b3, Pot, amountInUSD * decimalsDAI);
        (success,) = DAI.call(approve);
        require(success, "DAI.approve failed");

        // Hope to join Vat {Vat-hope}
        bytes memory hope = abi.encodeWithSelector(0xa3b22fc4, Pot);
        (success,) = Vat.call(hope);
        require(success, "Vat.hope failed");

        // Drip DAI {Pot-drip}
        bytes memory drip = abi.encodeWithSelector(0x9f678cca);
        bytes memory response;
        (success, response) = Pot.call(drip);
        require(success, "Pot.drip failed");
        uint256 chi = abi.decode(response, (uint256));

        // Join with DAI {Pot-join}
        uint256 RAY = 10 ** 27;
        bytes memory join = abi.encodeWithSelector(0x049878f3, mul(amountInUSD, RAY) / chi);
        (success,) = Pot.call(join);
        require(success, "Pot.join failed");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }
}
