resource "proxmox_vm_qemu" "multi-purpose" {
  name   = "multi-purpose"
  vmid = 220
  target_node = "pve"
  clone  = "ubuntu-2404-multi-purpose-template"
  full_clone = true
  os_type = "cloud-init"
  scsihw = "virtio-scsi-single"
  onboot = true

  cpu {
    cores  = 2
    sockets = 1
  }

  memory = 4096

  disk {
    size    = "32G"
    type    = "disk"
    slot    = "scsi0"
    storage = "local-lvm"       # Your storage pool
  }

  # Cloud-init drive
  disk {
    type    = "cloudinit"
    slot    = "scsi1"
    storage = "local-lvm"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  ipconfig0 = "ip=192.168.0.220/24,gw=192.168.0.1"

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    type = "serial0"
  }

  ciuser    = "ubuntu"
  sshkeys = file("~/.ssh/id_rsa.pub")
}
