const { create } = require("ipfs-http-client");

async function uploadToIPFS(data) {
    const ipfs = create({ host: 'ipfs.infura.io', port: '5001', protocol: 'https' });
    const added = await ipfs.add(data);
    console.log("IPFS CID:", added.path);
    return added.path;
}

// Example usage
uploadToIPFS("Sample data for IPFS").then((cid) => {
    console.log("CID:", cid);
});