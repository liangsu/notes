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

