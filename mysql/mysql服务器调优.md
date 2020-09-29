# mysql服务器调优总结

## bool buffer调整

1. 调整bool buffer的大小，默认情况下占物理内存的80%
2. 监控innodb的监控日志，调整old LRU和new  LRU的占比，`innodb_old_blocks_pct`
3. 防止大批量读取的时候，old LRU的数据过早的加入到new LRU，调整将old LRU的数据加入到new LRU中的时间参数：`innodb_old_blocks_time`
4. 