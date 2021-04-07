// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

interface IRewardController {
  function allocatedByPool(address holder) external;
}
