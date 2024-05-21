// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "./Interfaces.sol";

contract Calldata {
  /// @dev Top #1 USDC Holder will be impersonated
  address Alice = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

  /// @dev Stablecoin configurations
  uint256 constant decimalsUSDC = 10 ** 6;
  uint256 constant decimalsDAI = 10 ** 18;
  IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  /// @dev Maker PSM contracts to convert USDC to DAI
  IDssPsm DssPsm = IDssPsm(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A);
  address AuthGemJoin5 = 0x0A59649758aa4d66E25f08Dd01271e891fe52199;

  /// @dev Maker DSR contracts to receive DAI
  IDaiJoin DaiJoin = IDaiJoin(0x9759A6Ac90977b93B58547b4A71c78317f391A28);
  IPot Pot = IPot(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
  IVat Vat = IVat(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);

  /// @dev DaiJoin will multiply the DAI amount by this constant before joining
  uint constant ONE = 10 ** 27;

  // Admin address that will execute the script
  address admin;
  bool executed = false;

  constructor(address _admin) {
    admin = _admin;
  }

  function execute() internal {
    executed = true;

    uint256 balanceOfUSDC = USDC.balanceOf(address(this));
    USDC.approve(AuthGemJoin5, balanceOfUSDC);
    DssPsm.sellGem(address(this), balanceOfUSDC);

    uint256 balanceOfDAI = DAI.balanceOf(address(this));
    DAI.approve(address(DaiJoin), balanceOfDAI);
    DaiJoin.join(address(this), balanceOfDAI);

    Vat.hope(address(Pot));
    uint256 chi = Pot.drip();
    uint256 RAY = 10 ** 27;
    uint wad = mul(amount, RAY) / chi;
    Pot.join(wad);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    require(y == 0 || (z = x * y) / y == x);
  }
}