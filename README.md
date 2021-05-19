# 👑 King-Of-The-Hill 👑
 
 ![alt text](https://image.freepik.com/vecteurs-libre/pixel-art-king-crown-icon-bit-jeu_360488-117.jpg)

 
 ## The King Of The Hill 
 
 Is usually a game that is played in the world of Hacking. 
 
 To see who is better at hacking a given system, you set one up with some flaws in it, intentionnaly. 
 
 Then, many hackers attack that system, the first to do it, gain access to the system and now have to secure it from the inside. 
 
 He therefore becomes the King Of The Hill, until another hacker breaks into his self-proclaimed kingdom and dethrone him/her.
 
 On the Blockchain, the game was slightly different, a smart contract was deployed, and the one who placed the highest bid, became the King.
 The price was of cours, the sum of all the bid placed. 
 The one that placed a bid higher than the last one, now have the crown on his head, before a richer person dared to place a bid. 
 
 [Official Doc Common Pattern Exemple](https://docs.soliditylang.org/en/latest/common-patterns.html#withdrawal-from-contracts)
 
 [King Of The Ether](https://www.kingoftheether.com/thrones/kingoftheether/index.html)
 
 ## How to play : 
 
### Initiatilization : 
 
When the contract is deployed, the deployer sets the owner of the smart-contract (usually himself) and the number of blocks 
_starting from the current one where the contract is deployed_ to set the length (in blocks) of a turn. 

He also initialize the game with a bid called _seed_. The ammount must be superior to 0 gwei. 

After that, everyone _but the owner of the game_ can place a bid on to claim the throne. 

### During the Game : 

Each time someone becomes a King, he can't play over the last bid. Unless he is dethrone, he have to wait patiently on his throne. 
All the players can place a bid, as long as it is twice as much as the latest one. The game end when the turn end. 

Then the King have to retrive his due. 

When he does : 

- 80% of all the bid placed is for him. 
- 10% is for the owner (the tax)
- 10% is for the new price. 


## Disclaimer : 

**DO NOT** copy that smart contract and deploy it on the mainnet.
