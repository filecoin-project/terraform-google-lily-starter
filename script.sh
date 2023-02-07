#!/bin/bash -xe

#: dependencies
sudo apt update -y && sudo apt install -y mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget tmux -y && sudo apt upgrade -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
wget -c https://golang.org/dl/go1.18.8.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.bashrc && source ~/.bashrc

#: lily
git clone https://github.com/filecoin-project/lily.git
cd ./lily
git checkout ${release}
CGO_ENABLED=1 make clean ${network}
sudo cp ./lily /usr/local/bin/lily

#: add persistent disk
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p /mnt/disks/lily
sudo mount -o discard,defaults /dev/sdb /mnt/disks/lily
sudo chmod a+w /mnt/disks/lily

#: download latest snapshot
if [ ${network} = "hyperspacenet" ]; then
    aria2c -x5 https://snapshots.hyperspace.yoga/hyperspace-latest-pruned.car --dir=/mnt/disks/lily
else
    aria2c -x5 https://snapshots.${network}.filops.net/minimal/latest.zst --dir=/mnt/disks/lily
    zstd -d /mnt/disks/lily/*.zst
fi

#: run tmux session and run lily on that
tmux new-session -d -s lily_node './lily init --repo=/mnt/disks/lily --import-snapshot /mnt/disks/lily/*.car && ./lily daemon --repo=/mnt/disks/lily'
