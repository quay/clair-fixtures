{
	architecture: "amd64",
	os: "linux",
	rootfs: {
		type: "layers",
		diff_ids: ["sha256:\($layer_digest)"]
	}
}
