import { NextResponse, type NextRequest } from "next/server";
import { pinata } from "@/utils/config"; // Pinata configuration
import { getContract } from "@/utils/contract"; // Contract helper
import { parseEther } from "ethers";

export async function POST(request: NextRequest) {
  try {
    console.log("Starting POST request at /api/files");

    // Parse form data from the request
    const formData = await request.formData();
    const file = formData.get("file") as unknown as File;
    const price = formData.get("price") as string;
    const description = formData.get("description") as string;

    console.log("Parsed FormData:", { file, price, description });

    if (!file || !price || !description) {
      console.error("Missing required fields:", { file, price, description });
      return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
    }

    // Step 1: Upload file to Pinata
    console.log("Uploading file to Pinata...");
    const fileUploadResponse = await pinata.upload.file(file);
    console.log("Pinata upload response:", fileUploadResponse);

    const cid = fileUploadResponse.IpfsHash; // Extract the CID
    console.log("File uploaded to Pinata with CID:", cid);

    // Step 2: Interact with the smart contract
    console.log("Getting smart contract instance...");
    const contract = await getContract();
    console.log("Smart contract instance retrieved.");

    console.log("Calling listData on the smart contract...");
    const tx = await contract.listData(cid, parseEther(price), description);
    console.log("Transaction sent. Waiting for confirmation...");
    await tx.wait(); // Wait for confirmation
    console.log("Transaction confirmed.");

    // Simplified response to indicate success
    return NextResponse.json({ message: "Data listed successfully." });
  } catch (error) {
    console.error("Error in /api/files route:", error);
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
  }
}