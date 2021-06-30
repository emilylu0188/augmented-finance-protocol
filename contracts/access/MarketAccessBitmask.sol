// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.12;

import 'hardhat/console.sol';
import {IERC20} from '../dependencies/openzeppelin/contracts/IERC20.sol';
import {SafeERC20} from '../dependencies/openzeppelin/contracts/SafeERC20.sol';
import {IMarketAccessController} from './interfaces/IMarketAccessController.sol';
import {AccessHelper} from './AccessHelper.sol';
import {AccessFlags} from './AccessFlags.sol';
import {Errors} from '../tools/Errors.sol';

contract MarketAccessBitmask {
  using AccessHelper for IMarketAccessController;
  IMarketAccessController internal _remoteAcl;

  constructor(IMarketAccessController remoteAcl) internal {
    _remoteAcl = remoteAcl;
  }

  function _getRemoteAcl(address addr) internal view returns (uint256) {
    return _remoteAcl.getAcl(addr);
  }

  function hasRemoteAcl() internal view returns (bool) {
    return _remoteAcl != IMarketAccessController(0);
  }

  function acl_hasAllOf(address subject, uint256 flags) internal view returns (bool) {
    return _remoteAcl.hasAllOf(subject, flags);
  }

  modifier aclHas(uint256 flags) virtual {
    require(_remoteAcl.hasAllOf(msg.sender, flags), 'access is restricted');
    _;
  }

  modifier aclAllOf(uint256 flags) {
    require(_remoteAcl.hasAllOf(msg.sender, flags), 'access is restricted');
    _;
  }

  modifier aclNoneOf(uint256 flags) {
    require(_remoteAcl.hasNoneOf(msg.sender, flags), 'access is restricted');
    _;
  }

  modifier aclAnyOf(uint256 flags) {
    require(_remoteAcl.hasAnyOf(msg.sender, flags), 'access is restricted');
    _;
  }

  modifier aclAny() {
    require(_remoteAcl.hasAny(msg.sender), 'access is restricted');
    _;
  }

  modifier aclNone() {
    require(_remoteAcl.hasNone(msg.sender), 'access is restricted');
    _;
  }

  modifier onlyPoolAdmin {
    require(_remoteAcl.isPoolAdmin(msg.sender), Errors.CALLER_NOT_POOL_ADMIN);
    _;
  }

  modifier onlyEmergencyAdmin {
    require(_remoteAcl.isEmergencyAdmin(msg.sender), Errors.CALLER_NOT_EMERGENCY_ADMIN);
    _;
  }

  modifier onlyRewardAdmin {
    require(
      _remoteAcl.hasAllOf(msg.sender, AccessFlags.REWARD_CONFIG_ADMIN),
      Errors.CALLER_NOT_REWARD_ADMIN
    );
    _;
  }
}