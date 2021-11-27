# hermit-guest-kernel

This is the kernel used by [hermit-ci](https://github.com/thepwagner/hermit), based on the [debian/stable sources](https://tracker.debian.org/pkg/linux-signed-amd64).

It is what guest virtual machines boot, so should have all the features you want from builders. It must set `CONFIG_VIRTIO_VSOCKETS=y`.

This configuration started with [firecracker's default kernel configuration](https://github.com/firecracker-microvm/firecracker/blob/8be922692b03f1240a3ed2ae4b144b086963416d/resources/microvm-kernel-x86_64.config) and accepted defaults.
