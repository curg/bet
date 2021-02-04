// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.6.0;

import "./Context.sol";
import "./MultiOwnable.sol";
import "./IBet.sol";
import "./SafeMath.sol";
import "./FP224x8.sol";
import "./Address.sol";
import "./CVT.sol";
import "./Random.sol";


/**
 * @title Bet
 * @dev Implementation of the {IBet} abstract contract.
 */
contract Bet is Context, MultiOwnable, IBet {
    using SafeMath for uint256;
    using FP224x8 for uint232;
    using Address for address;

    address private _CVTAddress;
    address private _randomAddress;

    bytes4 private constant BURNFROM = bytes4(keccak256(bytes('burnFrom(address,uint256)')));
    bytes4 private constant MINT = bytes4(keccak256(bytes('mint(address,uint256)')));
    bytes4 private constant RANDOM = bytes4(keccak256(bytes('random()')));

    // levels
    uint8 private constant OWNERBLE = 7;
    uint8 private constant ADDRESS = 7;
    uint8 private constant FEECONST = 6;

    uint8 private _feeconst = 8;

    /**
     * @dev Sets the 'CVT' and 'Random' contracts.
     *
     * Requirements:
     *
     * - the `CVTAddress` MUST be a contract address.
     * - the `initialRandomAddress` MUST be a contract address.
     */
    constructor (
        address initialCVTAddress,
        address initialRandomAddress
    ) public {
        // conditions
        require(initialCVTAddress.isContract(), "NOT a contract address.");
        require(initialRandomAddress.isContract(), "NOT a contract address.");

        _CVTAddress = initialCVTAddress;    // CVT contract
        _randomAddress = initialRandomAddress;  // Random contract
    }

    /**
     * @dev Consumes `amount` CVTs and runs the betting system with the probability
     * `percentage` .
     *
     * Returns a boolean value indicating whether the betting succeeded.
     *
     * Emits {Bet} and {Result} events.
     * 
     * Requirements:
     *
     * - `percentage` < 100
     */
    function bet(
        uint24 amount,
        uint8 percentage
    ) public returns (
        bool success
    ) {
        // conditions
        require(percentage < 100, "Percentage MUST be lower than 100 .");
        address sender = _msgSender();
        require(!sender.isContract(), "The caller MUST NOT be a contract address.");

        // `fee = amount * _feeconst * (p**2)` where `p = percentage / 100`
        // `fee > 1` when `amount >= 13` where `_feeconst = 8`
        // if `percentage >= 94`, you would lose out beacause of 'fee' where '_feeconst = 8'
        uint256 numerator = uint256(_feeconst).mul(uint256(percentage)).mul(uint256(percentage));
        uint256 fee = uint256(amount).mul(numerator).div(100**3);
        fee = fee.add(uint256(amount));
        // burn `amount + fee`
        (bool check, bytes memory data) = _CVTAddress.call(
            abi.encodeWithSelector(BURNFROM, _msgSender(), fee)
        );
        require(
            check && (data.length == 0 || abi.decode(data, (bool))),
            "call burnFrom(address, uint256) is failed."
        );

        // successfully betted
        emit Bet(_msgSender(), amount, percentage);

        // gets random
        (check, data) = address(_randomAddress).call(
            abi.encodeWithSelector(RANDOM)
        );
        require(
            check && (data.length != 0),
            "call random() is failed."
        );
        uint256 returnValue = abi.decode(data, (uint256));

        // bet!
        uint8 luckyNumber = uint8(returnValue.mod(100));
        uint232 scale = FP224x8.encode(100).fpdiv(percentage);
        uint256 reward = 0;

        if (luckyNumber < percentage) {
            reward = uint256(scale).mul(uint256(amount)).div(2**224);  // never overflows
            success = true;
        }

        if (success) {
            // mint `amount + reward`
            (check, data) = _CVTAddress.call(
                abi.encodeWithSelector(MINT, _msgSender(), reward)
            );
            require(
                check && (data.length == 0 || abi.decode(data, (bool))),
                "call mint(address,uint256) is failed."
            );
        }
        
        emit Result(_msgSender(), success, reward);
    }

    /**
     * @dev Returns the number of {_feeconst}.
     */
    function getFeeConst(
        // ...
    ) public view returns (uint8) {
        return _feeconst;
    }

    /**
     * @dev Sets {_feeconst} to a value other than the default one of 8.
     */
    function setFeeConst(
        uint8 newFeeConst
    ) public onlyOwner(FEECONST) {
        _feeconst = newFeeConst;
    }

    /**
     * @dev Returns the address of 'CVT' contract.
     */
    function getCVTAddress(
        // ...
    ) public view returns (address) {
        return _CVTAddress;
    }

    /**
     * @dev Sets the 'CVT' via an address.
     * {newCVTAddress}.
     *
     * Requirements:
     *
     * - the `newCVTAddress` MUST be contract address.
     */
    function setCVTAddress(
        address newCVTAddress
    ) public onlyOwner(ADDRESS) {
        require(newCVTAddress.isContract(), "NOT a contract address.");

        _CVTAddress = newCVTAddress;
    }

    /**
     * @dev Returns the address of 'Random' contract.
     */
    function getRandomAddress(
        // ...
    ) public view returns (address) {
        return _randomAddress;
    }

    /**
     * @dev Sets the 'Random' contract via an address.
     * {newRandomAddress}.
     *
     * Requirements:
     *
     * - the `newRandomAddress` MUST be contract address.
     */
    function setRandomAddress(
        address newRandomAddress
    ) public onlyOwner(ADDRESS) {
        require(newRandomAddress.isContract(), "NOT a contract address.");

        _randomAddress = newRandomAddress;
    }

    /**
     * @dev Calls {_addOwnership}.
     */
    function addOwnership(
        address account,
        uint8 level
    ) public onlyOwner(OWNERBLE) returns (bool) {
        _addOwnership(account, level);

        return true;
    }

    /**
     * @dev Calls {_deleteOwnership}.
     */
    function deleteOwnership(
        address account
    ) public onlyOwner(OWNERBLE) returns (bool) {
        _deleteOwnership(account);

        return true;
    }

    /**
     * @dev Calls {_transferOwnership}.
     */
    function transferOwnership(
        address oldOwner,
        address newOwner
    ) public onlyOwner(OWNERBLE) returns (bool) {
        _transferOwnership(oldOwner, newOwner);

        return true;
    }

    /**
     * @dev Calls {_changeOwnershipLevel}.
     */
    function changeOwnershipLevel(
        address account,
        uint8 level
    ) public onlyOwner(OWNERBLE) returns (bool) {
        _changeOwnershipLevel(account, level);

        return true;
    }
}
