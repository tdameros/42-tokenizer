# Smart contract

- [Token.sol](code/Token.sol): A simple ERC-20 token contract that allows users to create and manage their own tokens.
- [Wallet.sol](code/Wallet.sol): A multi-signature wallet contract that requires multiple signatures to execute transactions, enhancing security for managing funds.

## Token.sol

Token42 is a custom ERC20 token implementation with minting and burning capabilities, built using OpenZeppelin contracts.

### Contract Details
- **Token Name**: Token42
- **Token Symbol**: T42
- **Decimals**: 4
- **License**: MIT
- **Solidity Version**: 0.8.20+

### Features

#### Token Management
- Standard ERC20 functionality (transfers, approvals)
- 4 decimal places precision
- Balance checking via myBalance()

#### Minting and Burning
- Owner can mint tokens to any valid address
- Any user can burn their own tokens
- Owner can forcibly burn tokens from any address

### Functions

#### myBalance()
Returns the token balance of the caller

#### burn(amount)
Burns specified amount from caller's balance  
Requires: Sufficient token balance

#### mint(to, amount) [Owner Only]
Mints new tokens to specified address  
Requires: Non-zero address

#### burnFrom(from, amount) [Owner Only]
Burns tokens from specified address  
Requires: Address has sufficient balance

### Access Control
- Inherits OpenZeppelin Ownable
- Minting and forced burning restricted to owner
- Regular burning available to all token holders

### Usage

To check your balance:  
`myBalance()`

To burn your tokens:  
`burn(amount)`

Owner functions:  
`mint(to, amount)`  
`burnFrom(from, amount)`


## Wallet.sol

Wallet42 is a multi-signature wallet implementation that requires multiple confirmations to execute transactions. Designed for secure fund management with shared ownership.

### Contract Details
- **Solidity Version**: 0.8.20+
- **License**: MIT
- **Type**: Multi-signature Wallet

### Features

#### Ownership Management
- Configurable list of owners
- Unique owner addresses enforced
- No zero-address owners allowed

#### Transaction Flow
- Transaction submission by any owner
- Configurable confirmation threshold
- Transaction execution after sufficient confirmations
- Prevention of duplicate confirmations

### Core Functions

#### submitTransaction(to, data)
Submits a new transaction for confirmation  
Restricted to: Wallet owners

#### confirmTransaction(transactionIndex)
Confirms a pending transaction  
Restricted to: Wallet owners  
Requirements:
- Transaction must exist
- Not yet executed
- Not already confirmed by caller

#### executeTransaction(transactionIndex)
Executes a confirmed transaction  
Restricted to: Wallet owners  
Requirements:
- Sufficient confirmations
- Not yet executed

#### View Functions
- getOwners(): Returns list of all owners
- getTransactions(): Returns all transactions

### Events

#### Transaction Lifecycle

- SubmitTransaction: When new transaction created
- ConfirmTransaction: When owner confirms transaction
- RevokeConfirmation: When owner revokes confirmation
- ExecuteTransaction: When transaction executes

### Configuration

#### Constructor Parameters
- owners: Array of owner addresses
- numConfirmationsRequired: Minimum confirmations needed

#### Requirements
- At least 1 owner required
- Confirmations required must be > 0 and ≤ owner count
- All owners must be unique, non-zero addresses

### Usage

#### Initialization
Deploy with owner addresses and confirmation threshold

#### Typical Workflow
1. Owner submits transaction
2. Other owners confirm
3. Transaction executes automatically when threshold met
4. Alternatively: Execute manually after sufficient confirmations
