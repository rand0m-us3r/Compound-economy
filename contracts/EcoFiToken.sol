// SPDX-License-Identifier: AGPL-3.0-only
// Life Token Contract
// Copyright (C) 2021
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity >=0.4.22 <0.9.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

/**
 * @title Life Token (LIV)
 * @notice Implementation of OpenZepplin's ERC20Burnable Token with custom burn and staking mechanism.
 */
contract LifeFiToken is ERC20Burnable {
    address internal deployer;
    address internal sproutContract = address(0);
    constructor(
        address _systemMultisig
    ) 
    ERC20("Life Token", "LIV")
    {
        deployer = msg.sender;
        _mint(_systemMultisig, 10*10**6*10**18);
    }

    /**
     * @notice Overload OpenZepplin internal _transfer() function to add extra require statement preventing
     * transferring tokens to the contract address
     * @param _sender The senders address
     * @param _recipient The recipients address
     * @param _amount Amount of tokens to transfer (in wei units)
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * Additional requirements:
     *
     * - `_recipient` cannot be the token contract address.
     */
    function _transfer(address _sender, address _recipient, uint256 _amount) internal override {
        require(_recipient != address(this), "LifeToken: transfer to token contract address");
        super._transfer(_sender, _recipient, _amount);
    }

    /**
     * @notice Overload OpenZepplin public transfer() function to add extra require statement preventing
     * transferring tokens to the sprout contract by calling transfer() (should only work with transferFrom)
     * @param _recipient The recipients address
     * @param _amount Amount of tokens to transfer (in wei units)
     * @dev Moves tokens `amount` to `recipient` by calling `_transfer()`.
     *
     * Additional requirements:
     *
     * - `_recipient` cannot be the sprout contract address.
     */
    function transfer(address _recipient, uint256 _amount) public virtual override returns (bool) {
        require(_recipient != address(sproutContract), "LifeToken: transfer to sprout contract address (use transferFrom instead)");
        return super.transfer(_recipient, _amount);
    }

    /**
     * @notice Set Life address once it is deployed, so we can prevent users from mistakenly transferring
     * LIV to the LIFE contract incorrectly (thus locking up their tokens)
     * @param _sproutContract Sprout contract address
     * @dev Sets `sproutContract` to supplied argument `_sproutContract` only one time.
     *
     * Additional requirements:
     *
     * - Can only be called by `deployer` .
     */
    
    function setLiveAddress(address _liveContract) public {
        require(liveContract == address(0), "may only be called once");
        require(msg.sender == deployer, "must be called by deployer");
        liveContract = _liveContract;
    }

}
