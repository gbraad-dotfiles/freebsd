packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "freebsd" {
  accelerator       = "kvm"
  disk_image        = true
  iso_url           = "freebsd.img"
  iso_checksum      = "none"
  output_directory  = "output-freebsd"
  format            = "qcow2"
  memory            = 2048
  disk_size         = "20480"
  net_device        = "virtio-net"

  ssh_username      = "root"
  ssh_password      = "password"

  disk_interface     = "virtio"

  cd_files = [
    "cloud-init/user-data",
    "cloud-init/meta-data"
  ]
  cd_label = "CIDATA"

  shutdown_command  = "shutdown -p now"
  shutdown_timeout  = "1m"

  headless = true
  qemuargs = [
    ["-machine", "type=q35,accel=kvm"],
    ["-boot", "c"],
    ["-display", "none"],
    ["-serial", "file:serial.log"]
  ]
}

build {
  sources = ["source.qemu.freebsd"]

  provisioner "shell" {
    inline = [
      "pkg update",
      "pkg install -y git stow zsh",
      "echo 'FreeBSD 15.1-RELEASE Automated Build' > /etc/motd"
    ]
  }
}
