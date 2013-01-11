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
extracontrollers=""
machine="pc"
spawn=""
numainfo=""
devices=""
plegap=""
maxcpus=64
#monitor="-monitor unix:/tmp/qemu.monitor5,server,nowait"
usbcontrollers=0
cachemode="none"

while [ $# -gt 0 ]; do
    case $1 in
    --nodefaults)
        extrargs=$extrargs" -nodefaults -nodefconfig"
        shift 1
        ;;
    --cachemode)
        cachemode=$2
        shift 2
        ;;
    --dimmid)
        dimmid="id=$2"
        shift 2
        ;;
    --dimmnode)
        dimmnode=",node=$2"
        shift 2
        ;;
    --dimmbus)
        dimmbus=",bus=$2"
        shift 2
        ;;
    --dimmsize)
        dimmsize=",size=$2"
        dimms=$dimms" "$dimmarg$dimmid$dimmsize$dimmnode$dimmpop" "
        shift 2
        ;;
    --dimmarg)
        dimmarg="-dimm "
        shift 1
        ;;
    --dimmdev)
        dimmarg=" -device dimm"
        shift 1
        ;;
    --dimmpop)
        dimmpop=",populated=$2"
        shift 2
        ;;
    --device)
        devices=$devices" -device $2"
        shift 2
        ;;
    --e1000)
        net="-net nic,model=e1000"
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
    --usb-piix4)
        extracontrollers=$extracontrollers" -device piix4-usb-uhci,id=usb$usbcontrollers"
        let usbcontrollers++
        shift 1
        ;;
    --usb-piix3)
        extracontrollers=$extracontrollers" -device piix3-usb-uhci,id=usb"
        #extracontrollers=$extracontrollers" -device piix3-usb-uhci,id=usb$usbcontrollers" #use this for multplit usb host controllers
        #extracontrollers=$extracontrollers" -device piix3-usb-uhci"
        let usbcontrollers++
        shift 1
        ;;
    --usb-ehci)
        extracontrollers=$extracontrollers" -device usb-ehci,id=usb$usbcontrollers"
        let usbcontrollers++
        shift 1
        ;;
    --usbtablet)
        extrargs=$extrargs" -device usb-tablet,id=input0"
        shift 1
        ;;
    --ahci)
        extracontrollers=$extracontrollers" -device ahci,id=ahci.0,bus=pci.0"
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
    --usbdriver)
        diskdriver="usb-storage"
        diskbus="usb"
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
        imagextra="-drive file=$2,if=none,id=isoextra,format=raw" #media=cdrom
        shift 2
        ;;
    --imagecdromextra)    
        imagextra="-drive file=$2,if=none,id=isoextra,format=raw,media=cdrom"
        shift 2
        ;;
    --imagextradummy)    
        imagextra="-drive if=none,id=isoextra,format=raw"
        shift 1
        ;;
    --cdromideextra)
        imagextra=$imagextra" -device ide-drive,drive=isoextra,id=ide1-cd1"
        shift 1
        ;;
    --cdromideextraempty)
        imagextra=$imagextra" -device ide-cd"
        shift 1
        ;;
    --cdromscsiextra)
        imagextra=$imagextra" -device scsi-cd,drive=isoextra"
        shift 1
        ;;
    --cdromscsiextraempty)
        imagextra=$imagextra" -device scsi-cd"
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
        extrargs=$extrargs" "$2
        shift 2
    	;;
    --diskbus)
        diskbus=$2
        shift 2
    	;;
    --L)
        extrargs=$extrargs"-L "$2
        shift 2
        ;;    
    --numactl)
        spawn="numactl $2 -l"
        shift 2
        ;;    
    --numa)
        numainfo=$numainfo" -numa $2"
        shift 2
        ;;    
    --plegap)
        plegap="-ple-gap $2"
        shift 2
        ;;    
    --maxcpus)
        maxcpus=$2
        shift 2
        ;;
    --vda)
        args=$args"-device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent "
        shift
        ;;
    --usbredirdisk)
        args=$args"-usbdevice disk:$2 -chardev spicevmc,name=usbredir,id=usbredirchardev1 -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1,debug=3 "
        shift 2
        ;;
    --usbcontrol)
        args=$args"-readconfig $2 "
        shift 2
        ;;
    --spice)
        spice="-spice port=5930,disable-ticketing"
        vga="-vga qxl"
        shift 1
        ;;
    --fbdev)
        extrargs=$extrargs" ""-fbdev "
        shift 1
        ;;
    --assign)
        passthrough="-device pci-assign,host=$2"
        shift 2
        ;;
    esac
done

net="-netdev type=tap,id=guest0,vhost=$vhost -device virtio-net-pci,netdev=guest0 "

$spawn $kvm -bios $seabios -enable-kvm  \
-M $machine -smp $cpus,maxcpus=$maxcpus \
-cpu $model \
$extracontrollers \
-m $mem -drive file=$rootimage,if=none,id=drive-virtio-disk0,format=raw,cache=$cachemode \
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
$extrargs \
$numainfo \
$devices \
$plegap \
$spice \
$passthrough

#-device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x8
#-monitor stdio \

#id=p$4m0,size=$4M 

