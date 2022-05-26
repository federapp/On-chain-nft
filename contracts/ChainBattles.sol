// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIds;

    struct Attributes {
        uint256 levels;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    mapping(uint256 => Attributes) public tokenIdToAttributes;
    
    constructor() ERC721 ("Chain Battles", "CBTLS"){

    }

    function generateCharacter(uint256 tokenId) public returns(string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",getLife(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }


    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToAttributes[tokenId].levels;
        return levels.toString();
    }

    function getLife(uint256 tokenId) public view returns (string memory) {
        uint256 life = tokenIdToAttributes[tokenId].life;
        return life.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint256 speed = tokenIdToAttributes[tokenId].speed;
        return speed.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint256 strength = tokenIdToAttributes[tokenId].strength;
        return strength.toString();
    }


    uint initialNumber;
    function randomNumber(uint256 number) public returns(uint256){
        return uint256(keccak256(abi.encodePacked(initialNumber++))) % number;
    }

    function getTokenURI(uint256 tokenId) public returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToAttributes[newItemId].levels = 0;
        tokenIdToAttributes[newItemId].speed = randomNumber(25);
        tokenIdToAttributes[newItemId].strength = randomNumber(25);
        tokenIdToAttributes[newItemId].life = randomNumber(25);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender,"You must be the owner to train it");
        
        uint256 currentLevel = tokenIdToAttributes[tokenId].levels;
        tokenIdToAttributes[tokenId].levels = currentLevel + 1;
        
        uint256 currentSpeed = tokenIdToAttributes[tokenId].speed;
        tokenIdToAttributes[tokenId].speed = currentSpeed + randomNumber(7);
        
        uint256 currentLife = tokenIdToAttributes[tokenId].life;
        tokenIdToAttributes[tokenId].life = currentLife + randomNumber(7);
        
        uint256 currentStrength = tokenIdToAttributes[tokenId].strength;
        tokenIdToAttributes[tokenId].strength = currentStrength + randomNumber(7);

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }


}