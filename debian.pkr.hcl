packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "proxmox_node" {
    type = string
}

variable "proxmox_vm_id" {
    type = string
}

variable "proxmox_iso_storage_pool" {
    type = string
    default = "local"
}

variable "proxmox_iso_file" {
    type = string
}

variable "proxmox_vm_storage_pool" {
    type = string
}

variable "proxmox_vm_storage_pool_type" {
    type = string
}

variable "cores" {
  type    = string
  default = "2"
}

variable "disk_format" {
  type    = string
  default = "raw"
}

variable "disk_size" {
  type    = string
  default = "10G"
}

variable "cpu_type" {
  type    = string
  default = "kvm64"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "network_vlan" {
  type    = string
  default = ""
}

variable "machine_type" {
  type    = string
  default = ""
}

# Resource Definition for the VM Template
# Documentation: https://developer.hashicorp.com/packer/plugins/builders/proxmox/iso
source "proxmox-iso" "debian" {

  # Proxmox Connection Settings
  proxmox_url = var.proxmox_api_url
  username = var.proxmox_api_token_id
  token = var.proxmox_api_token_secret
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true

  # VM General Settings
  node = var.proxmox_node
  vm_id = var.proxmox_vm_id
  vm_name = trimsuffix(basename(var.proxmox_iso_file), ".iso")
  template_description = "Built from ${basename(var.proxmox_iso_file)} on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"
  tags = "debian"

  # VM OS Settings
  # (Option 1) Local ISO File
  iso_file = "${var.proxmox_iso_storage_pool}:iso/${var.proxmox_iso_file}"
  # (Option 2) Download ISO
  # iso_url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso"
  # iso_checksum = "64d727dd5785ae5fcfd3ae8ffbede5f40cca96f1580aaa2820e8b99dae989d94"
  iso_storage_pool = "${var.proxmox_iso_storage_pool}"
  http_directory = "./"
  boot_wait      = "10s"
  boot_command   = ["<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"]
  unmount_iso    = true

  # Packer Communication
  #http_directory = "http" 
  # (Optional) Bind IP Address and Port
  # http_bind_address = "0.0.0.0"
  #http_port_min = 8802
  #http_port_max = 8802

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-single"
  disks {
    type              = "scsi"
    disk_size         = var.disk_size
    format            = var.disk_format
    storage_pool      = var.proxmox_vm_storage_pool
    #storage_pool_type = var.proxmox_vm_storage_pool_type   #deprecated

    # Create one I/O thread per storage controller, 
    # rather than a single thread for all I/O. 
    # This can increase performance when multiple disks are used.
    # Requires virtio-scsi-single controller and a scsi or virtio disk.
    io_thread         = true
  }

  # VM CPU and Memory Settings
  cpu_type = var.cpu_type
  sockets  = "1"
  cores    = var.cores
  memory   = var.memory
  machine  = var.machine_type
  os       = "l26"

  # VM Network Settings
  network_adapters {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
    vlan_tag = var.network_vlan
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = var.proxmox_vm_storage_pool

  # Note: this password is needed by packer to run the file provisioner, but
  # once that is done - the password will be set to random one by cloud init.
  ssh_password = "packer"
  ssh_username = "root"
}

build {
  sources = ["source.proxmox-iso.debian"]

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "cloud.cfg"
  }

  # Prevent using same machine id for all cloned VMs.
  # See https://wiki.debian.org/MachineId
  # See https://github.com/romantomjak/packer-proxmox-template/issues/1#issuecomment-1276168233
  provisioner "shell" {
    inline = [
      "rm /etc/ssh/ssh_host_*",
      "rm /etc/machine-id /var/lib/dbus/machine-id",
      "touch /etc/machine-id && ln -s /etc/machine-id /var/lib/dbus/machine-id",
    ]
  }
}