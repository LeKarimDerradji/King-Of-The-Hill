// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AccessControl {
    
    
        address internal _owner;
        address internal _kingOfTheHill;
        mapping(address => bool) internal _king;
    
        constructor(address owner_) payable {
           _owner = owner_;
       }
       

       

        // modifier for owner
        modifier onlyOwner() {
            require(msg.sender == _owner, "Ownable: Only owner can call this function");
             _;
        }
        
        modifier onlyKing() {
            require(msg.sender == _kingOfTheHill, 'AccessControl: Only the kingOfTheHill can call this function.');
            _;
        }
        
        modifier costs(uint _amount) {
         if (msg.value < _amount)
            revert('You can not send less than the highest king price');
             _;
        }
    

        function owner() public view returns(address) {
            return _owner;
       }
      
       function king() public view returns(address) {
           return  _kingOfTheHill;
       }
       
       
}