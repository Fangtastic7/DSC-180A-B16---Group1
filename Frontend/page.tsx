"use client";

import { useState } from "react";

export default function Home() {
  const [file, setFile] = useState<File | null>(null);
  const [price, setPrice] = useState("");
  const [description, setDescription] = useState("");
  const [sellerAddress, setSellerAddress] = useState("");
  const [uploading, setUploading] = useState(false);
  const [dataItems, setDataItems] = useState<any[]>([]);

  const uploadFile = async () => {
    try {
      if (!file || !price || !description || !sellerAddress) {
        alert("Please fill in all fields");
        return;
      }

      setUploading(true);

      const data = new FormData();
      data.set("file", file);
      data.set("price", price);
      data.set("description", description);
      data.set("sellerAddress", sellerAddress);

      const response = await fetch("/api/files", {
        method: "POST",
        body: data,
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error("Backend Error:", errorText);
        throw new Error(`File upload failed with status ${response.status}`);
      }

      const uploadedData = await response.json();
      alert("File uploaded successfully!");
      setDataItems([...dataItems, uploadedData]);
      setUploading(false);
    } catch (error) {
      console.error("Error in uploadFile:", error);
      setUploading(false);
      alert("Error uploading file");
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFile(e.target?.files?.[0] || null);
  };

  return (
    <main className="min-h-screen flex flex-col justify-center items-center bg-gray-900 text-white p-6">
      <h1 className="text-3xl font-bold mb-8">Blockchain Data Marketplace</h1>
      <div className="w-full flex justify-center items-start gap-8">
        {/* Column 1: Upload Data */}
        <div className="w-1/3 bg-gray-800 p-6 rounded-lg shadow-lg">
          <h2 className="text-xl font-bold mb-4">Upload Data For Sale</h2>
          <label className="block mb-2 text-lg font-semibold text-gray-400">
            File:
          </label>
          <input
            type="file"
            onChange={handleFileChange}
            className="block w-full text-sm text-gray-500 border border-gray-700 rounded-lg bg-gray-800 file:bg-blue-500 file:border-none file:text-white file:py-2 file:px-4 file:cursor-pointer hover:file:bg-blue-600"
          />
          <label className="block mt-4 mb-2 text-lg font-semibold text-gray-400">
            Price (in MATIC):
          </label>
          <input
            type="text"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            className="block w-full text-sm text-gray-500 border border-gray-700 rounded-lg bg-gray-800 p-2"
          />
          <label className="block mt-4 mb-2 text-lg font-semibold text-gray-400">
            Description:
          </label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="block w-full text-sm text-gray-500 border border-gray-700 rounded-lg bg-gray-800 p-2"
          />
          <label className="block mt-4 mb-2 text-lg font-semibold text-gray-400">
            Your Public Address:
          </label>
          <input
            type="text"
            value={sellerAddress}
            onChange={(e) => setSellerAddress(e.target.value)}
            placeholder="e.g., 0x123...abc"
            className="block w-full text-sm text-gray-500 border border-gray-700 rounded-lg bg-gray-800 p-2"
          />
          <button
            onClick={uploadFile}
            disabled={uploading}
            className="mt-6 w-full bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {uploading ? "Uploading..." : "Upload"}
          </button>
        </div>

        {/* Column 2: Purchase Data */}
        <div className="w-1/3 bg-gray-800 p-6 rounded-lg shadow-lg">
          <h2 className="text-xl font-bold mb-4">Purchase Data</h2>
          <p className="text-gray-400 mb-4">
            Browse data listings and purchase them using MATIC.
          </p>
          <p className="text-gray-400">Coming soon...</p>
        </div>

        {/* Column 3: Browse Listed Data */}
        <div className="w-1/3 bg-gray-800 p-6 rounded-lg shadow-lg">
          <h2 className="text-xl font-bold mb-4">Browse Listed Data</h2>
          <div
            className="grid gap-4 overflow-y-auto max-h-[400px] pr-2"
            style={{
              scrollbarWidth: "thin",
              scrollbarColor: "#4A5568 transparent", // Styled scrollbars for better UX
            }}
          >
            {dataItems.map((item, index) => (
              <div
                key={index}
                className="bg-gray-700 p-4 rounded-lg shadow-md flex flex-col"
              >
                <p>ID: {item.id}</p>
                <p>Seller: {item.seller}</p>
                <p>Price: {item.price} MATIC</p>
                <p>Description: {item.description}</p>
                <p>Sales Count: {item.salesCount}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </main>
  );
}