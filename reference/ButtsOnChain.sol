// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


// Added inline below

pragma solidity ^0.8.4;

library ButtLibrary {
    /**
     * @dev Inspired by OraclizeAPI's implementation - MIT license
     * @dev https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
     */
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0';
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>

pragma solidity ^0.8.4;

library Base64 {
    bytes internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return '';

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}


contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract ButtsOnChain is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _nextTokenId;

    uint256 public freeButts = 100;
    uint256 public maxSupply = 3333;
    uint256 public buttPrice = 0.0333 ether;

    uint256 public constant mintPrice = 30000000000000000; // 0.03 ETH.
    uint256 public constant maxMint = 10;
    uint256 public MAX_TOKENS = 10000;

    bool public claimActive;
    bool public mintActive;
    
    struct Butt {
        uint16 backgroundColor;
        uint16 buttCrackType;
        uint16 buttType;
    }

    // struct Color {
    //     string hexCode;
    //     string name;
    // }

    struct ButtCrackType {
        string name;
        string shape;
    }

    struct BackgroundColor {
        string hexCode;
        string name;
    }

    struct ButtType {
        string name;
        string shape;
        string lightHexCode;
        string darkHexCode;
    }

    mapping(uint256 => Butt) private tokenIdButt;

    // Color[] private backgroundColors;
    BackgroundColor[] private backgroundColors;
    
    ButtType[] private buttTypes;
    
    ButtCrackType[] private buttCrackTypes;

    uint16[][6] private traitWeights;

    // address public immutable proxyRegistryAddress;
    address public proxyRegistryAddress;
    bool public openSeaProxyActive;
    mapping(address => bool) public proxyToApproved;

    string[] private bgColors = ["#1A3201", "#FFFB0A", "#B5FB04", "#99FC06", "#7ECE06", "#49A117", "#2AA508", "#319E0C", "#366C00", "#072C02", "#234606"];

    function setButtCrackTypes(ButtCrackType[3] memory cracks) private {
        for (uint8 i = 0; i < cracks.length; i++) {
            buttCrackTypes.push(cracks[i]);
        }
    }

    function setBackgroundColors(BackgroundColor[8] memory colors) private {
        for (uint8 i = 0; i < colors.length; i++) {
            backgroundColors.push(colors[i]);
        }
    }
    function setButtTypes(ButtType[4] memory types) private {
        for (uint8 i = 0; i < types.length; i++) {
            buttTypes.push(types[i]);
        }
    }

    constructor(address _proxyRegistryAddress) ERC721('Butts On Chain', 'BUTT') {
        // Start at token 1
        _nextTokenId.increment();

        // Background colors rarity
        traitWeights[0] = [9000, 8000, 5000, 1, 2, 3, 4, 5];
        // Butt type rarity
        traitWeights[1] = [9000, 5000, 1000, 100];
        // Crack type rarity
        traitWeights[2] = [9000, 5000, 842];

        // OpenSea proxy contract
        proxyRegistryAddress = _proxyRegistryAddress;
        
        // Background colors
        setBackgroundColors(
            // TODO: Maybe remove "Color" and treat this like a normal array?
            // Otherwise, maybe move all these into vars in arrays like Larva Lads. 
            // Then use the random number here to pick the array index to use.
            [
                BackgroundColor({ hexCode: '#d5bada', name: 'Purple' }),
                BackgroundColor({ hexCode: '#000000', name: 'Green' }),
                BackgroundColor({ hexCode: '#ecc1db', name: 'Pink' }),
                BackgroundColor({ hexCode: '#e3c29e', name: 'Orange' }),
                BackgroundColor({ hexCode: '#9cd7d5', name: 'Turquoise' }),
                BackgroundColor({ hexCode: '#faf185', name: 'Yellow' }),
                BackgroundColor({ hexCode: '#b0d9f4', name: 'Blue' }),
                BackgroundColor({ hexCode: '#333333', name: 'Black' })
                // Color({ hexCode: '#d5bada', name: 'Purple' }),
                // Color({ hexCode: '#000000', name: 'Green' }),
                // Color({ hexCode: '#ecc1db', name: 'Pink' }),
                // Color({ hexCode: '#e3c29e', name: 'Orange' }),
                // Color({ hexCode: '#9cd7d5', name: 'Turquoise' }),
                // Color({ hexCode: '#faf185', name: 'Yellow' }),
                // Color({ hexCode: '#b0d9f4', name: 'Blue' }),
                // Color({ hexCode: '#333333', name: 'Black' })
            ]
        );

        // // Regular
        // setButtCrackType(
        //     0,
        //     "<g fill='#FFFFFF'><path d='M0 0H1V1H0V0zM0 1H1V2.00006L2 2.00006V4.00006H1L1 3.00006H0V1z'/></g>"
        // );

        // // Long
        // setButtCrackType(
        //     1,
        //     "<g fill='#000000'><path d='M0 0H1V1H0V0zM0 1H1V2.00006L2 2.00006V4.00006H1L1 3.00006H0V1z'/></g>"
        // );

        // // Tall
        // setButtCrackType(
        //     2,
        //     "<g fill='#DB0D0D'><path fill='black' fill-rule='evenodd' d='M2 0H0.999998V1H2V0ZM2 1.00006H0.999998V2.00006L-1.66893e-06 2.00006V3.00006V4.00006H1L0.999998 3.00006H2V2.00006V1.00006Z'/></g>"
        // );

        setButtCrackTypes(
            [
                ButtCrackType({
                    name: "Normal",
                    shape: "<g fill='#FFFFFF'><path d='M0 0H1V1H0V0zM0 1H1V2.00006L2 2.00006V4.00006H1L1 3.00006H0V1z'/></g>"
                }),
                ButtCrackType({
                    name: "Right",
                    shape: '<path fill="black" fill-rule="evenodd" d="M20 19H19V20H20V19ZM20 20.0001H19V21.0001L18 21.0001V22.0001V23.0001H19L19 22.0001H20V21.0001V20.0001Z" clip-rule="evenodd"/>'
                }),
                ButtCrackType({
                    name: "Tall",
                    shape: '<path d="M18 17H19V20H18V17zM19 20L20 20V21H19L19 20zM19 21H20V23.0001H19V21z"/>'
                })
            ]
        );

        // Butt Types
        setButtTypes(
            [
                ButtType({
                    name: 'Normal',
                    shape: '<polygon class="fur" points="22 1 22 0 21 0 20 0 18 0 17 0 15 0 14 0 10 0 9 0 6 0 5 0 3 0 2 0 2 1 1 1 1 2 1 4 1 5 1 7 2 7 2 8 3 8 3 9 5 9 6 9 9 9 10 9 10 8 12 8 12 9 14 9 15 9 17 9 18 9 18 8 20 8 20 7 21 7 21 6 23 6 23 5 23 4 23 2 23 1 22 1"/> <rect class="outline" x="1" y="7" width="1" height="1"/><rect class="outline" x="2" y="8" width="1" height="1"/><polygon class="outline" points="1 2 2 2 2 1 1 1 1 2 0 2 0 5 0 7 1 7 1 5 1 2"/><polygon class="cls-2" points="21 7 20 7 20 8 18 8 18 9 14 9 12 9 12 10 14 10 18 10 20 10 20 9 21 9 21 8 22 8 22 7 23 7 23 6 21 6 21 7"/> <polygon class="outline" points="23 2 23 5 23 6 24 6 24 5 24 2 23 2"/><rect class="outline" x="10" y="8" width="2" height="1"/><polygon class="outline" points="5 9 3 9 3 10 5 10 9 10 10 10 10 9 9 9 5 9"/><polygon class="cls-2" points="23 2 23 1 22 1 21 1 21 2 22 2 23 2"/> <polygon class="outline" points="4 1 4 0 3 0 2 0 2 1 3 1 4 1"/>',
                    lightHexCode: '#65bc48',
                    darkHexCode: '#567e39'
                }),
                ButtType({
                    name: 'Narrow',
                    shape: '<polygon class="fur" points="19,0 18,0 16,0 15,0 13,0 12,0 8,0 7,0 4,0 3,0 2,0 1,0 1,1 1,2 1,3 2,3 2,4 2,5 2,7 3,7 3,8 4,8 4,97,9 8,9 8,8 10,8 10,9 12,9 13,9 15,9 16,9 16,8 17,8 17,7 18,7 18,6 19,6 19,5 19,4 19,2 19,1 20,1 20,0"/><g><polygon class="outline" points="4,9 4,10 7,10 8,10 8,9 7,9"/><rect x="3" y="8" class="outline" width="1" height="1"/><rect x="8" y="8" class="outline" width="2" height="1"/><polygon class="outline" points="1,0 0,0 0,2 0,3 1,3 1,2"/><rect x="2" y="7" class="st1" width="1" height="1"/><polygon class="outline" points="2,3 1,3 1,5 1,7 2,7 2,5"/><rect x="16" y="8" class="outline" width="1" height="1"/><rect x="20" y="0" class="outline" width="1" height="1"/><polygon class="outline" points="10,9 10,10 12,10 16,10 16,9 12,9"/><polygon class="outline" points="19,2 19,5 19,6 20,6 20,5 20,2 20,1 19,1"/><rect x="18" y="6" class="outline" width="1" height="1"/><rect x="17" y="7" class="outline" width="1" height="1"/></g>',
                    lightHexCode: '#7ea26b',
                    darkHexCode: '#4c6141'
                }),
                ButtType({
                    name: 'Wide',
                    shape: '',
                    lightHexCode: '#d4af34',
                    darkHexCode: '#a07e2d'
                }),
                ButtType({
                    name: 'Alien',
                    shape: '',
                    lightHexCode: '#8cb0b0',
                    darkHexCode: '#578888'
                })
            ]
        );
    }
    // Not needed if using ERC721Enermerable
    // function totalSupply() public view returns (uint256) {
    //     return _nextTokenId.current() - 1;
    // }
    

    function weightedRarityGenerator(uint16 pseudoRandomNumber, uint8 trait) private view returns (uint16) {
        uint16 lowerBound = 0;

        for (uint8 i = 0; i < traitWeights[trait].length; i++) {
            
            uint16 weight = traitWeights[trait][i];

            if (pseudoRandomNumber >= lowerBound && pseudoRandomNumber < lowerBound + weight) {
                return i;
            }

            lowerBound = lowerBound + weight;
        }

        revert();
    }

    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, Strings.toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 randResult = rand % 10000;
        
        // if (randResult > 14) {
        //     // output = string(abi.encodePacked(output, " ", suffixes[rand % suffixes.length]));
        //     console.log(randResult);
        // } else {
        //     output = string(abi.encodePacked(output));
        // }
        return output;
    }

    function createTokenIdButt(uint256 tokenId) public view returns (Butt memory) {
        // Temp hidden while on local dev -- Using manual block number instead.
        uint256 pseudoRandomBase = uint256(keccak256(abi.encodePacked(blockhash(block.number * tokenId - 1), tokenId)));
        // uint256 pseudoRandomBase = uint256(keccak256(abi.encodePacked(uint(14252113), tokenId)));

        // uint16 _randinput = uint16(uint256(keccak256(abi.encodePacked(blockhash(block.timestamp), blockhash(block.difficulty)))) % 10000);
        // uint16 _randinput = uint16(uint256(keccak256(abi.encodePacked(uint(14252113)))) % 10000);
        uint16 _randinput = uint16(uint256(keccak256(abi.encodePacked(uint(14252113)))));

        console.log(uint16(uint16(pseudoRandomBase) % 8));

        return
            Butt({
                // this isnt working!
                // Something is breaking between here and getTokenIdButtMetadata. 
                // Using an int there works, but it doesn't work here. 
                // backgroundColor: uint16(3),
                backgroundColor: uint16(tokenId),
                // backgroundColor: weightedRarityGenerator(uint16(uint16(_randinput) % 10000), 0),
                // backgroundColor: pluck(uint256(tokenId), "COLOR", bgColors),
                buttType: weightedRarityGenerator(uint16(uint16(_randinput) % 10000), 1),
                buttCrackType: weightedRarityGenerator(uint16(uint16(_randinput) % 10000), 2)
            });
    }

    function getButtBase(Butt memory butt) private view returns (string memory buttBase) {
        buttBase = string(
            abi.encodePacked(
                "<rect fill='",
                backgroundColors[butt.backgroundColor].hexCode,
                "' height='40' width='40' />"
            )
        );

        return buttBase;
    }

    function getButtType(Butt memory butt) private view returns (string memory buttType) {
        buttType = string(
            abi.encodePacked(buttTypes[butt.buttType].shape)
        );

        // console.log(buttType);

        return buttType;
    }

    function getButtCrack(Butt memory butt) private view returns (string memory buttCrack) {
        buttCrack = string(
            abi.encodePacked(buttCrackTypes[butt.buttCrackType].shape)
        );
        
        // console.log(buttCrack);

        return buttCrack;
    }


    function getTokenIdButtSvg(Butt memory butt) public view returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                getButtBase(butt),
                getButtCrack(butt),
                getButtType(butt)
            )
        );

        return
            string(
                abi.encodePacked(
                    "<svg id='butt' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 40 40'>",
                        '<defs><style>.fur{fill:#7d78a5;fill-rule:evenodd;}.outline{fill:#100c0a;}.highlight{fill:#9995B8;}</style></defs>',
                        '<g><rect x="4" y="3" class="outline" width="1" height="1"/><rect x="2" y="5" class="outline" width="1" height="2"/><polygon class="outline" points="6,2 5,2 5,3 6,3 7,3 7,2 7,1 6,1"/><rect x="0" y="8" class="outline" width="1" height="3"/><rect x="1" y="7" class="outline" width="1" height="1"/><polygon class="outline" points="10,3 10,4 11,4 11,3 12,3 12,2 10,2"/><polygon class="outline" points="8,0 7,0 7,1 8,1 9,1 9,0"/><rect x="3" y="4" class="outline" width="1" height="1"/><polygon class="outline" points="20,8 19,8 19,9 20,9 21,9 21,8"/><rect x="18" y="6" class="outline" width="1" height="2"/><rect x="21" y="9" class="outline" width="1" height="2"/><polygon class="outline" points="18,4 17,4 17,5 17,6 18,6 18,5"/><rect x="16" y="3" class="outline" width="1" height="1"/><rect x="12" y="1" class="outline" width="3" height="1"/><rect x="9" y="1" class="outline" width="1" height="1"/><rect x="15" y="2" class="outline" width="1" height="1"/><rect x="16" y="5" class="outline" width="1" height="1"/><rect x="15" y="6" class="outline" width="1" height="1"/></g><polygon class="fur" points="20,9 19,9 19,8 18,8 18,7 18,6 17,6 17,5 17,4 16,4 16,3 15,3 15,4 15,4 15,3 15,3 15,2 14,2 13,212,2 12,3 11,3 10,3 10,2 9,2 9,1 8,1 7,1 7,2 6,2 6,3 5,3 5,4 4,4 4,5 3,5 3,6 3,7 2,7 2,8 1,8 1,9 1,10 1,11 2,11 3,11 4,11 5,116,11 7,11 8,11 9,11 10,11 11,11 12,11 13,11 14,11 15,11 16,11 17,11 18,11 19,11 20,11 21,11 21,10 21,9"/><g><polygon class="highlight" points="5,5 5,6 6,6 7,6 7,5 6,5"/><polygon class="highlight" points="14,3 13,3 13,4 14,4 15,4 15,3"/></g>',
                        svg,
                    '<style>#butt{shape-rendering:crispedges;}</style></svg>'
                )
            );
    }

    function getTokenIdButtMetadata(Butt memory butt) public view returns (string memory metadata) {
        metadata = string(
            abi.encodePacked(
                metadata,
                '{"trait_type":"Background", "value":"',
                backgroundColors[butt.backgroundColor].name,
                Strings.toString(butt.backgroundColor),
                '"},',
                '{"trait_type":"Type", "value":"',
                buttTypes[butt.buttType].name,
                Strings.toString(butt.buttType),
                '"},',
                '{"trait_type":"Butt crack", "value":"',
                buttCrackTypes[butt.buttCrackType].name,
                Strings.toString(butt.buttCrackType),
                '"}'
            )
        );

        return string(abi.encodePacked('[', metadata, ']'));
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId));
        Butt memory butt = tokenIdButt[tokenId];

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "On Chain Butt #',
                                    ButtLibrary.toString(tokenId),
                                    '", "description": "Butts on butts on butts on chain", "image": "data:image/svg+xml;base64,',
                                    Base64.encode(bytes(getTokenIdButtSvg(butt))),
                                    '","attributes":',
                                    getTokenIdButtMetadata(butt),
                                    '}'
                                )
                            )
                        )
                    )
                )
            );
    }

    function internalMint(uint256 numberOfTokens) private {
        require(numberOfTokens > 0, 'Quantity must be greater than 0.');
        require(numberOfTokens < 11, 'Exceeds max per mint.');
        require(totalSupply() + numberOfTokens <= maxSupply, 'Exceeds max supply.');

        for (uint256 i = 0; i < numberOfTokens; i++) {
            // console.log(i);
            uint256 tokenId = _nextTokenId.current();

            tokenIdButt[tokenId] = createTokenIdButt(tokenId);
            
            _safeMint(msg.sender, tokenId);

            _nextTokenId.increment();
        }
    }

    function ownerClaim(uint256 numberOfTokens) external onlyOwner {
        internalMint(numberOfTokens);
    }

    function claim(uint256 numberOfTokens) external {
        require(claimActive, 'Claiming not active yet.');
        require(totalSupply() + numberOfTokens <= freeButts, 'Exceeds claim supply.');

        internalMint(numberOfTokens);
    }

    // function mint(uint256 numberOfTokens) external payable {
    //     require(mintActive, 'Mint not active yet.');
    //     require(msg.value >= numberOfTokens * buttPrice, 'Wrong ETH value sent.');

    //     internalMint(numberOfTokens);
    // }

    // The main token minting function (recieves Ether).
    function mint(uint256 numberOfTokens) public payable {
        // Number of tokens can't be 0.
        require(numberOfTokens != 0, "You need to mint at least 1 token");
        // Check that the number of tokens requested doesn't exceed the max. allowed.
        require(numberOfTokens <= maxMint, "You can only mint 10 tokens at a time");
        // Check that the number of tokens requested wouldn't exceed what's left.
        require(totalSupply().add(numberOfTokens) <= MAX_TOKENS, "Minting would exceed max. supply");
        // Check that the right amount of Ether was sent.
        require(mintPrice.mul(numberOfTokens) <= msg.value, "Not enough Ether sent.");

        // For each token requested, mint one.
        for(uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if(mintIndex < MAX_TOKENS) {
                /** 
                 * Mint token using inherited ERC721 function
                 * msg.sender is the wallet address of mint requester
                 * mintIndex is used for the tokenId (must be unique)
                 */
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function setFreeButts(uint256 newFreeButts) external onlyOwner {
        require(newFreeButts <= maxSupply, 'Would increase max supply.');
        freeButts = newFreeButts;
    }

    function setButtPrice(uint256 newButtPrice) external onlyOwner {
        buttPrice = newButtPrice;
    }

    function toggleClaim() external onlyOwner {
        claimActive = !claimActive;
    }

    function toggleMint() external onlyOwner {
        mintActive = !mintActive;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Not needed with enumerable
    // function isApprovedForAll(address owner, address operator) public view override returns (bool) {
    //     // Allow OpenSea proxy contract
    //     ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

    //     if (address(proxyRegistry.proxies(owner)) == operator) {
    //         return openSeaProxyActive;
    //     }

    //     // Allow future contracts
    //     if (proxyToApproved[operator]) {
    //         return true;
    //     }

    //     return super.isApprovedForAll(owner, operator);
    // }

    function reduceSupply() external onlyOwner {
        require(totalSupply() < maxSupply, 'All minted.');
        maxSupply = totalSupply();
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}