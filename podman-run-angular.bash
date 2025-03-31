podman build --no-cache --rm -f Containerfile -t angular:demo .
podman run --interactive --tty -p 4200:4200 angular:demo
echo "browse http://localhost:4200/?username=test"
