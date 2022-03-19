/* eslint-disable @next/next/no-img-element */
import Head from 'next/head'
import { useState, useRef } from 'react'
import { ethers } from 'ethers'
import { hasEthereum } from '../utils/ethereum'
// import Minter from '../src/artifacts/contracts/Minter.sol/Minter.json'
import Minter from '../src/artifacts/contracts/ButtsOnChain.sol/ButtsOnChain.json'
import TotalSupply from '../components/TotalSupply'
import Wallet from '../components/Wallet'
import YourNFTs from '../components/YourNFTs'
import parse from 'html-react-parser';


export default function Home() {
  // Constants
  const MINT_PRICE = 0.03;
  const MAX_MINT = 10;

  // UI state
  const [mintQuantity, setMintQuantity] = useState(1)
  const mintQuantityInputRef = useRef()
  const [mintError, setMintError] = useState(false)
  const [mintMessage, setMintMessage] = useState('')
  const [mintLoading, setMintLoading] = useState(false)

  // SVG elements
  const colors = [ '#000000', '#800000', '#008000', '#808000', '#000080', '#800080', '#008080', '#c0c0c0', '#808080', '#ff0000', '#00ff00', '#ffff00', '#0000ff', '#ff00ff', '#00ffff', '#ffffff', '#000000', '#00005f', '#000087', '#0000af', '#0000d7', '#0000ff', '#005f00', '#005f5f', '#005f87', '#005faf', '#005fd7', '#005fff', '#008700', '#00875f', '#008787', '#0087af', '#0087d7', '#0087ff', '#00af00', '#00af5f', '#00af87', '#00afaf', '#00afd7', '#00afff', '#00d700', '#00d75f', '#00d787', '#00d7af', '#00d7d7', '#00d7ff', '#00ff00', '#00ff5f', '#00ff87', '#00ffaf', '#00ffd7', '#00ffff', '#5f0000', '#5f005f', '#5f0087', '#5f00af', '#5f00d7', '#5f00ff', '#5f5f00', '#5f5f5f', '#5f5f87', '#5f5faf', '#5f5fd7', '#5f5fff', '#5f8700', '#5f875f', '#5f8787', '#5f87af', '#5f87d7', '#5f87ff', '#5faf00', '#5faf5f', '#5faf87', '#5fafaf', '#5fafd7', '#5fafff', '#5fd700', '#5fd75f', '#5fd787', '#5fd7af', '#5fd7d7', '#5fd7ff', '#5fff00', '#5fff5f', '#5fff87', '#5fffaf', '#5fffd7', '#5fffff', '#870000', '#87005f', '#870087', '#8700af', '#8700d7', '#8700ff', '#875f00', '#875f5f', '#875f87', '#875faf', '#875fd7', '#875fff', '#878700', '#87875f', '#878787', '#8787af', '#8787d7', '#8787ff', '#87af00', '#87af5f', '#87af87', '#87afaf', '#87afd7', '#87afff', '#87d700', '#87d75f', '#87d787', '#87d7af', '#87d7d7', '#87d7ff', '#87ff00', '#87ff5f', '#87ff87', '#87ffaf', '#87ffd7', '#87ffff', '#af0000', '#af005f', '#af0087', '#af00af', '#af00d7', '#af00ff', '#af5f00', '#af5f5f', '#af5f87', '#af5faf', '#af5fd7', '#af5fff', '#af8700', '#af875f', '#af8787', '#af87af', '#af87d7', '#af87ff', '#afaf00', '#afaf5f', '#afaf87', '#afafaf', '#afafd7', '#afafff', '#afd700', '#afd75f', '#afd787', '#afd7af', '#afd7d7', '#afd7ff', '#afff00', '#afff5f', '#afff87', '#afffaf', '#afffd7', '#afffff', '#d70000', '#d7005f', '#d70087', '#d700af', '#d700d7', '#d700ff', '#d75f00', '#d75f5f', '#d75f87', '#d75faf', '#d75fd7', '#d75fff', '#d78700', '#d7875f', '#d78787', '#d787af', '#d787d7', '#d787ff', '#d7af00', '#d7af5f', '#d7af87', '#d7afaf', '#d7afd7', '#d7afff', '#d7d700', '#d7d75f', '#d7d787', '#d7d7af', '#d7d7d7', '#d7d7ff', '#d7ff00', '#d7ff5f', '#d7ff87', '#d7ffaf', '#d7ffd7', '#d7ffff', '#ff0000', '#ff005f', '#ff0087', '#ff00af', '#ff00d7', '#ff00ff', '#ff5f00', '#ff5f5f', '#ff5f87', '#ff5faf', '#ff5fd7', '#ff5fff', '#ff8700', '#ff875f', '#ff8787', '#ff87af', '#ff87d7', '#ff87ff', '#ffaf00', '#ffaf5f', '#ffaf87', '#ffafaf', '#ffafd7', '#ffafff', '#ffd700', '#ffd75f', '#ffd787', '#ffd7af', '#ffd7d7', '#ffd7ff', '#ffff00', '#ffff5f', '#ffff87', '#ffffaf', '#ffffd7', '#ffffff', '#080808', '#121212', '#1c1c1c', '#262626', '#303030', '#3a3a3a', '#444444', '#4e4e4e', '#585858', '#606060', '#666666', '#767676', '#808080', '#8a8a8a', '#949494', '#9e9e9e', '#a8a8a8', '#b2b2b2', '#bcbcbc', '#c6c6c6', '#d0d0d0', '#dadada', '#e4e4e4', '#eeeeee' ]
  
  // TODO: 
  // Randomly choose with weight. Look at Loot for inspo. Greatness ranking.

  function randomlyChoose(part) {
    const chosen = part[Math.floor(Math.random() * part.length)];
    // console.log(chosen);
    return chosen;
  }

  function GetParts(color) {
    // const backgroundColor = randomlyChoose(backgroundColors);
    // const colorPalette = randomlyChoose(colorPalettes);
    // const bodyType = randomlyChoose(bodyTypes);
    // const buttType = randomlyChoose(buttTypes);
    // const buttCrack = randomlyChoose(buttCracks);

    // Loop through array in order
    const textColor = colors[color.color];
    const frameColor = randomlyChoose(colors);
    const backgroundColor = colors[color.color];
    const monoColor = randomlyChoose(colors);
    
    // Random from the array
    // const textColor = randomlyChoose(colors);
    // const frameColor = randomlyChoose(colors);
    // const backgroundColor = randomlyChoose(colors);
    // const monoColor = randomlyChoose(colors);


    const image = ('<svg id="butt" preserveAspectRatio="xMinYMin meet" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs>' + 
      // `<style>.bg{fill:${monoColor}}.txt{fill:${monoColor};}.fr{fill: transparent;stroke:${monoColor}}.txt,.fr{filter: brightness(0.8); mix-blend-mode: multiply;}}#butt{shape-rendering:crispedges;}</style></defs>`+ 
      `<style>.bg{fill:${backgroundColor}}.txt{fill:${frameColor};}.fr{fill: transparent;stroke:${frameColor}}.txt,.fr{filter: brightness(1.2);}}#butt{shape-rendering:crispedges;}</style></defs>`+ 
      // '<rect class="bg" height="24" width="24" />' +
      '<path class="bg" d="M0 0h24v24H0z"/>' +
      `<path class="fr" d="M.5.5h23v23H.5z"/>` +
      `<path class="txt" d="M2 22v-6h3.999v1h-3v1.001h3v1h-3V22H2zM8 22v-1h2v1H8zm-1-1v-5h1v5H7zm3 0v-5h.999v5h-1zM13 22v-1h2v1h-2zm2-1v-1h.999v1h-1zm-3 0v-4h1v4h-1zm3-2.999V17h.999v1.001h-1zM13 17v-1h2v1h-2zM20 22v-2h.999v2h-1zm-1-2v-1h1v1h-1zm0-1.999V17h1v1.001h-1zM17 22v-6h1v2.001h1v1h-1V22h-1zm3-5v-1h.999v1h-1z"/>` +
      // `<path class="txt" d="M0 6V0h3.999v1h-3v1.001h3v1h-3V6H0zM6 6V5h2v1H6zM5 5V0h1v5H5zm3 0V0h.999v5h-1zM11 6V5h2v1h-2zm-1-1V0h1v5h-1zm3 0V0h.999v5h-1zM16 6V5h2v1h-2zm-1-1V0h1v5h-1zm3 0V0h.999v5h-1zM1 13v-1h2v1H1zm-1-1V7h1v5H0zm3 0V7h.999v5h-1zM6 13v-1h2v1H6zm-1-1V7h1v5H5zm3 0V7h.999v5h-1zM11 13v-1h2v1h-2zm-1-1V7h1v5h-1zm3 0V7h.999v5h-1zM16 13v-1h2v1h-2zm-1-1V7h1v5h-1zm3 0V7h.999v5h-1zM1 20v-1h2v1H1zm-1-1v-5h1v5H0zm3 0v-5h.999v5h-1zM6 20v-1h2v1H6zm-1-1v-5h1v5H5zm3 0v-5h.999v5h-1zM11 20v-1h2v1h-2zm2-1v-1h.999v1h-1zm-3 0v-4h1v4h-1zm3-2.999V15h.999v1.001h-1zM11 15v-1h2v1h-2zM18 20v-2h.999v2h-1zm-1-2v-1h1v1h-1zm0-1.999V15h1v1.001h-1zM15 20v-6h1v2.001h1v1h-1V20h-1zm3-5v-1h.999v1h-1z"/>` +
    '</svg>'
    );

    const buff = new Buffer(image);
    const base64data = buff.toString('base64');

    return <img src={`data:image/svg+xml;base64,${base64data}`} alt="" width="500" height="500" />
  }

  const GetPartsInOrder = (color) => {

    // Variants:
    // #1 - 1 fuck 
    // #2 - 2 fucks
    // #3 - 3 fucks
    // #4 - fuuuuuuck
    // #5 - diagn fuck

    // 256: Loop through all colors for single fucks
    // 128: Loop through odd # colors for 2 fucks
    // 118: Loop through every 3rd color for 3 fucks
    // 51: Every 5th color for fuuuuck
    // 25: Every 10th color for diag
    // = 578

    // 256: #1
    // 128: #2 (odds)
    // 128: #3 (evens)
    // 64: #4
    // 64: dial
    // 512: different colors for text + bg
    
    // 256: Randomly pick bg + text/frame colors (lots of combos available)
    // 256: Monochrome of each color
    // 64: 2 fucks random colors
    // 64: 2 fucks monochrome (every 4)
    // 32: 3 fucks random colors
    // 32: 3 fucks monochrome (every 8)
    // 32: fuuuucks monochrome (every 8)
    // 32: fuuuucks random colors
    // = 768

    // 512: Randomly pick bg + text/frame colors (lots of combos available)
    // 256: Monochrome of each color
    // 128: 2 fucks random colors
    // 128: 2 fucks monochrome (every 4)
    // 64: 3 fucks random colors
    // 64: 3 fucks monochrome (every 8)
    // 64: fuuuucks monochrome (every 8)
    // 64: fuuuucks random colors
    // 16: Reversed fuck (random colors)
    // 16: Pixel rainbow background
    // = 1280

    // #TODO: Look at foreground and background colors here: https://robotmoon.com/256-colors/#foreground-colors
    // That might solve legibility issues. But, potentially cuts down on # of combos. 
    // Also the first 16 hexes in that json list are listed twice.  

    console.log(color);
    const monoColor = colors[color.color];
    let textColor;
    if (color.color == 0) {
      textColor = '#FFFFFF';
    }

    const image = ('<svg id="butt" preserveAspectRatio="xMinYMin meet" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs>' + 
      `<style>.bg{fill:${monoColor}}.txt{fill:${textColor ? textColor : monoColor};}.fr{fill: transparent;stroke:${monoColor}}.txt,.fr{filter: brightness(0.8); mix-blend-mode: multiply;}}#butt{shape-rendering:crispedges;}</style></defs>`+ 
      '<path class="bg" d="M0 0h24v24H0z"/>' +
      `<path class="fr" d="M.5.5h23v23H.5z"/>` +
      `<path class="txt" d="M2 22v-6h3.999v1h-3v1.001h3v1h-3V22H2zM8 22v-1h2v1H8zm-1-1v-5h1v5H7zm3 0v-5h.999v5h-1zM13 22v-1h2v1h-2zm2-1v-1h.999v1h-1zm-3 0v-4h1v4h-1zm3-2.999V17h.999v1.001h-1zM13 17v-1h2v1h-2zM20 22v-2h.999v2h-1zm-1-2v-1h1v1h-1zm0-1.999V17h1v1.001h-1zM17 22v-6h1v2.001h1v1h-1V22h-1zm3-5v-1h.999v1h-1z"/>` +
    '</svg>'
    );

    const buff = new Buffer(image);
    const base64data = buff.toString('base64');

    return <img src={`data:image/svg+xml;base64,${base64data}`} alt="" width="500" height="500" />
  }

  const looper = [];
  for (var i = 0; i < 333; i++) {
      looper.push(i);
      // console.log(looper);
  }

  return (
    <div className="mx-auto px-4">
      <Head>
        <title>Tester Minting dApp Starter</title>
        <meta name="description" content="Mint an NFT, or a number of NFTs, from the client-side." />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <Wallet />
      <main className="space-y-8">
        <h1 className="text-4xl font-semibold mb-8">
          NFT Minting dApp Starter
        </h1>
        <ul style={{display: 'flex', flexWrap: 'wrap'}}>
          {/* { looper.map( (item, i) => {
            return (
              <li key={i} style={{maxWidth: '20%', padding: '1%'}}><GetParts /></li>
            )
          })} */}
          { colors.map( (item, i) => {
            console.log(i);
            return (
              <li key={i} id={i} style={{maxWidth: '20%', padding: '1%'}}>
                {/* <GetPartsInOrder color={i} /> */}
                <GetParts color={i} />
                </li>
            )
          })}
        </ul>
        {/* <GetParts /> */}
        <div className="space-y-8">
            <div className="bg-gray-100 p-4 lg:p-8">
              <div>
                <h2 className="text-2xl font-semibold mb-2">On Chain Butts</h2>
              </div>
            </div>
        </div>
      </main>
    </div>
  )
}
