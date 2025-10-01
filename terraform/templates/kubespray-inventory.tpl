[kube_control_plane]
%{ for _, vm in masters ~}
${ vm.name } ansible_host=${ vm.ip }
%{ endfor ~}

[etcd:children]
kube_control_plane

[kube_node]
%{for _, vm in workers ~}
${ vm.name } ansible_host=${ vm.ip }
%{ endfor ~}

[all:vars]
# Output the file at the the artifacts dir in kubespray
kubeconfig_localhost=true