// SPDX-License-Identifier: YORK
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "NFT_V2.sol";
// import "hardhat/console.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

contract KingOfLandmark {
    
    using Address for address;
    address private contractOwner;
    mapping (string => attack)  public attackhistory;
    mapping (string => land)  public lands;
    mapping (uint256 => bool)  public AttackNFT_exist;
    mapping (uint256 => bool)  public ProtectNFT_exist;
    YORKMeta public AttackNFT;
    YORKMeta public ProtectNFT;
    YORKMeta public LandNFT;
    
    struct land{
        address payable owner;
        uint256 nft;
        uint256 life;
        uint256 price;
        string alliance;
        string name;
        string position;
        uint256 starttime;
        uint256 [] attack_list;
        uint256 [] protect_list;
        bool isInit;
    }

    struct attack{
        address Address;
        uint256 Price;
        uint256 Time;
    }
    
    constructor(){
        contractOwner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }
    //check EOA
    function isHuman(address addr) internal view returns (bool) {
      uint size;
      assembly { size := extcodesize(addr) }
      return size == 0;
    }
    function initLandmark(string memory _name,string memory _position,string memory site,uint256 _nft) public onlyOwner{
        require(LandNFT.ownerOf(_nft) == address(this));
        require(lands[site].isInit == false);
        lands[site].alliance = "";
        lands[site].name = _name;
        lands[site].nft = _nft;
        lands[site].position = _position;
        lands[site].price = 0;
        lands[site].life = 100;
        lands[site].starttime=block.timestamp;
        lands[site].isInit = true;
    }
    function setAttackContract(address tokenAddress) public onlyOwner{
        AttackNFT = YORKMeta(tokenAddress);
    }
    function setProtectContract(address tokenAddress) public onlyOwner{
        ProtectNFT = YORKMeta(tokenAddress);
    }
    function setLandNFT(address tokenAddress) public onlyOwner{
        LandNFT = YORKMeta(tokenAddress);
    }
    function setAlliance(string memory _alliance,string memory site) public onlyOwner{
        require(lands[site].isInit == true);
        lands[site].alliance = _alliance;
    }
    function setPosition(string memory _position,string memory site) public onlyOwner{
        require(lands[site].isInit == true);
        lands[site].position = _position;
    }
    function setLandmarkName(string memory _name,string memory site) public onlyOwner{
        require(lands[site].isInit == true);
        lands[site].name = _name;
    }
    
    function setPrice(uint256 _value,address _address,string memory site) public{
        require(lands[site].isInit == true);
        lands[site].price +=_value;
        attackhistory[site]=attack({
            Address:_address,
            Price:_value,
            Time:block.timestamp
        });
    }
    
    function setLife(uint256 _life,string memory site) private {
        require(lands[site].isInit == true);
        lands[site].life -= _life;
    }

    function becomeking_ERC20(string memory _alliance,string memory site)payable public{
        require(isHuman(msg.sender));
        require(lands[site].isInit == true);
        require(msg.value>0 wei && msg.value<=15 wei*10000000000000000);
        uint256 _life = msg.value/10000000000000000 wei;
        if((lands[site].life-_life)<=100){
            setLife(_life,site);
            setPrice(_life,msg.sender,site);
        }
        if(lands[site].life<=0){
            lands[site].owner = payable(msg.sender);
            lands[site].owner.transfer((lands[site].price)* 10000000000000000 wei);
            lands[site].price = 0;
            lands[site].life = 100;
            //change alliance
            lands[site].alliance = _alliance;
            //transfer AttackNFT to winner
            uint256 a = lands[site].attack_list.length;
            for(uint256 i=0;i<a;i++){
                uint256 id = lands[site].attack_list[a-1-i];
                lands[site].attack_list.pop();
                AttackNFT.transferFrom(address(this),msg.sender,id);
                AttackNFT_exist[id] = false;
            }
            //transfer ProtectNFT to winner
            uint256 p = lands[site].protect_list.length;
            for(uint256 i=0;i<p;i++){
                uint256 id = lands[site].protect_list[p-1-i];
                lands[site].protect_list.pop();
                ProtectNFT.transferFrom(address(this),msg.sender,id);
                ProtectNFT_exist[id] = false;
            }
        }
    }

    function becomeking_NFT(string memory site,uint256 tokenId,string memory _alliance)payable public{
        require(isHuman(msg.sender));
        require(lands[site].isInit == true);
        require(AttackNFT.getHistory(tokenId).AfterOwner == address(this));
        require(AttackNFT.getHistory(tokenId).BeforeOwner == msg.sender);
        require(AttackNFT_exist[tokenId]==false);
        lands[site].attack_list.push(tokenId);
        AttackNFT_exist[tokenId] = true;
        uint256 _life = msg.value/10000000000000000 wei;
        if((lands[site].life-_life)<=100){
            setLife(_life,site);
            setPrice(_life,msg.sender,site);
        }
        if(lands[site].life<=0){
            lands[site].owner = payable(msg.sender);
            lands[site].owner.transfer((lands[site].price)* 10000000000000000 wei);
            lands[site].price = 0;
            lands[site].life = 100;
            //change alliance
            lands[site].alliance = _alliance;
            //transfer AttackNFT to winner
            uint256 a = lands[site].attack_list.length;
            for(uint256 i=0;i<a;i++){
                uint256 id = lands[site].attack_list[a-1-i];
                lands[site].attack_list.pop();
                AttackNFT.transferFrom(address(this),msg.sender,id);
                AttackNFT_exist[id] = false;
            }
            //transfer ProtectNFT to winner
            uint256 p = lands[site].protect_list.length;
            for(uint256 i=0;i<p;i++){
                uint256 id = lands[site].protect_list[p-1-i];
                lands[site].protect_list.pop();
                ProtectNFT.transferFrom(address(this),msg.sender,id);
                ProtectNFT_exist[id] = false;
            }
        }
    }
    
    function protect_ERC20(string memory site)payable public{
        require(isHuman(msg.sender));
        require(lands[site].isInit == true);
        require(msg.value>0 wei && msg.value<=15 wei*10000000000000000);
        uint256 _life = msg.value/10000000000000000 wei;
        require((lands[site].life+_life)>=0 && (lands[site].life+_life)<=100);
        lands[site].life += _life;
        setPrice(_life,msg.sender,site);
    }
    function protect_NFT(string memory site,uint256 tokenId)payable public{
        require(isHuman(msg.sender));
        require(lands[site].isInit == true);
        require(ProtectNFT.getHistory(tokenId).AfterOwner == address(this));
        require(ProtectNFT.getHistory(tokenId).BeforeOwner == msg.sender);
        require(ProtectNFT_exist[tokenId] == false);
        lands[site].protect_list.push(tokenId);
        ProtectNFT_exist[tokenId] = true;
        uint256 _life = msg.value/10000000000000000 wei;
        require((lands[site].life+_life)>=0 && (lands[site].life+_life)<=100);
        lands[site].life += _life;
        setPrice(_life,msg.sender,site);
    }
    function Attack_balance() view public returns(uint256){
        return AttackNFT.balanceOf(address(this));
    }
    function Protect_balance() view public returns(uint256){
        return ProtectNFT.balanceOf(address(this));
    }
    function tokenbalance(string memory site) view public returns(uint256){
        require(lands[site].isInit == true);
        return lands[site].price;
    }
    function life(string memory site) view public returns(uint256){
        require(lands[site].isInit == true);
        return lands[site].life;
    }
    function owner(string memory site) view public returns(address){
        require(lands[site].isInit == true);
        return lands[site].owner;
    }
    function alliance(string memory site) view public returns(string memory){
        require(lands[site].isInit == true);
        return lands[site].alliance;
    }
    function name(string memory site) view public returns(string memory){
        require(lands[site].isInit == true);
        return lands[site].name;
    }
    function position(string memory site) view public returns(string memory){
        require(lands[site].isInit == true);
        return lands[site].position;
    }
    function getLandURI(string memory site) view public returns(string memory){
        require(lands[site].isInit == true);
        uint256 index = lands[site].nft;
        return LandNFT.tokenURI(index);
    }

}



