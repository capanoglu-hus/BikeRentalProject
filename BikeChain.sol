// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BikeChain{

  address owner;

  constructor() {
      owner = msg.sender;
  }

  struct Render{
      address payable walletAdres;
      string firstName;
      string lastName;
      bool canRent; // kiralama durumu 
      bool active; // kiracı aktiflik durumu 
      uint balance; // kiracının hesabındaki para 
      uint due ; // işlem sonucu ödünecek miktar
      uint start ; // kiralama işleminin başlangıcı 
      uint end ; // kiralama işleminin bitişi
  }

    mapping(address => Render) public renders ; //kiracıları adrese göre eşliyecegiz 

    function addRender(
        address payable walletAdres,
        string memory firstName,
        string memory lastName,
        bool canRent , 
        bool active ,
        uint balance ,
        uint due ,
        uint start ,
        uint end) 
        public {
            renders[walletAdres]= Render(walletAdres ,firstName,lastName,canRent,active,balance,due,start,end );

        }

        function checkOut(address walletAdres) public {
            require(renders[walletAdres].balance != 0 ,"send money to account");
            require(renders[walletAdres].due == 0 ,"you have a pending balance");
            require(renders[walletAdres].canRent == true  ,"you cannot rent at this time");
            renders[walletAdres].active = true ; // kiralama işlemini aktif etti 
            renders[walletAdres].start = block.timestamp ; // başlangıç zamanını tuttu 
            renders[walletAdres].canRent = false ; // başka bir kiralama yapılmaması için false yapıldı .
        }

        function checkIn(address walletAdres) public {
            require(renders[walletAdres].active == true  ,"bike is currently checked out "); //bike kapatmadıkça bunları göremezler 
            renders[walletAdres].active = false ;
            renders[walletAdres].end = block.timestamp ;
            setDue(walletAdres);
        }

        // internal -- fonk miras alındıgında görünebilir
        function renderTimeSpan(uint start , uint end ) internal pure returns(uint){
            return end - start ;  
        }

        function getTotalDuration(address walletAdres) public view returns(uint){
             require(renders[walletAdres].active == false  ,"please check out a bike first ");
            uint timeSpan = renderTimeSpan(renders[walletAdres].start ,renders[walletAdres].end ) ; 
            uint timeMinute = timeSpan / 60 ; 
            return timeMinute ; 
        }

        function balanceOf() public view returns(uint){
            return address(this).balance ;  // kont. balance ı tutuyor.
        }

        function  balanceOfRender(address walletAdres ) public view returns(uint){
             return renders[walletAdres].balance ;
        }
        function setDue(address walletAdres) internal {
            uint timeMinute = getTotalDuration(walletAdres);
            uint fiveMinute = timeMinute / 5 ; // her 5 dk 0.005 bnb olacak 
            renders[walletAdres].due = (fiveMinute + 1 ) * 5000000000000000 ; 
        } 

        function canBikeRent(address walletAdres) public view returns(bool){
           return renders[walletAdres].canRent ; 
        }

        function deposit(address walletAdres) payable public {
            renders[walletAdres].balance += msg.value ;
        }

        function makePayment(address walletAdres) payable public { 
            require(renders[walletAdres].due > 0   ,"you do not have anything due at this time "); // ödeme yapmak için borçum olmalı 
            require(renders[walletAdres].balance > msg.value  ,"you do not have enough"); // ödeme degeri hesapdakinden büyük olmamalı 
            renders[walletAdres].balance -= msg.value ; // ödeme alınıyor 
            renders[walletAdres].canRent = true ;  // ödeme yapıldıgı için parametreler ilk hale döner 
            renders[walletAdres].end = 0 ;
            renders[walletAdres].start = 0 ;
            renders[walletAdres].due = 0 ;
        }
}
