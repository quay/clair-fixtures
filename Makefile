all: size shape

.PHONY: size shape

linkblob = install -d $(2)/blobs/sha256 &&\
		   ln $(1) $(2)/blobs/sha256/$$(sha256sum $(1) | awk '{print $$1}') ||:
shasum = $$(sha256sum $(1) | awk '{print $$1}')
size = $$(stat --format %s $(1))
layerfile = bomb.$(if $(findstring size,$(1)),gz,zip)
jqfile = $(basename $(notdir $(1))).jq

size: bad-size/oci-layout bad-size/index.json

shape: bad-shape/oci-layout bad-shape/index.json

bomb.gz:
	dd if=/dev/zero bs=4096 count=$$((25*1024*1024)) |\
		gzip -9 >$@
	$(call linkblob,$@,bad-size)

bomb.zip:
	zip $@ Makefile
	$(call linkblob,$@,bad-shape)

.SECONDEXPANSION:
bad-%/config.json: $$(call jqfile,$$(@)) $$(call layerfile,$$(@D))
	@mkdir -p $(@D)
	jq --null-input\
		--compact-output\
		--arg layer_digest $(call shasum,$(filter bomb.%,$^))\
		--from-file $(filter %.jq,$^)\
		>$@
	$(call linkblob,$@,$(@D))

bad-%/manifest.json: $$(call jqfile,$$(@)) bad-%/config.json $$(call layerfile,$$(@D))
	$(info $^)
	@mkdir -p $(@D)
	jq --null-input\
		--compact-output\
		--argjson config_size $(call size,$(filter %.json,$^))\
		--arg config_digest $(call shasum,$(filter %.json,$^))\
		--argjson layer_size $(call size,$(filter bomb.%,$^))\
		--arg layer_digest $(call shasum,$(filter bomb.%,$^))\
		--from-file $(filter %.jq,$^)\
		>$@
	$(call linkblob,$@,$(@D))
	$(call linkblob,$(filter bomb.%,$^),$(@D))

bad-%/index.json: $$(call jqfile,$$(@)) bad-%/manifest.json
	@mkdir -p $(@D)
	jq --null-input\
		--compact-output\
		--argjson manifest_size $(call size,$(filter %.json,$^))\
		--arg manifest_digest $(call shasum,$(filter %.json,$^))\
		--arg name $(@D)\
		--from-file $(filter %.jq,$^)\
		>$@

bad-%/oci-layout:
	@mkdir -p $(@D)
	jq --null-input --compact-output\
		'{imageLayoutVersion: "1.0.0"}'\
		>$@
