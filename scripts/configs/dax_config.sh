echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sudo rm -rf /mnt/pmem_emul/*
sudo umount /mnt/pmem_emul
sudo mkfs.ext4 -F -b 4096 /dev/pmem12
sudo mount -o dax /dev/pmem12 /mnt/pmem_emul
