variable "workers" {
  default = {
    worker1 = { name = "k8s-worker-1", vmid = 222, ip = "192.168.0.222", cores = 2, memory = 2096 },
    worker2 = { name = "k8s-worker-2", vmid = 223, ip = "192.168.0.223", cores = 2, memory = 2096 }
  }
}

resource "proxmox_vm_qemu" "workers" {
  for_each = var.workers

  name   = each.value.name
  vmid = each.value.vmid
  target_node = "pve"
  clone  = "ubuntu-2404-k8s-node-template"
  full_clone = true
  os_type = "cloud-init"
  scsihw = "virtio-scsi-single"
  onboot = true

  cpu {
    cores  = each.value.cores
    sockets = 1
  }

  memory = each.value.memory

  disk {
    size    = "16G"
    type    = "disk"
    slot    = "scsi0"
    storage = "local-lvm"
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
