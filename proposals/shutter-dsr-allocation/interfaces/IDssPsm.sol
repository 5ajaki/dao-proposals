// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IDssPsm {
    event BuyGem(address indexed owner, uint256 value, uint256 fee);
    event Deny(address user);
    event File(bytes32 indexed what, uint256 data);
    event Rely(address user);
    event SellGem(address indexed owner, uint256 value, uint256 fee);

    function buyGem(address usr, uint256 gemAmt) external;
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
    function deny(address usr) external;
    function file(bytes32 what, uint256 data) external;
    function gemJoin() external view returns (address);
    function hope(address usr) external;
    function ilk() external view returns (bytes32);
    function nope(address usr) external;
    function rely(address usr) external;
    function sellGem(address usr, uint256 gemAmt) external;
    function tin() external view returns (uint256);
    function tout() external view returns (uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function wards(address) external view returns (uint256);
}
