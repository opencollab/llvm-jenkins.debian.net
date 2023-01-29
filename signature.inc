To retrieve the archive signature:
  <p class="www_code">
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -<br />
# or
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
# Fingerprint:  6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421
</p><br />

