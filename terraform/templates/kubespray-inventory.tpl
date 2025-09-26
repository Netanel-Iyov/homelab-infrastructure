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