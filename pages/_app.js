import '../styles/globals.css';
// import { getDefaultProvider, getNetwork, ethers } from 'ethers';
// import { NftProvider, useNft } from "use-nft"

// const devNetwork = {
//   name: "dev",
//   chainId: 31337,
//   ensAddress: process.env.NEXT_PUBLIC_MINTER_ADDRESS
// };



function MyApp({ Component, pageProps }) {
  // const ethersConfig = {
  //   // provider: ethers.providers.getNetwork(devNetwork)
  //   provider: ethers.providers.getNetwork('31337')
  // }

  // function Nft() {
  //   const { loading, error, nft } = useNft(
  //     "0x5fbdb2315678afecb367f032d93f642f64180aa3", "0"
  //   )
  
  //   // nft.loading is true during load.
  //   if (loading) {
  //     console.log('loading'); return <>Loading…</>;
  //   }
  
  //   // nft.error is an Error instance in case of error.
  //   if (error || !nft) {
  //     console.log('error or no nft'); 
  //     return <>Error.</>
  //   }
    
  //   console.log(nft);
  
  //   // You can now display the NFT metadata.
  //   return (
  //     <section>
  //       <h1>{nft.name}</h1>
  //       <img src={nft.image} alt="" />
  //       <p>{nft.description}</p>
  //       <p>Owner: {nft.owner}</p>
  //       <p>Metadata URL: {nft.metadataUrl}</p>
  //     </section>
  //   )
  // }

  return (
    <>
      {/* <NftProvider fetcher={["ethers", ethersConfig]}> */}
        <Component {...pageProps} />
        {/* <Nft /> */}
      {/* </NftProvider> */}
    </>
    )
}

export default MyApp
