To retrieve the archive signature:
  <p class="www_code">
sudo install -d -m 0755 /etc/apt/keyrings<br />
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/keyrings/apt_llvm_org.asc<br />
# Fingerprint:  6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421
</p><br />

