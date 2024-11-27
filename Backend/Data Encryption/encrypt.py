import pandas as pd
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import ipfshttpclient
import os
import io
# Load dataset
data = pd.read_csv('data.csv')
data_bytes = data.to_csv(index=False).encode()  # Convert CSV data to bytes for encryption

# Generate AES encryption key
key = os.urandom(32)  # AES-256 requires a 32-byte key

# Encrypt dataset
iv = os.urandom(12)  # 12-byte nonce for GCM mode
cipher = Cipher(algorithms.AES(key), modes.GCM(iv), backend=default_backend())
encryptor = cipher.encryptor()
encrypted_data = encryptor.update(data_bytes) + encryptor.finalize()
tag = encryptor.tag  # Authentication tag for GCM

# Save as binary file
with open("encrypted_dataset.bin", "wb") as f:
    f.write(encrypted_data)