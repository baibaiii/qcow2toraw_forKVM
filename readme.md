#脚本介绍
一个批量将kvm内的qcow2磁盘格式转换成raw的工具
# 如何使用
默认脚本里面的变量，代表操作所有的虚拟机，将所有的kvm虚拟机的qcow2类型的磁盘转换成raw磁盘格式。

### 如果想指定哪些虚拟机进行磁盘格式转换
运行脚本前先执行
`virsh list --all > /virsh_list.txt `
`vim /virsh_list.txt`

修改 virsh_list.txt文件保留你需要磁盘转换的机器，然后取消脚本内以下注释即可
output=$(cat /virsh_list.txt)

注意：
如果磁盘转换报错，请将虚拟机关机，或待机状态后再执行脚本，也可能是文件被占用导致 `


**sudo lsof /var/lib/libvirt/images/centos7.0.qcow2 #查看qcow2文件占用
`**
