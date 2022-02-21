import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import { getDefaultProvider, } from "ethers"
import { NftProvider, useNft } from "use-nft"

import { hasEthereum, requestAccount } from '../utils/ethereum'
// import Minter from '../src/artifacts/contracts/Minter.sol/Minter.json'
import Minter from '../src/artifacts/contracts/ButtsOnChain.sol/ButtsOnChain.json'

export default function YourNFTs() {
    // UI state
    const [nfts, setNfts] = useState([])

    const [nftsMetaData, setNftsMetaData] = useState([])

    let collection = [];

    const ethersConfig = {
        provider: getDefaultProvider("homestead"),
    }
    
    // useEffect( function() {
    //     // getNftsOfCurrentWallet();
    //     showAllMintedNFTs();
    // });
    useEffect(() => showAllMintedNFTs(), []);


    // Get NFTs owned by current wallet
    async function getNftsOfCurrentWallet() {
        if(! hasEthereum()) return

        try {
            // Fetch data from contract
            const provider = new ethers.providers.Web3Provider(window.ethereum)
            const signer = provider.getSigner()
            const contract = new ethers.Contract(process.env.NEXT_PUBLIC_MINTER_ADDRESS, Minter.abi, provider)
            const address = await signer.getAddress()
            // Get amount of tokens owned by this address
            const tokensOwned = await contract.balanceOf(address)
            
            // For each token owned, get the tokenId
            const tokenIds = []

            for(let i = 0; i < tokensOwned; i++) {
                const tokenId = await contract.tokenOfOwnerByIndex(address, i);
                tokenIds.push(tokenId.toString());
            }
  
            setNfts(tokenIds)
          } catch(error) {
              console.log(error)
          }
    }

    async function showAllMintedNFTs() {
        if(! hasEthereum()) return

        try {
            // Fetch data from contract
            const provider = new ethers.providers.Web3Provider(window.ethereum)
            const signer = provider.getSigner()
            const contract = new ethers.Contract(process.env.NEXT_PUBLIC_MINTER_ADDRESS, Minter.abi, provider)
            const mintedCount = await contract.totalSupply();
            // const count = mintedCount.toString();
            const loopCount = mintedCount.toNumber();
            console.log('count: ', mintedCount, loopCount);
            // Get amount of tokens owned by this address
            
            // For each token, get the tokenId
            const tokenURIs = []

            for(let i = 0; i < loopCount; i++) {
                const tokenURI = await contract.tokenURI(i);
                
                // console.log(i, tokenURI);
                const clean = tokenURI.substring(29);
                const json = Buffer.from(clean, "base64").toString();
                const result = JSON.parse(json);

                // console.log('json:', json, json.image, result, result.image);
                tokenURIs.push(result);
            }
  
            setNftsMetaData(tokenURIs)
            console.log(collection);
          } catch(error) {
              console.log(error)
          }
          console.log(collection);
    }

    
    // if(nfts.length < 1) return null;

    return (
        <>
            <h2 className="text-2xl font-semibold mb-2">Your NFTs</h2>
            <ul className="grid grid-cols-4 gap-6">
                {/* { nfts.map( (nft) => <div key={nft} className="bg-gray-100 p-4 h-24 lg:h-28 flex justify-center items-center text-lg">{nft}</div>)} */}
                collection: {collection}
                <div>
                { nftsMetaData.map( (nft, i) => {
                    console.log(nft, nft.image);
                    return (
                    <li key={i} className="bg-gray-100 p-4 h-24 lg:h-28 flex justify-center items-center text-lg">
                        {nft.name} |
                        <img src={nft.image} alt="" />
                    </li>    
                    )
                })}   
                </div>             
            </ul>
        </>
    )
}