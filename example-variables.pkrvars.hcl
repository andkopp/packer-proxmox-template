proxmox_api_url = "https://pve1.myhomelab:8006/api2/json"  # Hostname or IP address
proxmox_api_token_id = "packer@pam!packer"  # API Token ID
proxmox_api_token_secret = "your_secret"
proxmox_node = "pve1"

proxmox_iso_storage_pool = "local"   # "truenas-neo"
proxmox_iso_file = "debian-13.3.0-amd64-netinst.iso"
proxmox_iso_checksum = "sha512:1ada40e4c938528dd8e6b9c88c19b978a0f8e2a6757b9cf634987012d37ec98503ebf3e05acbae9be4c0ec00b52e8852106de1bda93a2399d125facea45400f8"
proxmox_vm_storage_pool = "local"
proxmox_vm_id = "920"