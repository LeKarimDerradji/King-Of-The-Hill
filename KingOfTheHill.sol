// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title King Of The Hill
 * @notice
 * 
 * The deployer of the smart contract, set up an owner, the number of of blocks before the end of a turn, 
 * and a seed bid. Then, each user after him/her have to place a bid that is twice as high as the inital bid.
 * 
 * The one that mange to do so, claim the crown, and become the King of THe Hill. 
 * 
 * The King of The Hill is dethrone, if someone places a bid twice as high as his latest bid. 
 * 
 * The owner can't play. The King can place a bid over himself. 
 * 
 * At the end of the turn (number of blocks wise), the king can claim his price. 
 * Doing so, he resets the game. 
 * 
 * 10% of the price is for the Owner. 80% is for the King. 10% remaining serves as a new seed. 
 * Now the turn automatically last 8 turns.
 * 
 * “Concentrate on material gains. Whatever your opponent gives you take, unless you see a good reason not to.”
 * ― Bobby Fischer
 */
 
 
 import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
 import './AccessControl.sol';
 
contract KingOfTheHill is AccessControl {
    
    // library Usage 
    
    using Address for address payable;
    
    /**
     * @dev
     * It is better to track the balance of the king, as a way to give to caesar what belongs to caesar, and avoid rentrancy attack.
     * This way, the King of each turn can claim their price, as oppose to a loosing player paying for the gas fees for his transaction. 
     * 
     */
    mapping(address => uint256) private _kingPriceBalance;
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
     * The constructor takes two parameters, one requirement, one two modifiers, and sets up to three variables.
     * The deployer can set the owner of the smart contract, and the number of block before the end of the first turn.
     * To initialize the game, the deployer have to deploy to smart contract by storing more than 0 eth into it. 
     * The tax will always be 10% 
     * The end of one turn will always be block.number + the number of block the deployer chooses. 
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
    function claimCrown() external payable costs(_price * 2) onlyPlayer {
        require(_endOfTurn > block.number, 'KingOfTheHill: the turn ended, wait for the king to withdraw his price.');
         _price += msg.value;
         _kingOfTheHill = msg.sender;
         _kingPriceBalance[_kingOfTheHill] = _price;
         
    } 
    
    /**
     * @dev 
     * The second most important function of that game.
     * When the block.numbers of the current turn ended, the game froze, until the king retrives his sendValue
     * when she retrive her price, the price is reduced by 80% and stored into a new variable,
     * then we take the remaining, and store it to the owner profit variable to send it to him. 
     * finally, we set the balance of the king to zero
     * the price is now ready for the next turn
     * we send the profit to the owner
     * we send the price to the King
     * we reset the adress of the King
     * we add a new turn with the _endOfTurn variable + the current block number + 8.
     */
    
    function claimPrice() public payable onlyKing {
         require(block.number >= _endOfTurn, 'King Of The Hill: you can not withdraw yet.');
         uint256 kingLastPrice = (80 * _price) / 100;
         _price -= kingLastPrice;
         _ownerProfit = (_price * _tax) / 100;
         _price -= _ownerProfit;
         _kingPriceBalance[msg.sender] = 0;
         payable(_owner).sendValue(_ownerProfit);
         payable(_kingOfTheHill).sendValue(kingLastPrice);
         _kingOfTheHill = address(0);
         _endOfTurn = block.number + 8;
    }
    
}