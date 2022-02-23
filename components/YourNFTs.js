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

    const [visibleNft, setVisibleNft] = useState([])

    let collection = [];
    let tokenURIIndividual = [];



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

            const { chainId } = await provider.getNetwork()
            console.log('chainId:', chainId) 

            const block = await provider.getBlockNumber();
            console.log('block #', block);

            // const count = mintedCount.toString();
            const loopCount = mintedCount.toNumber();
            console.log('count: ', mintedCount, loopCount);
            // Get amount of tokens owned by this address
            
            // For each token, get the tokenId
            const tokenURIs = []

            // tokenURIIndividual = await contract.tokenURI(3);
            // const cleanToken = tokenURIIndividual.substring(29);
            // const jsonToken = Buffer.from(cleanToken, "base64").toString();
            // const resultToken = JSON.parse(jsonToken);
            // console.log(tokenURIIndividual, resultToken);
            // const i = 2;
            // let tokenURI;
            // tokenURI = await contract.tokenURI(i);
            // console.log(tokenURI);
            for(let i = 1; i < mintedCount; i++) {
                console.log(i);
                const tokenURI = await contract.tokenURI(i);
                
                // console.log(i, tokenURI);    
                const clean = tokenURI.substring(29);
                const json = Buffer.from(clean, "base64").toString();
                const result = JSON.parse(json);

                // console.log('json:', json, json.image, result, result.image);
                tokenURIs.push(result);
            }
  
            setNftsMetaData(tokenURIs);
            setVisibleNft(resultToken);
            console.log(collection, tokenURIIndividual);
          } catch(error) {
              console.log(error)
          }
          console.log(collection);
    }

    

    
    // if(nfts.length < 1) return null;

    return (
        <>
            <h2 className="text-2xl font-semibold mb-2">Your NFTs</h2>
            {/* <ul className="grid grid-cols-4 gap-6"> */}
            <ul className="grid grid-cols-4 gap-6">
                {/* { nfts.map( (nft) => <div key={nft} className="bg-gray-100 p-4 h-24 lg:h-28 flex justify-center items-center text-lg">{nft}</div>)} */}
                { nftsMetaData.map( (nft, i) => {
                    console.log(nft, nft.image);
                    return (
                    // <li key={i} className="bg-gray-100 p-4 h-24 lg:h-28 flex justify-center items-center text-lg">
                    <li key={i} className="">
                        {/* {nft.name} | */}
                        <img src={nft.image} alt="" />
                    </li>    
                    )
                })}              
            </ul>
        </>
    )
}