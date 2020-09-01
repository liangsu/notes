-- 系统表空间的大小，autoextend表示容量不够则自动增长
show variables like '%innodb_data_file_path%';
-- 系统表空间每次增长多少M
show variables like '%innodb_autoextend_increment%';
-- innodb能识别的目录
show variables like '%innodb_directories%';
show variables like '%innodb_data_home_dir%';
show variables like '%datadir%';
-- undo表空间目录
show variables like '%innodb_undo_directory%';
-- 每个undo表空间或者临时表空间的回滚段的大小，默认值128，最大值128
show variables like '%innodb_rollback_segments%';
-- 是否自动截断undo表空间
show variables like '%innodb_undo_log_truncate%';
-- undo表空间的最大大小，超过这个大小，如果自动截断undo表空间打开了，会触发自动截断表空间。默认值1073741824 bytes (1024 MiB)
show variables like '%innodb_max_undo_log_size%';
-- undo表空间的文件数量，这样每个回滚段可以平均的分配到几个文件中。
show variables like '%innodb_undo_tablespaces%';

-- purge线程查询undo表空间去截断的频率：每次多少次？
SELECT @@innodb_purge_rseg_truncate_frequency;
-- 临时表空间的路径，默认：#innodb_temp
show variables like '%innodb_temp_tablespaces_dir%';
-- 8.0以前的版本：内部临时表使用的存储引擎
show variables like '%internal_tmp_disk_storage_engine%';

-- bool buffer在磁盘上的映射
show variables like '%innodb_doublewrite%';
-- 设置redo log的日志大小
show variables like '%innodb_log_file_size%';
-- 设置redo log日志的数量
show variables like '%innodb_log_files_in_group%';
-- redo log日志归档目录，格式：label:path1;path2，label是归档目录名称，需要唯一
show variables like '%innodb_redo_log_archive_dirs%';

 
 show variables like '%innodb_lock_wait_timeout%';
 -- 是否启用死锁检测
 show variables like '%innodb_deadlock_detect%';
-- 查看innodb的版本
show variables like '%innodb_version%';
-- 查看innodb读写线程的数量
show variables like '%innodb_%io_thread%';
-- 查看innodb的清理undo log的线程数量。
show variables like '%innodb_purge_threads%';

-- 查看innodb的缓冲池实例的个数，在缓冲池大小在1G以上这个参数才生效
show variables like '%innodb_buffer_pool_instances%';
-- 缓冲池的大小
show variables like '%innodb_buffer_pool_size%';

-- 查看innodb LRU列表中old列表的占比，默认37%（差不多3/8）
show variables like '%innodb_old_blocks_pct%';
-- LRU中多少次将old列表中的数据移入new列表
show variables like '%innodb_old_blocks_time%';
-- 控制LRU中可用页的数量
show variables like '%innodb_lru_scan_depth%';

-- 当buffer pool中脏页数量占比达到多少时强制执行checkpoint
show variables like '%innodb_max_dirty_pages_pct%';
-- 合并插入缓冲的数量= innodb_io_capacity * 5%，刷新脏页的数量=innodb_io_capacity
show variables like '%innodb_io_capacity%';
-- 每次full purge时回收undo log页的数量
show variables like '%innodb_purge_batch_size%';
-- 是否启用自适应刷新脏页，通过判断redo log的速度来决定刷新脏页的数量
show variables like '%innodb_adaptive_flushing%';

-- change buffer最大使用内存占缓冲池的百分比，该参数的最大有效值50
show variables like '%innodb_change_buffer_max_size%';
-- 开启buffer的选项，可选参数：inserts、deletes、purges、changes、all、none
show variables like '%innodb_change_buffering%';

-- 刷新邻接页
show variables like '%innodb_flush_neighbors%';
-- 关闭参数
show variables like '%innodb_fast_shutdown%';
-- 启动恢复策略，可选范围：0-6，
show variables like '%innodb_force_recovery%';

-- 设置参数的语法：
select @@session.read_buffer_size;
set @@global.long_query_time = 1;
set @@global.long_query_time = 1;


-- 查看错误日志的位置
show variables like '%log_error%';

-- 慢查询日志的时间阈值，默认10秒
show variables like '%long_query_time%';
-- 超过最小检查行数的sql，记录慢查询日志
show variables like '%min_examined_row_limit%';
-- 是否开启慢查询日志
show variables like '%slow_query_log%';
-- 慢查询日志位置
show variables like '%slow_query_log_file%';
-- 是否记录管理sql语句的慢查询日志，包括：ALTER TABLE, ANALYZE TABLE, CHECK TABLE, CREATE INDEX, DROP INDEX, OPTIMIZE TABLE, and REPAIR TABLE
show variables like '%log_slow_admin_statements%';
-- 如果是从库，复制数据的时候，是否将慢sql记录slow log。只有基于sql语句的复制或者混合复制才会记录慢查询日志。
show variables like '%log_slow_slave_statements%';
-- 执行的sql如果没有使用索引，会将sql记录到慢查询日志
show variables like '%log_queries_not_using_indexes%';
-- 每分钟记录到slow log且未使用索引的sql的语句次数，默认值0，表示没有限制。
show variables like '%log_throttle_queries_not_using_indexes%';
-- 慢查询日志输出到文件还是表
show variables like '%log_output%';
-- 慢查询日志中是否输出额外的统计信息
show variables like '%log_slow_extra%';

-- 是否启用查询日志
show variables like '%general_log%';

set global general_log = 1;
select * from mysql.slow_log;


show master status; -- 42843959 42844282
show binlog events in 'mysql-bin.000032';
-- binlog单个日志文件的最大值，默认值1073741824（1G），单位：byte
show variables like '%max_binlog_size%';
-- 未提交的二进制日志会记录到缓冲中，缓冲大小有这个参数确定，这个缓冲是每个会话一个缓冲。
show variables like '%binlog_cache_size%';
-- 每写缓冲多少次就同步到磁盘
show variables like '%sync_binlog%';
-- 如果当前数据库是复制中的slave，则它不会将从master获取的binlog写入到自己的binlog中去，若需要，则需要开启该参数，在master->slave->slave中需要。
show variables like '%log_slave_update%';
-- binlog记录的格式，可选值：STATEMENT、ROW、MIXED
show variables like '%binlog_format%';

-- socket链接文件
show variables like '%socket%';
-- 进程文件
show variables like '%pid_file%';

-- 是否开启独立表空间
show variables like '%innodb_file_per_table%';

-- mysql将数据页读入内存后，会将页中的pageHeader与file Trailer中做校验，判断该页是否完整。
show variables like '%innodb_checksum_algorithm%';
-- 
show variables like '%par%';
-- 查看分区信息
select * from information_schema.`PARTITIONS` where table_schema = database();

-- 查看表的行格式、等信息
show table status like 'employees';


-- 手动配置redo log归档：当写很频繁的时候，redo log的修改速度远远大于备份的速度，需要将redo log归档。subdir可选参数，归档的子目录名称
SELECT innodb_redo_log_archive_start('label', '。');

-- 查看innodb中，buffer pool的命中率、每秒pages_made_young的次数
select pool_id, hit_rate, pages_made_young, pages_not_made_young from information_schema.INNODB_BUFFER_POOL_STATS;
-- 查看每个lru列表中每页的信息
select * from information_schema.INNODB_BUFFER_PAGE_LRU where space = 19;
-- 查看每个unzip_lru列表中每页的信息
select * from information_schema.INNODB_BUFFER_PAGE_LRU where compressed_size <> 0;
-- 脏页
select table_name, space, page_number, page_type from information_schema.INNODB_BUFFER_PAGE_LRU where oldest_modification > 0;


-- 1. 查询文件与表空间的关系
select * from INFORMATION_SCHEMA.FILES WHERE FILE_TYPE LIKE 'UNDO LOG'
-- 监控表空间的状态
SELECT NAME, STATE FROM INFORMATION_SCHEMA.INNODB_TABLESPACES WHERE NAME LIKE '%%';

CREATE UNDO TABLESPACE undo2 ADD DATAFILE 'file_name.ibu';
SELECT * FROM INFORMATION_SCHEMA.FILES WHERE FILE_TYPE LIKE 'UNDO LOG';

CREATE TABLESPACE `ts1` ADD DATAFILE 'E:\\Tools\\mysql-8.0.21-winx64\\data2\\ts1.ibd' Engine=InnoDB;

CREATE TABLESPACE `ts2` Engine=InnoDB;
show engine innodb status;

ALTER TABLE test TABLESPACE ts1
ALTER TABLE test TABLESPACE=innodb_file_per_table;




-- python C:/Users/Administrator/Desktop/mysql/david-mysql-tools/trunkvpy_innodb_page_type/py_innodb_page_info.py E:\\Tools\\mysql-8.0.21-winx64\\data\\tpcc_big\\customer.ibd



-- 查看latch信息
show engine innodb mutex;

show full PROCESSLIST;
-- 
select * from information_schema.innodb_trx;
select * from information_schema.innodb_locks;
select * from information_schema.INNODB_lock_waits;
-- mysql 8.0之后查看锁、等待的信息
select * from `performance_schema`.data_locks;
select * from `performance_schema`.data_lock_waits;


SELECT
  r.trx_id waiting_trx_id,
  r.trx_mysql_thread_id waiting_thread,
  r.trx_query waiting_query,
  b.trx_id blocking_trx_id,
  b.trx_mysql_thread_id blocking_thread,
  b.trx_query blocking_query
FROM performance_schema.data_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_engine_transaction_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_engine_transaction_id;

-- 定位一个阻塞的会话，是被哪些sql阻塞了
-- 查询
select waiting_pid from sys.innodb_lock_waits;
-- 查询阻塞的thread_id
select * from `performance_schema`.threads where processlist_id = 10;
-- 查询这个线程当前执行的sql
SELECT THREAD_ID, SQL_TEXT FROM performance_schema.events_statements_current WHERE THREAD_ID = 52;
-- 查询这个线程曾经执行的sql
SELECT THREAD_ID, SQL_TEXT FROM performance_schema.events_statements_history WHERE THREAD_ID = 52 ORDER BY EVENT_ID;


-- 超时等待时间
show variables like '%innodb_lock_wait_timeout%';
-- 是否在超时的时候对事务进行回滚
show variables like '%innodb_rollback_on_timeout%';


set @@GLOBAL.innodb_lock_wait_timeout = 5

show engine innodb status;

select @@tx_isolation
show variables like '%transaction_isolation%';

drop table t;
create table t (
	a int primary key
);
select * from t;
insert into t select 1;
insert into t select 2;
insert into t select 4;

drop table z;
create table z (
	a int primary key,
	b int,
	c varchar(10),
	d varchar(20)
);
show index from z;

select * from z;
insert into z select 1, 1, '1', '1';
insert into z select 2, 2, '2', '2';
insert into z select 3, 3, '3', '3';


delete from z;


create table z(
	a int primary key,
	b int,
	c int,
	key (b)
);

insert into z select 1, 1, 1;
insert into z select 2, 2, 2;
insert into z select 3, 3, 3;




------------------------------------------------------------------------------------------------
drop table tast_load;

create table tast_load(
	a int ,
	b char(80)
)engine = innodb;

drop PROCEDURE if exists p_load;

DELIMITER  //
create PROCEDURE p_load(count int UNSIGNED)
begin
	DECLARE s int unsigned DEFAULT 1;
	DECLARE c char(80) DEFAULT repeat('a', 80);
	
	while s <= count do
		insert into tast_load select null, c;
		commit;
		set s = s + 1;
	end while;
	
end;
// 
DELIMITER;


call p_load(1000);
/*
	插入1000条数据
	innodb_flush_log_at_trx_commit值  机械硬盘	固态硬盘
-- 0: 37.784s  34.903s
-- 1: 64.993s  58.491s
-- 2: 33.384s  27.192s
*/

select * from tast_load;
truncate table tast_load;


select count(*) from tast_load;
show variables like '%innodb_flush_log_at_trx_commit%';

start TRANSACTION;

select * from employees_test;

start TRANSACTION;
update employees_test set last_name = 'bb';
ROLLBACK;
commit;
select * from tast_load;


select * from information_schema.innodb_trx_rollback_segment;



-- 每次purge操作时，清理undo page的数量
show variables like '%innodb_purge_batch_size%';
-- 用来控制history list的长度，0表示不做限制。当history list的长度大于innodb_max_purge_lag时，会延缓dml操作。
-- History list表示事务提交的顺序组织undo log，先提交的事务在尾端。
-- 延缓算法： delay = (length(history_list) - innodb_max_purge_lag) * 10 - 5。 
-- 如果一条dml操作更新了5条数据，则延缓时间 = delay * 5
show variables like '%innodb_max_purge_lag%';
-- 最大延迟时间，上面步骤计算出来的delay如果超过该值，则取该值
show variables like '%innodb_max_purge_lag_delay%';
-- flush阶段等待的时间
show variables like '%binlog_max_flush_queue_time%';
show variables like '%binlog%';



-- tps计算： (com_commit + com_rollback) / time
-- 事务提交次数
show global status like 'com_commit';
-- 事务回滚次数
show global status like 'com_rollback';
-- 
show global status like 'handler_commit';
--
show global status like 'handler_rollback';

-- 数据库的隔离级别
show variables like '%transaction_isolation%';



xa start 'b';
insert into t select 3;
xa end 'b';
xa prepare 'b';
xa RECOVER;
xa commit 'b';
xa ROLLBACK 'b';

select * from t;


show index from salaries

-- 重新计算表的cardinalitiy
analyze table t;

select @@version;
-- 创建和删除索引的默认算法，off: inplace算法、on：copy算法（使用临时表）
show variables like '%old_alter_table%';
-- 索引在创建过程中，执行的dml操作会放入一个缓存，缓存的大小由该值决定。如果创建索引过程中加share锁，则不会发生写操作
show variables like '%innodb_online_alter_log_max_size%';

-- mysql8之前的参数，统计cardinality值时，每次采样页的数量
show variables like '%innodb_stats_sample_pages%';
-- 如何对待索引中出现null值记录。nulls_equal：将null值记录视为相等的记录、nulls_unequal：将null值记录视为不通的记录、nulls_ignored：忽略null值记录。
show variables like '%innodb_stats_method%';

-- 是否将analyze table命令计算的cardiality存放到磁盘上。
show variables like '%innodb_stats_persistent%';
-- 在执行show table status、show index及访问infomation_schema架构下的表的tables和statistic时，是否重新计算索引的cardinality的值
show variables like '%innodb_stats_on_metadata%';
-- innodb_stats_persistent为on时，执行analyze table采样页的数量
show variables like '%innodb_stats_persistent_sample_pages%';
-- 采样页的数量，用于取代innodb_stats_sample_pages
show variables like '%innodb_stats_transient_sample_pages%';


set @@global.innodb_stats_persistent = off;

------------------------------------------------------------------------------------------------

--
show variables like '%optimizer_switch%';
-- mrr为on，表示启用multi-Range read。mrr_cost_based表示是否通过cost based的方式启用mrr优化。
-- 如果mrr=on,mrr_cost_based=off，则表示一直启用mrr优化
set @@optimizer_switch = 'mrr=on,mrr_cost_based=off';
-- 启用mrr时的缓冲区大小，当大于该值时，则执行器对已经缓存的数据根据rowId排序，并通过rowId来取得行数据。
show variables like '%read_rnd_buffer_size%';


set @@optimizer_switch = 'mrr=on,mrr_cost_based=off';

-- 下面语句在启用mrr，和没有启用mrr的性能对比
-- off 21.298
-- on  0.793
explain select * from salaries where salary > 10000 and salary < 40000;

-- explain extra 值说明：
-- Using MRR 启用multi-Range read优化 
-- Using index condition： 使用了index condition pushdown优化，将索引的过滤条件从服务层下推到存储引擎层
-- Using where:
-- Using index: 使用覆盖索引
-- Using filesort： 需要使用额外的一次排序
-- Using temporary 表示MySQL需要使用临时表来存储结果集，常见于排序和分组查询，常见 group by ; order by
-- 

-- index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=on,mrr=on,mrr_cost_based=off,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on,use_invisible_indexes=off,skip_scan=on,hash_join=on,subquery_to_derived=off,prefer_ordering_index=on





