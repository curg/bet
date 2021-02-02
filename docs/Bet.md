## `Bet`



Implementation of the {IBet} abstract contract.


### `constructor(address initialCVTAddress, address initialRandomAddress)` (public)



Sets the 'CVT' and 'Random' contracts.

Requirements:

- the `CVTAddress` MUST be a contract address.
- the `initialRandomAddress` MUST be a contract address.

### `bet(uint24 amount, uint8 percentage) → bool success` (public)



Consumes `amount` CVTs and runs the betting system with the probability
`percentage` .

Returns a boolean value indicating whether the betting succeeded.

Emits {Bet} and {Result} events.

Requirements:

- `percentage` < 100

### `getFeeConst() → uint8` (public)



Returns the number of exponent.

### `setFeeConst(uint8 newFeeConst)` (public)



Sets {_exponent} to a value other than the default one of 2.

### `getCVTAddress() → address` (public)



Returns the address of 'CVT' contract.

### `setCVTAddress(address newCVTAddress)` (public)



Sets the 'CVT' via an address.
{newCVTAddress}.

Requirements:

- the `newCVTAddress` MUST be contract address.

### `getRandomAddress() → address` (public)



Returns the address of 'Random' contract.

### `setRandomAddress(address newRandomAddress)` (public)



Sets the 'Random' contract via an address.
{newRandomAddress}.

Requirements:

- the `newRandomAddress` MUST be contract address.

### `addOwnership(address account, uint8 level) → bool` (public)



Calls {_addOwnership}.

### `deleteOwnership(address account) → bool` (public)



Calls {_deleteOwnership}.

### `transferOwnership(address oldOwner, address newOwner) → bool` (public)



Calls {_transferOwnership}.

### `changeOwnershipLevel(address account, uint8 level) → bool` (public)



Calls {_changeOwnershipLevel}.


