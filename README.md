# SLSA Example

Example using the [SLSA3+ GitHub Workflow for Go](https://github.com/slsa-framework/slsa-github-generator/blob/main/internal/builders/go/README.md) and the [SLSA Verifier](https://github.com/slsa-framework/slsa-verifier).

### Create a new release
Pushing a new tag will trigger [a build](https://github.com/stiankri/slsa-example/actions) which creates [a new release](https://github.com/stiankri/slsa-example/releases).

### Verify release `v0.0.2`
Install `slsa-verifier`
```sh
go install github.com/slsa-framework/slsa-verifier/v2/cli/slsa-verifier@v2.5.1
```

Download artifact and provenance data
```sh
wget https://github.com/stiankri/slsa-example/releases/download/v0.0.2/binary-linux-amd64
wget https://github.com/stiankri/slsa-example/releases/download/v0.0.2/binary-linux-amd64.intoto.jsonl
```

Verify
```sh
slsa-verifier verify-artifact binary-linux-amd64 \
--provenance-path binary-linux-amd64.intoto.jsonl \
--source-uri github.com/stiankri/slsa-example \
--source-tag v0.0.2
```

Rekor entry: [109479596](https://search.sigstore.dev/?logIndex=109479596) (based on the [OIDC token of the GitHub Workflow](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token)).

### Reproduce artifact bits for release `v0.0.2`
Get the hash of the released version
```sh
sha256sum binary-linux-amd64
```
The expected SHA256 is `c78bb6af4d0fc89c11af2376c5ad2255807a7fcc2b0f9d4683f62ef779fa353b`.

Use the same version of Go as the build (`go1.22.4` for tag `v0.0.2`) then
```sh
git clone https://github.com/stiankri/slsa-example.git
cd slsa-exmaple
git checkout v0.0.2
./reproducible-build.sh
sha256sum binary-linux-amd64
```

### Countersign
To achieve ["verified reproducible builds"](https://slsa.dev/spec/v1.0/faq), the build should be verified in a separate build process.

One way could be that the maintainers verify the artifact bits and release metadata locally, then countersign the release and add it to Rekor. [SSH is one of several supported formats](https://docs.sigstore.dev/logging/sign-upload/).
```sh
cd ..
ssh-keygen -C test -t ed25519 -f id_ed25519 # preferably a long-lived key used by maintainer/project
ssh-keygen -Y sign -n file -f id_ed25519 binary-linux-amd64.intoto.jsonl
```

Install `rekor-cli`
```sh
go install -v github.com/sigstore/rekor/cmd/rekor-cli@latest
```

Upload to Rekor ([example entry](https://search.sigstore.dev/?uuid=24296fb24b8ad77a0938e917726893ce9bff2da2f55275f5fd80ffa8b5603aa102cb9ea6d0208824))
```sh
rekor-cli upload --artifact binary-linux-amd64.intoto.jsonl --signature binary-linux-amd64.intoto.jsonl.sig --pki-format=ssh --public-key=id_ed25519.pub
```

Verify inclusion in log (using the example public key)
```sh
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBuSE7w1N3OUUpl6N6kpRO+WKkpJb0x1VRCIS3u8NMTj > id_ed25519.pub
rekor-cli verify --signature binary-linux-amd64.intoto.jsonl.sig --artifact binary-linux-amd64.intoto.jsonl --public-key id_ed25519.pub --pki-format ssh
```

Verify signature
```sh
cat binary-linux-amd64.intoto.jsonl | ssh-keygen -Y check-novalidate -n file -f id_ed25519.pub  -s binary-linux-amd64.intoto.jsonl.sig
```
