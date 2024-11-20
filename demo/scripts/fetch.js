const { PinataSDK }  = require('pinata-web3');
const pinata = new PinataSDK({
  pinataJwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJmNGRhZDRiMC0xNGZhLTRlOWUtYmNhNy1lN2NlNjNiMjAwMzMiLCJlbWFpbCI6ImF2bWVsa290ZUB1Y3NkLmVkdSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiI0MGFhMzIyNzA5NTUyODlhMjAyZSIsInNjb3BlZEtleVNlY3JldCI6ImM3NTlmOTY1YWIxMTNhMWM0OWIzYjIxNzlmMmVjNmE1MjI3OWQ1ZDA1NTY2Yjc5MmQ2ZGM5ZGMyODgwYTQ4ZGQiLCJleHAiOjE3NjMwNzI3NDl9.Ebwp4Dy8HoMg0_NcR_LUHPIoJo38qOt6KIvH3Qphvwk",
  pinataGateway: "aqua-general-grasshopper-134.mypinata.cloud",
});
async function fetch(cid) {
    try {
      const data = await pinata.gateways.get(cid);
      console.log(data)
    } catch (error) {
      console.log(error);
    }
  }
function updateCID(newCID) {
    cid = newCID;
}
fetch('bafybeiacakd42x5ex6kuwvznhhd3tvf3bxuthqt34qxjl24sojv4ehishm');