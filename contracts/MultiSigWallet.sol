// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// A contract for a multi-signature wallet that requires multiple confirmations from the owners for transactions with timelock.
contract MultiSigWallet {
    // Events for logging actions within the contract.
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data,
        uint submitTime
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    // Storage variables.
    address[] public owners; // List of owners.
    mapping(address => bool) public isOwner; // Tracks whether an address is an owner.
    uint public numConfirmationsRequired; // Number of confirmations required to execute a transaction.
    uint public delay; // Delay required before a transaction can be executed.

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
        uint submitTime; // Time when transaction was submitted.
    }

    // Mapping to keep track of confirmations for each transaction.
    mapping(uint => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions; // List of all transactions.

    // Modifiers to control function access and conditions.
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    modifier delayedExecution(uint _txIndex) {
        require(block.timestamp >= transactions[_txIndex].submitTime + delay, "tx locked");
        _;
    }

    // Constructor to set initial owners and the required number of confirmations.
    constructor(address[] memory _owners, uint _numConfirmationsRequired, uint _delay) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
            _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );
        require(_delay > 0, "delay must be positive");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
        delay = _delay; 
    }

    // Fallback function to allow the contract to receive Ether directly.
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // Function to submit a new transaction.
    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0,
                submitTime: block.timestamp
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data, block.timestamp);
    }

    // Function to confirm a transaction by an owner.
    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    // Function to execute a transaction after the required number of confirmations and delay.
    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        delayedExecution(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    // Function to revoke confirmation of a transaction.
    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    // Function to get a list of owners.
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    // Function to get the number of transactions.
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    // Function to get details of a specific transaction.
    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations,
            uint submitTime
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations,
            transaction.submitTime
        );
    }
}
