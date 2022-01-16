// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 *
 *   =0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=
 *   =0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=
 *   
 *    _____ _____ _   _______ _____ ________  ___ ___ __   _______ 
 *   |  ___|_   _| | | | ___ |_   _/  __ |  \/  |/ _ \\ \ / |_   _|
 *   | |__   | | | |_| | |_/ / | | | /  \| .  . / /_\ \\ V /  | |  
 *   |  __|  | | |  _  | ___ \ | | | |   | |\/| |  _  |/   \  | |  
 *   | |___  | | | | | | |_/ / | | | \__/| |  | | | | / /^\ \_| |_ 
 *   \____/  \_/ \_| |_\____/  \_/  \____\_|  |_\_| |_\/   \/\___/                                                                                                                          
 *                                                                
 *   =0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=
 *   =0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=
 *
 *   Optimization credits: NuclearNerds.sol
 *
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721Enumerable.sol";

contract ETHBTCMaxiv2 is ERC721Enumerable, Ownable {
    string  public              baseURI;
    
    address public              proxyRegistryAddress;
    address public              devWallet;
    address public              xbtcAddress;

    uint256 public constant     MAX_SUPPLY          = 100;
    uint256 public constant     MINT_REWARD         = 210000000000; //0xbtc reward (divide by 10^8 to get units)
    uint256 public constant     MAX_PER_TX          = 10; //max number of tokens purchasable in 1 txn
    uint256 public constant     RESERVES            = 5; //tokens reserved for the team and free to mint (wont get mint reward)
    uint256 public constant     priceInWei          = 2 ether; //price

    constructor(
        string memory _baseURI,
        address _devWallet,
        address _xbtcAddress
    )
        ERC721("ETHBTCMaxi", "ETHBTCMaxi")
    {
        baseURI = _baseURI;
        devWallet = _devWallet;
        xbtcAddress = _xbtcAddress;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist.");
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId)));
    }

    function collectReserves() external onlyOwner {
        require(_owners.length == 0, 'Reserves already taken.');
        for(uint256 i; i < RESERVES; i++)
            _mint(_msgSender(), i);
    }

    function publicMint(uint256 count) public payable {
        uint256 totalSupply = _owners.length;
        require(totalSupply + count < MAX_SUPPLY, "Excedes max supply.");
        require(count < MAX_PER_TX, "Exceeds max per transaction.");
        require(count * priceInWei == msg.value, "Invalid funds provided.");

        for(uint i; i < count; i++) { 
            _mint(_msgSender(), totalSupply + i);
            IERC20(xbtcAddress).transfer(_msgSender(), MINT_REWARD);
        }
    }

    function burn(uint256 tokenId) public { 
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Not approved to burn.");
        _burn(tokenId);    
    }

    function withdraw() public  {
        (bool success, ) = devWallet.call{value: address(this).balance}("");
        require(success, "Failed to withdraw.");
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return new uint256[](0);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function batchTransferFrom(address _from, address _to, uint256[] memory _tokenIds) public {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            transferFrom(_from, _to, _tokenIds[i]);
        }
    }

    function batchSafeTransferFrom(address _from, address _to, uint256[] memory _tokenIds, bytes memory data_) public {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            safeTransferFrom(_from, _to, _tokenIds[i], data_);
        }
    }

    function isOwnerOf(address account, uint256[] calldata _tokenIds) external view returns (bool){
        for(uint256 i; i < _tokenIds.length; ++i ){
            if(_owners[_tokenIds[i]] != account)
                return false;
        }
        return true;
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        _owners.push(to);
        emit Transfer(address(0), to, tokenId);
    }
}