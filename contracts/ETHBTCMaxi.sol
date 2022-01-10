// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 *
 *   =0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=
 *   =0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=o0o=0o0=
 *    _____ _____ _   _ ______ _______   _____  ___           _ 
 *   |  ___|_   _| | | || ___ \_   _\ \ / /|  \/  |          (_)
 *   | |__   | | | |_| || |_/ / | |  \ V / | .  . | __ ___  ___ 
 *   |  __|  | | |  _  || ___ \ | |  /   \ | |\/| |/ _` \ \/ / |
 *   | |___  | | | | | || |_/ / | | / /^\ \| |  | | (_| |>  <| |
 *   \____/  \_/ \_| |_/\____/  \_/ \/   \/\_|  |_/\__,_/_/\_\_|                                                         
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

contract ETHBTCMaxi is ERC721Enumerable, Ownable {
    string  public              baseURI;
    
    address public              proxyRegistryAddress;
    address public              devWallet;
    address public              xbtcAddress;

    uint256 public constant     MAX_SUPPLY          = 100;
    uint256 public constant     BURN_REWARD    = 210000000000;
    uint256 public constant     MAX_PER_TX          = 10;
    uint256 public constant     RESERVES            = 5;
    uint256 public constant     priceInWei          = 0.065 ether;

    constructor(
        string memory _baseURI, 
        address _proxyRegistryAddress, 
        address _devWallet,
        address _xbtcAddress
    )
        ERC721("ETHBTCMaxi", "ETHBTCMaxi")
    {
        baseURI = _baseURI;
        proxyRegistryAddress = _proxyRegistryAddress;
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
        }
    }

    function burn(uint256 tokenId) public { 
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Not approved to burn.");
        _burn(tokenId);
        require(_owners[tokenId] == address(0));
        IERC20(xbtcAddress).transfer(_msgSender(), BURN_REWARD);
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

    function isApprovedForAll(address _owner, address operator) public view override returns (bool) {
        OpenSeaProxyRegistry proxyRegistry = OpenSeaProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == operator) return true;
        return super.isApprovedForAll(_owner, operator);
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        _owners.push(to);
        emit Transfer(address(0), to, tokenId);
    }
}

contract OwnableDelegateProxy { }
contract OpenSeaProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}