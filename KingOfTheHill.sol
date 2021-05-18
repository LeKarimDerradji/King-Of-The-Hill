// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title King Of The Hill
 * @dev Deposit money at the first block, thus becoming the Owner of the smart contract
 * if a given user deposit the double of the ammount deposited by the Owner, before a given number of Blocks
 * he becomes the King Of The Hill. 
 * 
 * “Concentrate on material gains. Whatever your opponent gives you take, unless you see a good reason not to.”
 * ― Bobby Fischer
 */
 
 
 import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
 import './AccessControl.sol';
 
contract KingOfTheHill is AccessControl {
    
    // library Usage 
    
    using Address for address payable;
    
    // To keep track of the king's balance, we made that mapping. 
    mapping(address => uint256) private _kingPriceBalance;
    /**
     * @dev
     * This mapping keep tracks of who is the last king, because, why would you be able to gamble again, if you won all of the money of others
     * it's revelant, if there's millions of player, but in a tiny circle of player, you'll be a whale, and win again and again, 
     * so i removed this flaw by excluding the last winner each time, by flagging them with a boolean.
     */
    mapping(address => bool) private _lastKing; 
    /**
     * @dev
     * The first one is a variable keep track of the blocknumber, it will store the block.number where our game will end and no more
     * bids can be placed anymore.
     */
    uint256 private _endOfTurn;
    /**
     * @dev 
     * Storage Variables Monetary Values :
     * These three following storage variables are there to keep track of the money that is flowing into 
     * the smart-contract, the _price will track the highest bid.
     * "_ownerProfit" will be used to send the profit earned in total, by the deployer and coder of the contract.
     * the "_tax" is the immuable in percent, ammount of tax that the owner can apply, we set it as 10%
     */
    uint256 public _price;
    uint256 private _ownerProfit;
    
    uint256 private _tax;
    
    /**
     * @notice
     * This is our constructor, it takes two paramettersn, an owner, and the number of blocks from the time of the deployment that
     * the game will run until the only public accessible function of this game will be frozen. 
     * this constructor, respond to the one in AccessControl.sol in order to set up an owner, AccessControl is the file
     * where we manage all the roles and modifiers, functions, related to these roles. 
     * finally, we make that constructor payable, in order to place an inital bid, the one that will put that inital bid can not play again,
     * we'll see that later. The seed value of the bid must be above 0 eth, then, after the first turn of the game, 
     * the value will reset itself depending of the price of the king at the end of a turn (10%)
     */
    constructor(address owner_, uint256 endOfTurn_) payable AccessControl(owner_)  {
            require(msg.value > 0, 'KingOfTheHill: the seed value must be superior to one eth');
            _price = msg.value;
            _endOfTurn = block.number + endOfTurn_;
            _tax = 10;
       }
    /**
     *@dev
     * This function serves to see the remaining blocks before the end of the turn, it's like a clock tic-tacking before 
     * no one can claim the crown anymore, and only the king can interract with the smart-contract, therefore reseting it for another turn. 
     */
    function remainingBlock() public view returns (uint256) {
        return _endOfTurn - block.number;
    }
    
    /**
     * @dev
     * 
     * This is the main and most important functionality of this game, to claim the crown
     * by claiming the crown, we mean, of course, placing the highest bid, 
     * you can only place twice as much as the latest bid place, this is controlled by the modifier 
     * 'costs' that is located in AccessControl, why did I choose to do so ? 
     * For the main reason that, placing a bid twice as much as the latest one, means that you become a KING, 
     * for that a ROLE is GRANTED to you, and another's player role is being REVOKED, to keep track of that
     * is the main function of AccessControl.sol
     * 
     * Then, we assign the value sent to the variable price, the sender becomes the king, and we be track of his balance with the mapping.
     * 
     **/
    function claimCrown() external payable costs(_price * 2) {
        require(msg.sender != _owner, 'KingOfTheHill: The owner can not play.');
        require(msg.sender != _kingOfTheHill, 'KingOfTheHill: The king can not claim the crown again.');
        require(_endOfTurn > block.number, 'KingOfTheHill: the turn ended, wait for the king to withdraw his price.');
         _price += msg.value;
         _kingOfTheHill = msg.sender;
         _kingPriceBalance[_kingOfTheHill] = _price;
         
    } 
    
    function claimPrice() public payable onlyKing {
         require(block.number > _endOfTurn, 'King Of The Hill: you can not withdraw yet.');
         uint256 kingLastPrice = (80 * _price) / 100;
         _price -= kingLastPrice;
         _ownerProfit = (_price * _tax) / 100;
         _price -= _ownerProfit;
         _kingPriceBalance[msg.sender] = 0;
         payable(_owner).sendValue(_ownerProfit);
         payable(_kingOfTheHill).sendValue(kingLastPrice);
         _kingOfTheHill = address(0);
         _lastKing[msg.sender] = true;
         _endOfTurn = block.number + 8;
    }
    
}