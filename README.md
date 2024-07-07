# SLSA Example

Example using the [SLSA3+ GitHub Workflow for Go](https://github.com/slsa-framework/slsa-github-generator/blob/main/internal/builders/go/README.md) and the [SLSA Verifier](https://github.com/slsa-framework/slsa-verifier).

### Create a new release
Pushing a new tag will trigger [a build](https://github.com/stiankri/slsa-example/actions) which creates [a new release](https://github.com/stiankri/slsa-example/release).

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
