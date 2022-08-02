{
	schemaVersion: 2,
	mediaType: "application/vnd.oci.image.index.v1+json",
	manifests: [{
		mediaType: "application/vnd.oci.image.manifest.v1+json",
		digest: "sha256:\($manifest_digest)",
		size: $manifest_size,
		annotations: {
			"org.opencontainers.image.ref.name": $name,
		}}
	]
}
