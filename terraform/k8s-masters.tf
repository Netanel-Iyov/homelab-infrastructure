variable "masters" {
  default = {
    master1 = { name = "k8s-master-1", vmid = 221, ip = "192.168.0.221", cores = 2, memory = 4096 }
  }
}

resource "proxmox_vm_qemu" "masters" {
  for_each = var.masters

  name   = each.value.name
  vmid = each.value.vmid
  target_node = "pve"
  clone  = "ubuntu-2404-k8s-node-template"
  full_clone = true
  os_type = "cloud-init"
  scsihw = "virtio-scsi-single"

  cpu {
    cores  = each.value.cores
    sockets = 1
  }

  memory = each.value.memory

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
  
  ipconfig0 = "ip=${each.value.ip}/24,gw=192.168.0.1"

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
