// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Wallet42 {

    uint256 public numConfirmationsRequired;
    mapping(address => bool) public isOwner;
    // mapping from transaction index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isConfirmed;


    event SubmitTransaction(
        address indexed owner,
        uint256 indexed transactionIndex,
        address indexed to,
        bytes data
    );

    event ConfirmTransaction(address indexed owner, uint256 indexed transactionIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed transactionIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed transactionIndex);

    struct Transaction {
        address to;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    Transaction[] internal transactions;
    address[] internal owners;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier transactionExists(uint256 _transactionIndex) {
        require(_transactionIndex < transactions.length, "transaction does not exist");
        _;
    }

    modifier transactionNotExecuted(uint256 _transactionIndex) {
        require(!transactions[_transactionIndex].executed, "transaction already executed");
        _;
    }

    modifier transactionNotConfirmed(uint256 _transactionIndex) {
        require(!isConfirmed[_transactionIndex][msg.sender], "transaction already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0
            && _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    function submitTransaction(address _to, bytes memory _data) public onlyOwner {
        uint256 transactionIndex = transactions.length;
        transactions.push(
            Transaction({
                to: _to,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );
        emit SubmitTransaction(msg.sender, transactionIndex, _to, _data);
    }

    function confirmTransaction(uint256 _transactionIndex)
    public
    onlyOwner
    transactionExists(_transactionIndex)
    transactionNotExecuted(_transactionIndex)
    transactionNotConfirmed(_transactionIndex)
    {
        Transaction storage transaction = transactions[_transactionIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_transactionIndex][msg.sender] = true;
        if (transaction.numConfirmations == numConfirmationsRequired) {
            executeTransaction(_transactionIndex);
        }
        emit ConfirmTransaction(msg.sender, _transactionIndex);
    }

    function executeTransaction(uint256 _transactionIndex)
    public
    onlyOwner
    transactionExists(_transactionIndex)
    transactionNotExecuted(_transactionIndex)
    {
        Transaction storage transaction = transactions[_transactionIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute transaction"
        );

        (bool success,) = transaction.to.call(transaction.data);
        require(success, "transaction failed");
        transaction.executed = true;
        emit ExecuteTransaction(msg.sender, _transactionIndex);
    }

    function getOwners() view public returns (address[] memory) {
        return owners;
    }

    function getTransactions() view public returns (Transaction[] memory) {
        return transactions;
    }
}