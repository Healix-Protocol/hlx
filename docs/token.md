# Token Contract Documentation

### Overview

This is an ERC20-compliant token with an added feature of role-based access control for minting new tokens. It utilizes OpenZeppelin's contracts for access control and ERC20 token implementation.

### Contract Details

#### Dependencies

The contract imports the following OpenZeppelin contracts:

- `AccessControl` for role-based access control.
- `ERC20Capped` for capping the total supply of tokens.

#### Role

- `MINTER_ROLE`: Role for minters, who are authorized to create new tokens.

#### Constructor

The constructor initializes the token with the following parameters:

- `name_`: The name of the token.
- `symbol_`: The symbol of the token.
- `cap_`: The maximum supply limit of the token.

#### Functions

##### `mint(address to, uint256 amount)`

This function allows minters to create new tokens and assign them to a specified address.

- `to`: The address to which the newly minted tokens will be assigned.
- `amount`: The amount of tokens to mint.

## Usage

1. Deploy the Token contract, providing the name, symbol, and maximum supply cap.
2. The deployer automatically receives the admin and minter roles.
3. Use the `mint` function to create new tokens, ensuring that the caller has the minter role.
