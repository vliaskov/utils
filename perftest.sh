#!/bin/bash
#very basic script to collect kvmstats and perf-symbols for a VM benchmark
ECHO="echo"
PROG="`basename $0`"

vcpus="-a" #by default, profile all vcpus inside guest
event="" #default event is cpu-cycles
args="" #no other default options
HOST_RUN=0 #by default profile guest

usage () {

	$ECHO "Usage: $PROG [OPTIONS]"
	$ECHO "where OPTIONS are:"
	$ECHO "\t-o     prefix for output files under /tmp/"
	$ECHO "\t-a     profile all cpus and vcpus (default)"
	$ECHO "\t-e     profile specified event (default: cpu-cyles)"
	$ECHO "\t--vcpus Guest profiles only vcpus specified. (Host-profiling still applies to all cpus)"
	$ECHO "\t--ip   ip of VM to run benchmark on"
	$ECHO "\t-b     benchmark command line for VM"
	exit 2
}

if [ $# -le 0 ]; then
	usage
fi

while [ $# -gt 0 ]; do
    case $1 in
    -o)
        benchprefix=$2
        shift 2
        ;;
    --ip)
        vm=$2
        shift 2
        ;;
    -a)
        shift
        ;;
    --vcpus)
        vcpus=" --cpu "$2
        shift 2
        ;;
    -e)
        event=$event" -e "$2
        shift 2
        ;;
    -b)
        shift
        break
        ;;
    --call-graph)
        args=$args" --call-graph"
        shift
        ;;
    --host)
        HOST_RUN=1
        shift
        ;;    
    esac
done

#vm=$1
#benchprefix=$2
#shift 2

#allow perf record for non-priviliged user
echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid

guestkallsyms=/tmp/kallsyms-$vm.txt
guestmodules=/tmp/modules-$vm.txt
benchout=/tmp/$benchprefix.$vm.benchout
perfout=/tmp/$benchprefix.$vm.perf
statout=/tmp/$benchprefix.$vm.kvmstat

if [ $HOST_RUN -eq 1 ]; then
    benchout=/tmp/$benchprefix.host.benchout
    perfout=/tmp/$benchprefix.host.perf
    perf record -a $event $args -o $perfout.host.data $@ >& $benchout-1.txt
    perf report -i $perfout.host.data >& $perfout-hostdata.txt
    exit
fi

ssh root@$vm "cat /proc/kallsyms" >& $guestkallsyms
ssh root@$vm "cat /proc/modules" >& $guestmodules
ssh root@$vm "cat /proc/modules" >& $guestmodules

#kvm stats
perf stat -a -e "kvm:*" -o $perfout-kvmstat.txt ssh root@$vm "$@" >& $benchout-1.txt

#host profiling only
perf record -a $event $args -o $perfout.host.data ssh root@$vm "$@" >& $benchout-2.txt
#sudo killall -2 perf
perf report -i $perfout.host.data >& $perfout-hostdata.txt

# recording guest symbols from the host works, but "perf report" has a bug # reading the guest kallsyms and modules files (segfaults). FIXME
perf kvm --host --guestkallsyms=$guestkallsyms --guestmodules=$guestmodules record -a -o $perfout.kvmhostdata ssh root@$vm "$@" >& $benchout-3.txt
perf kvm --host --guestkallsyms=$guestkallsyms --guestmodules=$guestmodules report -i $perfout.kvmhostdata >& $perfout-kvmhostdata.txt
perf kvm --guest --guestkallsyms=$guestkallsyms --guestmodules=$guestmodules record -a -o $perfout.kvmguestdata ssh root@$vm "$@" >& $benchout-4.txt
perf kvm --guest --guestkallsyms=$guestkallsyms --guestmodules=$guestmodules report -i $perfout.kvmguestdata >& $perfout-kvmguestdata.txt

#profiling in-guest. This requires that the perf tool is also installed in the guest
ssh root@$vm perf record $vcpus $event $args -o $perfout.inguest.data "$@" >& $benchout-3.txt
scp root@$vm:$perfout.inguest.data $perfout.inguest.data
ssh root@$vm perf report -i $perfout.inguest.data | tee $perfout-inguestdata.txt
#perf report --guest --guestkallsyms=$guestkallsyms --guestmodules=$guestmodules report -i $perfout.kvmguestdata >& $perfout-kvmguestdata.txt

# other event-processing on host, besides kvm?
# e.g. block, sched layer, look at /sys/kernel/debug/tracing/available_events
#perf record -a -e "new_event" -o $perfout.kvmevents ssh root@$vm "$@" >& $benchout
# a few example post-processing python scripts for event-tracing can be found at
# tools/perf/scripts/python in the kernel tree. More can be easily written.
#perf script -s /opt/extra/vliaskov/devel/linux-guest-devel/tools/perf/scripts/python/kvm-exits.py -i $perfout.kvmevents >& $perfout-kvmexitshist.txt

