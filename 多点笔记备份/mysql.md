# mysql

mysql常用导入数据的命令：在导入的过程中，应该先创建一个数据库，再进行导入，否则会出错
1.mysql命令
  mysql -u[用户名] - p [数据库名] < [文件名].sql

D:\\tools\\mysql\\mysql-5.7.16-winx64\\bin\\mysql -uroot -p 123456 --default-character-set=utf8 dmall_inventory_adjust < D:\\数据库备份\\dmall_inventory_adjust_20210713.sql

2.source命令
  mysql>source dmall_inventory_adjust_20210713.sql;前提是先选择一个数据库，然后在进行导入

	source D:\\数据库备份\\dmall_rdp_fresh.sql

	source C:\\Users\\dmall\\Downloads\\DDL_dmall_inventory_count_105.sql
	
	source C:\\Users\\dmall\\Downloads\\DDL_dmall_inventory_count_303.sql
	
	


url: jdbc:mysql:replication://10.16.247.226:5703/dmall_rdp_voucher?serverTimezone=CTT&characterEncoding=UTF-8&autoReconnect=true&allowMultiQueries=true&useSSL=false&rewriteBatchedStatements=true&connectTimeout=2000&socketTimeout=180000
        username: my_user_5703
        password: my_user_5703@df~

jdbc:mysql://10.16.247.194:8703/dmall_rdp_voucher


查看连接数：
select * from information_schema.processlist where db = 'dmall_rdp_voucher';


alter table st_delivery_00 add `batch_expiry_date` DATETIME NULL DEFAULT NULL COMMENT '批次过期日期';


## 监控

查看数据库各表容量大小
```
select
table_schema as '数据库',
table_name as '表名',
table_rows as '记录数',
truncate(data_length/1024/1024, 2) as '数据容量(MB)',
truncate(index_length/1024/1024, 2) as '索引容量(MB)'
from information_schema.tables
where table_schema='rta_price_tag' and table_name like 'd_price_tag_list%'
order by data_length desc, index_length desc;
```




select * from information_schema.innodb_trx;
-- 查看正在锁的事务
select * from information_schema.innodb_locks;
-- 查看等待锁的事务
select * from information_schema.innodb_lock_waits;



SELECT  table_name, column_name, data_type from information_schema.columns where table_name = 'st_receipt_23' and data_type in ('datetime', 'date', 'timestamp');

获取新增utc字段的sql：
```
SELECT  
    concat('ALTER TABLE ', table_name, ' ADD ', column_name, '_utc bigint DEFAULT NULL COMMENT \'', column_comment, '\'', 'AFTER ', column_name, ';')
from information_schema.columns where table_name = 'st_receipt_00' and data_type in ('datetime', 'date', 'timestamp');
```

```
SELECT  
    concat('ALTER TABLE ', table_name, ' drop COLUMN ', column_name, ';')
from information_schema.columns 
where table_name in ('st_receipt_00', 'st_adjust_00', 'st_allocation_00', 'st_count_00', 'st_delivery_00', 'st_delivery_on_way_00', 'st_process_00', 'st_requisition_00') 
	and data_type in ('datetime', 'date', 'timestamp')
order by table_name;
```




// TODO: 2022/2/15 时区国际化注释，没有使用这个报表，所以这里没改造



queryMap.startTimeUtc
queryMap.endTimeUtc
voucherStartTimeUtc

## 时间函数
```
SELECT FROM_UNIXTIME( 1527476643, '%Y%m%d' );
SELECT FROM_UNIXTIME( 1527476643, '%Y年%m月%d' );
SELECT FROM_UNIXTIME( 1527476643, '%Y-%m-%d %H:%i:%s' );


SELECT UNIX_TIMESTAMP(); -- 获取当前时间的秒数
SELECT UNIX_TIMESTAMP('2018-05-28 11:04:03'); -- //获取指定日期格式的秒数
SELECT UNIX_TIMESTAMP('2018-05-28'); -- //获取指定日期格式的秒数


FROM_UNIXTIME(utc / 1000, '%Y-%m-%d %H:%i:%s')
FROM_UNIXTIME(utc / 1000)
```


## 场景sql

```
ALTER TABLE user ADD batch_expiry_date_utc bigint DEFAULT NULL COMMENT '批次过期日期' AFTER sex;

ALTER table `out_plan_report_00` 
	add COLUMN close_name varchar(64) DEFAULT NULL COMMENT '关单人', 
	add COLUMN order_type varchar(16) DEFAULT NULL COMMENT '订单类型 P03等';


ALTER TABLE user drop COLUMN batch_expiry_date_utc;

-- 索引操作
alter table user add index idx_test(sex, batch_expiry_date_utc, age);

alter table user add UNIQUE idx_age(`age`);

ALTER TABLE user DROP INDEX idx_test;
```


