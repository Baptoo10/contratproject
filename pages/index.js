"use client"; // client component

//import list
import { useState, useEffect } from 'react';
import {ethers} from "ethers";
import ipfsClient, {create} from 'ipfs-http-client';
import { CID } from 'ipfs-http-client'


//Tricks contract deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
import TricksABI from '../artifacts/contracts/tricks.sol/Tricks.json' //ABI
const TricksAddress = '0x2e58099F3e891Bf23f0F44F278BE820c3da76582' //ADDRESS


export default function Home() {

  const [tokenId, setTokenId] = useState('');
  const [account, setAccount] = useState('');
  const [contract, setContract] = useState(null);

  useEffect(() => {
    connectWallet();
  }, []);

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(TricksAddress, TricksABI.abi, signer);
        setAccount(await signer.getAddress());
        setContract(contract);
      } catch (error) {
        console.error(error);
      }
    } else {
      console.error('Web3 provider not found');
    }
  };
/*
  const NFTMint = async () => {
    try {
      await contract.NFTMintById(account, 1);
      console.log('NFT minted successfully!');
    } catch (error) {
      console.error(error);
    }
  };
*/

  const projectId = '2QYwJIMXSqXRkRKz1zZcjGmDcJ8';
  const projectSecret = '07c4b67008715f385e6a3d9a0547954f';
  const auth = `Basic ${Buffer.from(`${projectId}:${projectSecret}`).toString('base64')}`;

/*
  const NFTMintById = async () => {
    try {

      console.log("ouiIPFS");
      const ipfs = create({
        host: 'ipfs.infura.io',
        port: 5001,
        protocol: 'https',
        headers: {
          authorization: auth,
        },
      });


      const cid = 'bafybeidhodmcmmlb6ozh53wfhsr5ovoeazniwfdtuu5427gxhk7euikaou'; // CID de l'image IPFS

      const metadata = {
        name: 'NFT_b',
        description: 'description_',
        image: `ipfs://${cid}`, //referencer le CID IPFS
      };

      const metadataCID = await ipfs.add(JSON.stringify(metadata)); // Ajoutez les metadata sur IPFS et obtenez le CID

      await contract.NFTMintById(account, metadataCID.path); // Mint le NFT en utilisant le CID IPFS comme tokenId
      console.log('NFT minted successfully!');
    } catch (error) {
      console.error(error);
    }
  };
*/
  const setContractURI = async (uri) => {
    try {
      await contract.setContractURI(uri);
      console.log('Contract URI updated successfully!');
    } catch (error) {
      console.error(error);
    }
  };

  async function NFTMint() {
    //await requestAccount();
    if (typeof window.ethereum !== 'undefined') {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(TricksAddress, TricksABI.abi, signer);
        console.log("oui");
        // Appeler la fonction Solidity pour ajouter une nouvelle proposition
        let override ={
          from: account
        }
        const transaction = await contract.NFTMintById(account, 2, override);
        await transaction.wait();

      } catch (error) {
        console.error("Erreur lors du mint : ", error);
      }
    } else {
      console.error("Web3 non disponible. Veuillez installer MetaMask pour interagir avec cette fonction.");
    }
  }

  async function NFTBurn() {
    //await requestAccount();
    if (typeof window.ethereum !== 'undefined') {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(TricksAddress, TricksABI.abi, signer);
        console.log("oui");
        // Appeler la fonction Solidity pour ajouter une nouvelle proposition
        await contract._burn(2);

      } catch (error) {
        console.error("Erreur lors du mint : ", error);
      }
    } else {
      console.error("Web3 non disponible. Veuillez installer MetaMask pour interagir avec cette fonction.");
    }
  }
/*
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
*/
/*
  useEffect(() => {
    fetchData();
  }, []);*/

  return (
      <main>

        <div>
          <p>COUCOU</p>
          <button onClick={NFTMint}>Mint NFT</button>
          <button onClick={NFTBurn}>NFTBurn NFT</button>
          <button onClick={() => setContractURI("https://ipfs.io/ipfs/QmYGgEFqTRkWvNZ6u7gfk9HDdh55bQAbYVyc16TF1zX658/")}>Set Contract URI</button>
        </div>

      </main>
  )
}