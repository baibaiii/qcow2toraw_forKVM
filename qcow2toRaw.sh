#!/bin/bash
########################################################################################
#如果需要操作的是所有虚拟机，请将多余的output变量注释掉，将以下变量生效
output=$(virsh list --all)
#
#如果想指定你需要操作哪些机器则运行virsh list --all > /virsh_list.txt 修改/virsh_list.txt文件保留你需要磁盘转换的机器
#output=$(cat /virsh_list.txt)
########################################################################################
#颜色
blue() {
    echo -e "\033[34m\033[01m$1\033[0m"
}
green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}
red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

# 提取名称字段值
names=$(green "$output" | awk '{if(NR>2) print $2}')
#建立配置备份目录
mkdir /kvm_config >/dev/null 2>&1

# 遍历名称值列表并打印
for name in $names; do
    red "   "
    red "$name"
    virsh domblklist --details --domain $name
    savefile=/kvm_config/$name.xml
    virsh dumpxml $name >$savefile
    #获取需要转换的磁盘名称，去重光盘，仅选择qcow2格式
    getdiskname=$(virsh domblklist --details --domain $name | grep -v 'cdrom' | grep 'qcow2' | awk '{print $4}' | sed 's/\.qcow2$//')

    #此变量计算磁盘数量
    count=0

    #获取磁盘
    for getdiskname in $getdiskname; do
        ((count++)) #统计获取到的磁盘的数量
        blue "=============================$name-disk$count======================================="
        green "获取到$name虚拟机的磁盘 $getdiskname  正在转换磁盘格式！"
        qemu-img convert -p -f qcow2 -O raw ${getdiskname}.qcow2 ${getdiskname}.raw

        # 检查命令是否成功运行
        if [ $? -eq 0 ]; then
            green "qemu-img convert -p -f qcow2 -O raw ${getdiskname}.qcow2  ${getdiskname}.raw 磁盘格式转换成功"
            chown qemu:qemu ${getdiskname}.raw
            #未做具体判断，将配置文件内所有qcow2修改为raw，如果需要生效配置文件，则手动运行 “virsh define 配置文件.xml”
            sed -i 's/qcow2/raw/g' $savefile && green "已将$savefile配置文件的磁盘格式修改为raw！" || red "$savefile文件修改失败"
        else
            red "qemu-img convert -p -f qcow2 -O raw ${getdiskname}.qcow2  ${getdiskname}.raw "
            red "qemu-img convert 转换失败失败，命令如上"
            red "$savefile 磁盘转换失败,请关闭虚拟机才能够进行转换"
        fi
    done

done
