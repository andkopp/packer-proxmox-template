proxmox_api_url = "https://pve1.myhomelab:8006/api2/json"  # Hostname or IP address
proxmox_api_token_id = "packer@pam!packer"  # API Token ID
proxmox_api_token_secret = "your_secret"
proxmox_node = "pve1"

proxmox_iso_storage_pool = "local"   # "truenas-neo"
proxmox_iso_file = "debian-12.4.0-amd64-netinst.iso"
proxmox_vm_storage_pool = "local"
proxmox_vm_storage_pool_type = "zfspool"
proxmox_vm_id = "910"