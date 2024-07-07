COMMIT_DATE="$(git log --date=iso8601-strict -1 --pretty=%ct)"
COMMIT="$(git log -1 --pretty=%H)"
VERSION="$(git describe --tags --always --dirty | cut -c2-)"
TREE_STATE="$(if git diff --quiet; then echo "clean"; else echo "dirty"; fi)"

echo \"$VERSION\"
echo \"$COMMIT\"
echo \"$COMMIT_DATE\"
echo \"$TREE_STATE\"

GOOS=linux GOARCH=amd64 GO111MODULE=on CGO_ENABLED=0 go build -ldflags="-X 'main.Version=$VERSION' -X 'main.Commit=$COMMIT' -X 'main.CommitDate=$COMMIT_DATE' -X 'main.TreeState=$TREE_STATE'" -x -trimpath -tags=netgo -o binary-linux-amd64 -mod=vendor
