#!/bin/bash
echo "Clearing PageCache..."
sync
echo 1 > /proc/sys/vm/drop_caches

echo "Clearing dentries and inodes..."
sync
echo 2 > /proc/sys/vm/drop_caches

echo "Clearing all caches..."
sync
echo 3 > /proc/sys/vm/drop_caches

echo "Cache cleared successfully!"
