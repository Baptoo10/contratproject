"use client"; // client component

//import list
import { useState, useEffect } from 'react';
import {ethers} from "ethers";



//Tricks contract deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
import TricksABI from '../artifacts/contracts/tricks.sol/tricks.json'
const TricksAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512' //ADDRESS

export default function Home() {

  async function requestAccount() {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
  }

  async function NFTMint() {
    await requestAccount();
    if (typeof window.ethereum !== 'undefined') {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(TricksAddress, TricksABI.abi, signer);

        // Appeler la fonction Solidity pour ajouter une nouvelle proposition
        const transaction = await contract.NFTMint();

      } catch (error) {
        console.error("Erreur lors du mint : ", error);
      }
    } else {
      console.error("Web3 non disponible. Veuillez installer MetaMask pour interagir avec cette fonction.");
    }

  }


  async function fetchData() {
    if(typeof window.ethereum !== 'undefined') {
      // Se connecter au fournisseur Web3 (MetaMask)
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      // Creer une instance du contrat Tricks
      const contract = new ethers.Contract(TricksAddress, TricksABI.abi, provider);

      try {
        // Appel de la fonction du contrat pour recuperer l'URI d'un token en question
        const uri = await contract.tokenURI(tokenId);
        console.log('URI du token:', uri);

        // Requete HTTP pour obtenir les metadata grace a l'URI
        const response = await fetch(uri);
        const metadata = await response.json();
        console.log('Metadata du token:', metadata);
      }
      catch(err) {
        console.log(err.message);
      }
    }
  }


  useEffect(() => {
    fetchData();
  }, []);

  return (
      <main>

        <div>
          <p>COUCOU</p>
          <button onClick={NFTMint}>Mint NFT</button>
        </div>

      </main>
  )
}