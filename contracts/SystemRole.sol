/* SPDX-License-Identifier: apache-2.0 */
/**
 * Copyright 2019 Monerium ehf.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity 0.8.11;

//import "openzeppelin-solidity/contracts/access/rbac/Roles.sol";
//import "@openzeppelin/contracts/access/Roles.sol";

/**
 * This has been pasted here to enable compilation
 * before futher talk about re-implementation.
 *
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}


/**
 * @title SystemRole
 * @dev SystemRole accounts have been approved to perform operational actions (e.g. mint and burn).
 * @notice addSystemAccount and removeSystemAccount are unprotected by default, i.e. anyone can call them.
 * @notice Contracts inheriting SystemRole *should* authorize the caller by overriding them.
 * @notice The contract is an abstract contract.
 */
abstract contract SystemRole {

  using Roles for Roles.Role;
  Roles.Role private systemAccounts;

    /**
     * @dev Emitted when system account is added.
     * @param account is a new system account.
     */
    event SystemAccountAdded(address indexed account);

    /**
     * @dev Emitted when system account is removed.
     * @param account is the old system account.
     */
    event SystemAccountRemoved(address indexed account);

    /**
     * @dev Modifier which prevents non-system accounts from calling protected functions.
     */
    modifier onlySystemAccounts() {
        require(isSystemAccount(msg.sender));
        _;
    }

    /**
     * @dev Modifier which prevents non-system accounts from being passed to the guard.
     * @param account The account to check.
     */
    modifier onlySystemAccount(address account) {
        require(
            isSystemAccount(account),
            "must be a system account"
        );
        _;
    }

    /**
     * @dev System Role constructor.
     * @notice The contract is an abstract contract as a result of the internal modifier.
     */
    //constructor() internal {}

    /**
     * @dev Checks whether an address is a system account.
     * @param account the address to check.
     * @return true if system account.
     */
    function isSystemAccount(address account) public view returns (bool) {
        return systemAccounts.has(account);
    }

    /**
     * @dev Assigns the system role to an account.
     * @notice This method is unprotected and should be authorized in the child contract.
     */
    function addSystemAccount(address account) public virtual {
        systemAccounts.add(account);
        emit SystemAccountAdded(account);
    }

    /**
     * @dev Removes the system role from an account.
     * @notice This method is unprotected and should be authorized in the child contract.
     */
    function removeSystemAccount(address account) public virtual {
        systemAccounts.remove(account);
        emit SystemAccountRemoved(account);
    }

}
