// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Added inline below

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

    struct Color {
        string hexCode;
        string name;
    }

    struct ButtCrackType {
        string name;
        string shape;
    }

    struct ButtType {
        string name;
        string lightHexCode;
        string darkHexCode;
    }

    mapping(uint256 => Butt) private tokenIdButt;

    Color[] private backgroundColors;
    
    ButtType[] private buttTypes;
    
    ButtCrackType[] private buttCrackTypes;

    uint16[][6] private traitWeights;

    // address public immutable proxyRegistryAddress;
    address public proxyRegistryAddress;
    bool public openSeaProxyActive;
    mapping(address => bool) public proxyToApproved;

    function setButtCrackTypes(ButtCrackType[3] memory cracks) private {
        for (uint8 i = 0; i < cracks.length; i++) {
            buttCrackTypes.push(cracks[i]);
        }
    }

    function setBackgroundColors(Color[8] memory colors) private {
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

        // Crack type rarity
        traitWeights[0] = [1248, 986, 842];

        // Background colors rarity
        traitWeights[1] = [3200, 1200, 500];

        // Butt type rarity
        traitWeights[2] = [1622, 3378, 500, 100];

        // OpenSea proxy contract
        proxyRegistryAddress = _proxyRegistryAddress;
        
        // Background colors
        setBackgroundColors(
            [
                Color({ hexCode: '#bcdfb9', name: 'Green' }),
                Color({ hexCode: '#d5bada', name: 'Purple' }),
                Color({ hexCode: '#ecc1db', name: 'Pink' }),
                Color({ hexCode: '#e3c29e', name: 'Orange' }),
                Color({ hexCode: '#9cd7d5', name: 'Turquoise' }),
                Color({ hexCode: '#faf185', name: 'Yellow' }),
                Color({ hexCode: '#b0d9f4', name: 'Blue' }),
                Color({ hexCode: '#333333', name: 'Black' })
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
                    name: "Test",
                    shape: "<g fill='#000000'><path d='M0 0H1V1H0V0zM0 1H1V2.00006L2 2.00006V4.00006H1L1 3.00006H0V1z'/></g>"
                }),
                ButtCrackType({
                    name: "Test",
                    shape: "<g fill='#DB0D0D'><path fill-rule='evenodd' d='M2 0H0.999998V1H2V0ZM2 1.00006H0.999998V2.00006L-1.66893e-06 2.00006V3.00006V4.00006H1L0.999998 3.00006H2V2.00006V1.00006Z'/></g>"
                })
            ]
        );

        // Butt Types
        setButtTypes(
            [
                ButtType({
                    name: 'Normal',
                    lightHexCode: '#65bc48',
                    darkHexCode: '#567e39'
                }),
                ButtType({
                    name: 'Zombie',
                    lightHexCode: '#7ea26b',
                    darkHexCode: '#4c6141'
                }),
                ButtType({
                    name: 'Droid',
                    lightHexCode: '#d4af34',
                    darkHexCode: '#a07e2d'
                }),
                ButtType({
                    name: 'Alien',
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

    function createTokenIdButt(uint256 tokenId) public view returns (Butt memory) {
        uint256 pseudoRandomBase = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), tokenId)));


        // NOTE: Maybe the issue is in this function/structure?
        return
            Butt({
                backgroundColor: uint16(uint16(pseudoRandomBase) % 8),
                // Note: Looks like removing weightedRarity solves the error.
                buttCrackType: weightedRarityGenerator(uint16(uint16(pseudoRandomBase >> 1) % maxSupply), 0),
                buttType: weightedRarityGenerator(uint16(uint16(pseudoRandomBase >> 10) % maxSupply), 2)
            });
    }

    function getButtBase(Butt memory butt) private view returns (string memory buttBase) {
        return
            string(
                abi.encodePacked(
                    "<rect fill='",
                    backgroundColors[butt.backgroundColor].hexCode,
                    "' height='40' width='40' />"
                )
            );
    }

    function getButtCrack(Butt memory butt) private view returns (string memory buttCrack) {
        buttCrack = string(
            abi.encodePacked(
                buttCrackTypes[butt.buttCrackType].shape
            )
        );

        return buttCrack;
    }


    function getTokenIdButtSvg(Butt memory butt) public view returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                getButtBase(butt),
                getButtCrack(butt)
            )
        );

        return
            string(
                abi.encodePacked(
                    "<svg id='butt' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 40 40'>",
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
                '"},',
                '{"trait_type":"Type", "value":"',
                buttTypes[butt.buttType].name,
                '"},',
                '{"trait_type":"Butt crack", "value":"',
                buttCrackTypes[butt.buttCrackType].name,
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
        console.log("Empty internal mint");
        require(numberOfTokens > 0, 'Quantity must be greater than 0.');
        require(numberOfTokens < 11, 'Exceeds max per mint.');
        require(totalSupply() + numberOfTokens <= maxSupply, 'Exceeds max supply.');
        console.log(numberOfTokens);

        for (uint256 i = 0; i < numberOfTokens; i++) {
            console.log(i);
            uint256 tokenId = _nextTokenId.current();
            // console.log(tokenId);
            // console.log(msg.sender);

            // NOTE: This line is where the error starts.
            tokenIdButt[tokenId] = createTokenIdButt(tokenId);
            
            _safeMint(msg.sender, tokenId);

            _nextTokenId.increment();
        }
    }

    function ownerClaim(uint256 numberOfTokens) external onlyOwner {
        internalMint(numberOfTokens);
    }

    function claim(uint256 numberOfTokens) external {
        console.log("Claim function");
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