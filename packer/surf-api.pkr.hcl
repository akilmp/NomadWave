variable "artifact_dir" {
  type    = string
  default = "artifacts"
}

variable "artifact_bucket" {
  type    = string
  default = ""
}

source "null" "local" {
  communicator = "none"
}

build {
  name    = "surf-api"
  sources = ["source.null.local"]

  provisioner "shell-local" {
    inline = [
      "set -euo pipefail",
      "docker buildx create --use --name surf-api-builder >/dev/null 2>&1 || docker buildx use surf-api-builder",
      "mkdir -p ${var.artifact_dir}",
      "docker buildx build ../services/surf-api --platform linux/amd64,linux/arm64 --tag surf-api:latest --output type=oci,dest=${var.artifact_dir}/surf-api.tar",
      "docker run --rm --privileged -v $(pwd)/${var.artifact_dir}:/out alpine:3.20 sh -c 'apk add --no-cache linux-lts util-linux e2fsprogs && cp /boot/vmlinuz-lts /out/vmlinux && dd if=/dev/zero of=/out/rootfs.ext4 bs=1M count=64 && mkfs.ext4 /out/rootfs.ext4 && mkdir /mnt/root && mount /out/rootfs.ext4 /mnt/root && apk add --no-cache --root /mnt/root alpine-base && umount /mnt/root'",
      "%{if var.artifact_bucket != ""}aws s3 sync ${var.artifact_dir} s3://${var.artifact_bucket}/%{endif}"
    ]
  }
}
