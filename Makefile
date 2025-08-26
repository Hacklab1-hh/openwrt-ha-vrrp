# Top-level helper Makefile (optional) for openwrt-ha-vrrp v0.5.2
# Prefer the OpenWrt buildroot Makefiles inside ha-vrrp/ and luci-app-ha-vrrp/.
# This file offers convenience targets for bundling and sandbox testing.

.PHONY: help ipks bundle clean

help:
	@echo "Targets:"
	@echo "  ipks    - build .ipk packages using OpenWrt buildroot (requires BUILDROOT=/path)"
	@echo "  bundle  - create a tar.gz with the current tree"
	@echo "  clean   - remove temporary artifacts"

ipks:
	@if [ -z "$$BUILDROOT" ]; then echo "Set BUILDROOT=/path/to/openwrt-sdk"; exit 1; fi
	cp -a ha-vrrp $(BUILDROOT)/package/
	cp -a luci-app-ha-vrrp $(BUILDROOT)/package/
	$(MAKE) -C $(BUILDROOT) package/ha-vrrp/compile V=s
	$(MAKE) -C $(BUILDROOT) package/luci-app-ha-vrrp/compile V=s
	@echo "Look under $$BUILDROOT/bin/packages/... for the IPKs"

bundle:
	tar -C .. -czf ../openwrt-ha-vrrp-0.5.2.bundle.tar.gz $(notdir $(CURDIR))

clean:
	rm -f ../openwrt-ha-vrrp-0.5.2.bundle.tar.gz
