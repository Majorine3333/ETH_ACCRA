import { BigInt, Address } from "@graphprotocol/graph-ts";
import { Transfer, MetadataUpdate } from "../generated/NFTTracking/NFTTracking";
import { Account, NFT, Transfer as TransferEntity, Metadata } from "../generated/schema";

export function handleTransfer(event: Transfer): void {
  let fromAddress = event.params.from.toHex();
  let toAddress = event.params.to.toHex();
  let tokenId = event.params.tokenId.toString();

  // Create or update the 'from' Account entity
  let fromAccount = Account.load(fromAddress);
  if (fromAccount === null) {
    fromAccount = new Account(fromAddress);
    fromAccount.save();
  }

  // Create or update the 'to' Account entity
  let toAccount = Account.load(toAddress);
  if (toAccount === null) {
    toAccount = new Account(toAddress);
    toAccount.save();
  }

  // Create or update the NFT entity
  let nft = NFT.load(tokenId);
  if (nft === null) {
    nft = new NFT(tokenId);
    nft.owner = toAddress;
    nft.metadataURI = "";
    nft.save();
  } else {
    nft.owner = toAddress;
    nft.save();
  }

  // Create a Transfer entity
  let transfer = new TransferEntity(event.transaction.hash.toHex() + "-" + event.logIndex.toString());
  transfer.from = fromAddress;
  transfer.to = toAddress;
  transfer.tokenId = tokenId;
  transfer.save();
}

export function handleMetadataUpdate(event: MetadataUpdate): void {
  let tokenId = event.params.tokenId.toString();
  let metadataURI = event.params.metadataURI;

  // Load the NFT entity
  let nft = NFT.load(tokenId);
  if (nft === null) {
    nft = new NFT(tokenId);
    nft.owner = "";  // Set default or empty owner if not available
  }
  nft.metadataURI = metadataURI;
  nft.save();

  // Create a Metadata entity
  let metadata = new Metadata(tokenId);
  metadata.metadataURI = metadataURI;
  metadata.save();
}
