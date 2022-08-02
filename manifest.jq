{
	schemaVersion: 2,
	mediaType: "application/vnd.oci.image.manifest.v1+json",
	config: {
		size: $config_size,
		mediaType: "application/vnd.oci.image.config.v1+json",
		digest: "sha256:\($config_digest)",
	},
	layers: [{
		size: $layer_size,
		mediaType: "application/vnd.oci.image.layer.v1.tar+gzip",
		digest: "sha256:\($layer_digest)",
	}]
}
