#!/bin/bash
numaid=0
mem=4096
diskdriver="virtio-blk-pci"
diskbus="pci"
diskaddr="addr=0x5"
seabios="/usr/share/seabios/bios.bin"
kvm="kvm"
cpus=2
incoming=""
vhost="on"
monseabios=""
monitor=""
qmp=""
vnc=""
vga="-vga std"
global=""
model="host"
extrargs=""
machine="pc"
#monitor="-monitor unix:/tmp/qemu.monitor5,server,nowait"

while [ $# -gt 0 ]; do
    case $1 in
    --dimmid)
        dimmid="id=$2,"
        shift 2
        ;;
    --dimmsize)
        dimmsize="size=$2"
        dimms=$dimms" "$dimmarg$dimmid$dimmsize$dimmpop" "
        shift 2
        ;;
    --dimmarg)
        dimmarg="-dimm "
        shift 1
        ;;
    --dimmdev)
        dimmarg=" -device dimm,"
        shift 1
        ;;
    --dimmpop)
        dimmpop=",populated=on"
        shift 1
        ;;
    --e1000)
        net="-net nic,model=e1000"
        shift 1
        ;;    
    --numa)
        numarg=" -numa node,nodeid=0,cpus=2 -numa node,nodeid=1,cpus=2"
        shift 1
        ;;
    --lsi)
        extra="-device lsi"
        shift 1
        ;;
    --scsi)
        diskdriver="scsi-disk"
        shift 1
        ;;
    --root)
        rootimage=$2
        shift 2
        ;;
    --ide)
        diskdriver="ide-hd"
        diskbus="ide"
        diskaddr=""
        shift 1
        ;;
    --diskextra)    
        diskextra="-drive file=$2,if=none,id=extra,format=raw"
        shift 2
        ;;
    --scsidiskextra)
        diskextra=$diskextra" -device scsi-disk,drive=extra"
        shift 1
        ;;    
    --idediskextra)
        diskextra=$diskextra" -device ide-disk,drive=extra"
        shift 1
        ;;    
    --virtiodiskextra)
        diskextra=$diskextra" -device virtio-blk-pci,drive=extra"
        shift 1
        ;;
    --imagextra)    
        imagextra="-drive file=$2,if=none,id=isoextra,format=raw"
        shift 2
        ;;
    --cdromextra)
        imagextra=$imagextra" -device ide-cd,drive=isoextra"
        shift 1
        ;;
    --bios)
        seabios=$2
        shift 2
        ;;   
    --mem)
        mem=$2
        shift 2
        ;;   
    --cpus)
        cpus=$2
        shift 2
        ;;
    --qga)    
        qga="-device virtio-serial -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 -chardev socket,path=/tmp/qga.sock,server,nowait,id=qga0 "
        shift 1
        ;;
    --vhostoff)
        vhost="off"
        shift 1
        ;;    
    --kvm)
        kvm=$2
        shift 2
        ;;    
    --vnc)
        vnc="-vnc 0.0.0.0:$2"
        shift 2
    	;;
    --incoming)
        incoming="-incoming $2"
        shift 2
    	;;
    --monseabios)
        monseabios="-chardev stdio,id=seabios -device isa-debugcon,iobase=0x402,chardev=seabios"
        shift 1
    	;;
    --monitor)
        monitor="-monitor $2"
        shift 2
    	;;
    --qmp)
        qmp="-qmp $2"
        shift 2
    	;;
    --vga)
        vga="-vga $2"
        shift 2
    	;;
    --vgarom)
        vga="-device $2,romfile=$3"
        shift 3
    	;;
    --global)
        global="-global $2"
        shift 2
    	;;
    --model)
        model=$2
        shift 2
    	;;
    --machine)
        machine=$2
        shift 2
    	;;
    --extra)
        extrargs=$extrargs$2
        shift 2
    	;;
    esac
done

net="-netdev type=tap,id=guest0,vhost=$vhost -device virtio-net-pci,netdev=guest0 "

$kvm -bios $seabios -enable-kvm  \
-M $machine -smp $cpus,maxcpus=64 \
-cpu $model \
-m $mem -drive file=$rootimage,if=none,id=drive-virtio-disk0,format=raw \
-device $diskdriver,bus=$diskbus.0,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 \
$vga \
$net \
$dimms \
$qga \
$numarg $extra \
$diskextra \
$imagextra \
$vnc \
$global \
$monitor $monseabios $incoming\
$qmp \
$extrargs

#-device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x8
#-monitor stdio \

#id=p$4m0,size=$4M 
