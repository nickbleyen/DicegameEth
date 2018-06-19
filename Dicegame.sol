pragma solidity ^0.4.18;

contract DiceGame{
    
    address[2] public players;
    address public feeCollector = 0xc995E0aa41e83041EfD2536CBe55320A293adb7D; //Account 5
    uint8 public player1Throw;
    uint8 public player2Throw;
    uint256 public betAmount;
    uint80 constant None = uint80(0); 
    
    //Generate random number between 1 and 6
    function Throw(address player) internal view returns (uint8) {
        uint b = block.number;
        uint timestamp = block.timestamp;
        uint256 random = uint256(block.blockhash(b)) + uint256(player) + uint256(timestamp);
        return uint8(random%6);
    }

    function () public payable {
        if(players[0] == None){
            if(msg.value>=1){
                players[0]=msg.sender;
                betAmount = msg.value;
                player1Throw = Throw(msg.sender);
            }
            else {
                msg.sender.transfer(msg.value);
            }
        }else{
            if(msg.value==betAmount){
            collectFee();
            players[1]= msg.sender;
            player2Throw = Throw(msg.sender);
            checkAndFundWinner();
            clean();
            }else{
            msg.sender.transfer(msg.value);
            }
        }
}

    //Reset fields
    function clean() public{
        players[1] = None;
        players[0] = None;
        betAmount = None;
        player1Throw = 0;
        player2Throw = 0;
    }

    //Check who won and fund the winner
    function checkAndFundWinner() public{
            while(player1Throw == player2Throw){
                Throw(msg.sender);
            }
            if (player1Throw > player2Throw){
                players[0].transfer(betAmount);
            }else{
                players[1].transfer(betAmount);
            }
    }

    //Collect 10% from the total betamount
    function collectFee() public{
        uint256 fee;
        fee = betAmount * 10;
        betAmount += betAmount;
        betAmount -= fee / 100;
        feeCollector.transfer(fee/100 );
    }
}