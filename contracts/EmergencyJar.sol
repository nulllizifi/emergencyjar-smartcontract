// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 *   This contract creates an "emergency jar," essentially a shared wallet
 *   The jar can have multiple owners, who are added and removed by only the jar creator
 *   Jar owners can deposit or withdraw change and can check the jar balance
 */

contract EmergencyJar {
    // Store the address that deploys the contract
    address public jarCreator;

    // The jar name is customizable
    string public jarName;

    // Mapping that determines which addresses are jar owners
    // Addresses keys with a value of true are owners
    // Addresses keys with a value of false are not
    mapping(address => bool) public jarOwners;

    // Modifier that allows only the jar creator to perform actions
    modifier isCreator() {
        require(msg.sender == jarCreator);
        _;
    }

    // Modifier that requires ownership of jar to perform actions
    // Jar owners include the contract owner and added owners
    modifier isOwner() {
        require(msg.sender == jarCreator || jarOwners[msg.sender] == true);
        _;
    }

    // Events that log changes in emergency jar to blockchain
    event DepositChange(address indexed from, uint256 amount);
    event WithdrawChange(address indexed from, uint256 amount);

    // Constructor initializes creator of emergency jar
    // And grants the jar creator ownership as well
    constructor() {
        jarCreator = msg.sender;
        addOwner(msg.sender);
    }

    // Customize the jar name
    // Only the jar creator can change the name
    function setJarName(string memory _name) external isCreator {
        jarName = _name;
    }

    // Grant ownership of the jar
    // Only the jar creator can grant ownership
    // True signifies ownership
    function addOwner(address _owner) public isCreator {
        jarOwners[_owner] = true;
    }

    // Revoke ownership of the jar from an address
    // Only the jar creator can revoke ownership
    // False signifies lack of ownership
    function removeOwner(address _owner) public isCreator {
        jarOwners[_owner] = false;
    }

    // Deposit change into the jar
    // Only jar owners can deposit
    function depositChange() public payable isOwner {
        require(msg.value != 0, "Deposit some change please.");

        // Log DepositChange event
        emit DepositChange(msg.sender, msg.value);
    }

    // Withdraw change from the jar
    // Only owners can withdraw
    function withdrawChange(address payable _to, uint256 _total)
        public
        isOwner
    {
        require(
            _total <= address(this).balance,
            "Not enough change for withdrawal."
        );

        // Log WithdrawChange event
        emit WithdrawChange(msg.sender, _total);
        _to.transfer(_total);
    }

    // Return jar balance
    // Only owners can get the jar balance
    function getJarBalance() public view isOwner returns (uint256) {
        return address(this).balance;
    }
}
