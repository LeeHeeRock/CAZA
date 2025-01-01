#!/bin/bash

# Need to check device name through lsblk.
DEV=nullb1

# We need the deadline io scheduler to gurantee write ordering
echo deadline > /sys/class/block/$DEV/queue/scheduler

./zenfs mkfs --zbd=nullb1 --aux_path=/mnt/db --finish_threshold=5 --force


# Assumes 50GB device capacity.
# Put 34GB key-value pairs. [(16 + 4096) x 4500000 x 2(fillrandom + overwrite)]
# Total 157GB Written to device. [(compation write 122GB) + (flush write 35GB)]
./db_bench \
     --fs_uri=zenfs://dev:$DEV \
     --benchmarks=fillrandom,overwrite,stats \
     -statistics \
     -db=./db \
     --num=4500000 \
     -write_buffer_size=67108864 \
     --threads=1 \
     -disable_wal=true \
     -report_interval_seconds=1 \
     -stats_dump_period_sec=5 \
     --key_size=16 \
     --value_size=4096 \
     -max_background_compactions=10 \
     -max_background_flushes=10 \
     -compression_ratio=1 \
     -use_direct_io_for_flush_and_compaction \
     -target_file_size_multiplier=1 \
