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

show table status like 'mytest';

select count(*) from titles;
create table sal_test2 like salaries;
insert into sal_test select * from salaries;
truncate table sal_test;

create table mytest(
	t1 varchar(10),
	t2 varchar(10),
	t3 char(10),
	t4 varchar(10)
) engine=innodb charset=latin1 row_format=compact;

create table test(
	a varchar(65532)
)engine=innodb charset=latin1;

insert into test select repeat('a', 65532);

select * from test;

show WARNINGS;

select * from mytest;
drop table mytest;

insert into mytest values('a', 'bb', 'cc', 'ddd');
insert into mytest values('e', 'ff', 'gg', 'hhh');
insert into mytest values('i', null, null, 'jjj');


select count(*) from sal_test t limit 100;
update 
-- 12
-- 64 252
start TRANSACTION;
update sal_test set salary = 50 limit 1;
commit;
ROLLBACK;


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



select * from employees;
select * from salaries;
select * from departments where dept_no = 'd009';

select * from cas.data_user;

create table employees_test like employees;
insert into employees_test select * from employees limit 100;

delete from employees_test;
show create table employees_test;
create index idx_et_fname on employees_test(first_name);

select * from depart_test;
update depart_test set dept_name = 'asdfadsf' where dept_no = 'd005';



select @@INNODB_SESSION_TEMP_TABLESPACES;
select * from INFORMATION_SCHEMA.INNODB_TEMP_TABLE_INFO ;


SELECT * FROM INFORMATION_SCHEMA.FILES WHERE TABLESPACE_NAME='innodb_temporary';


-- 1. 查询文件与表空间的关系
select * from INFORMATION_SCHEMA.FILES WHERE FILE_TYPE LIKE 'UNDO LOG'
-- 监控表空间的状态
SELECT NAME, STATE FROM INFORMATION_SCHEMA.INNODB_TABLESPACES WHERE NAME LIKE '%%';







show engine innodb status;

TRUNCATE test.opening_lines;

CREATE UNDO TABLESPACE undo2 ADD DATAFILE 'file_name.ibu';


SELECT * FROM INFORMATION_SCHEMA.FILES WHERE FILE_TYPE LIKE 'UNDO LOG';


create table test like employees;
insert into test select * from employees

TRUNCATE test


CREATE TABLESPACE `ts1` ADD DATAFILE 'E:\\Tools\\mysql-8.0.21-winx64\\data2\\ts1.ibd' Engine=InnoDB;
CREATE TABLESPACE `ts2` Engine=InnoDB;

ALTER TABLE test TABLESPACE ts1
ALTER TABLE test TABLESPACE=innodb_file_per_table;

DROP TABLESPACE ts2










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
-- 1: 64.993s	 58.491s
-- 2: 33.384s  27.192s
*/

select * from tast_load;
truncate table tast_load;


select count(*) from tast_load;
show variables like '%innodb_flush_log_at_trx_commit%';























