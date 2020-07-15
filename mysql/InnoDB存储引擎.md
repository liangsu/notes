# InnoDB存储引擎

## 15.1 InnoDB概论

InnoDB是一个通用存储引擎，它平衡了高可靠性和高性能。在MySQL 8.0中，InnoDB是默认的MySQL存储引擎。除非您已经配置了一个不同的默认存储引擎，否则，发出一个不带engine =子句的CREATE TABLE语句将创建一个InnoDB表

#### InnoDB的主要优点

* 它的DML操作遵循ACID模型，事务具有提交、回滚和崩溃恢复功能，以保护用户数据。更多信息请参见15.2节“InnoDB和ACID模型”
* 行级锁和oracle风格的一致性读取提高了多用户并发性和性能。更多信息请参见15.7节“InnoDB锁定和事务模型”
* InnoDB表将你的数据排列在磁盘上，以优化基于主键的查询。每个InnoDB表都有一个主键索引，称为聚集索引，用于组织数据以最小化主键查找的I/O。更多信息请参见15.6.2.1节“聚集和二级索引”
* 为了保持数据的完整性，InnoDB支持外键约束。使用外键时，将检查插入、更新和删除，以确保它们不会导致不同表之间的不一致。更多信息请参见13.1.20.5节“外键约束”

表15.1 InnoDB存储引擎特性

| 特性                                                      | 支持                                                         |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| B-tree indexes                                            | Yes                                                          |
| 备份/时间点恢复(在服务器中实现，而不是在存储引擎中实现)。 | Yes                                                          |
| 集群数据库支持                                            | No                                                           |
| 聚簇索引                                                  | Yes                                                          |
| 数据压缩                                                  | Yes                                                          |
| 数据缓存                                                  | Yes                                                          |
| 数据加密                                                  | Yes(在服务器上通过加密功能实现;在MySQL 5.7及以后版本中，支持静态数据表空间加密。) |
| 外键支持                                                  | Yes                                                          |
| 全文搜索索引                                              | Yes(InnoDB对全文索引的支持在MySQL 5.6和更高版本中是可用的。) |
| 地理空间数据类型支持                                      | Yes(InnoDB对地理空间索引的支持在MySQL 5.7和更高版本中是可用的)。 |
| 地理空间索引支持                                          | Yes                                                          |
| hash索引                                                  | No(InnoDB内部利用哈希索引来实现自适应哈希索引特性。)         |
| 索引缓存                                                  | Yes                                                          |
| 锁粒度                                                    | Row                                                          |
| MVVC                                                      | Yes                                                          |
| 复制支持(在服务器中实现，而不是在存储引擎中实现)。        | Yes                                                          |
| 存储限制                                                  | 64TB                                                         |
| T-tree索引                                                | No                                                           |
| 事务                                                      | Yes                                                          |
| 更新数据字典的统计信息                                    | Yes                                                          |

要比较InnoDB和MySQL提供的其他存储引擎的特性，请参阅第16章“可选的存储引擎”中的存储引擎特性表。

#### InnoDB增强和新特性

有关InnoDB增强和新特性的信息，请参阅：

* 在1.4节“MySQL 8.0的新特性”中列出了InnoDB的增强列表。
* 发行说明。

#### 额外的InnoDB信息和资源

* 有关innodb相关术语和定义，请参阅MySQL术语表
* 关于InnoDB存储引擎的论坛，请参阅 [MySQL Forums::InnoDB](http://forums.mysql.com/list.php?22).
* InnoDB是在与MySQL相同的GNU GPL许可版本2(1991年6月)下发布的。有关MySQL许可的更多信息，请参见http://www.mysql.com/company/legal/licensing/。

### 15.1.1 使用InnoDB表的好处

你可能会发现InnoDB表很有用，原因如下：

* 如果服务器因为硬件或软件问题而崩溃，无论当时数据库中发生了什么，在重新启动数据库后都不需要做任何特殊操作。InnoDB"崩溃恢复（[crash recovery](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_crash_recovery)）"自动恢复崩溃前提交的所有更改，并撤销所有正在进行但未提交的更改。只需要重启然后在你停止的地方继续操作
* InnoDB存储引擎有自己的缓冲池（ [buffer pool](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_buffer_pool)），在访问数据时可以在主存中缓存表和索引数据。经常使用的数据直接在内存中处理。此缓存适用于许多类型的信息，能够加快处理速度。在专用数据库服务器上，通常会将高达80%的物理内存分配给缓冲池
* 如果将相关数据分割到不同的表中，则可以设置执行参照完整性（[referential integrity](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_referential_integrity)）的外键。更新或删除数据，其他表中的相关数据将自动更新或删除。如果尝试将数据插入到一个辅助表中，而主表中没有相应的数据，那么错误的数据将自动被踢出
* 如果磁盘或内存中的数据损坏，在使用伪数据之前，校验和机制会向您发出警告
* 当您为每个表使用适当的主键列设计数据库时，涉及这些列的操作将自动优化。在WHERE子句、ORDER BY子句、GROUP BY子句和join操作中引用主键列非常快。
* 插入、更新和删除由一种称为更改缓冲（[change buffering](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_change_buffering)）的自动机制进行优化。InnoDB不仅允许对同一个表并发读写访问，它还缓存修改后的数据以简化磁盘I/O。
* 性能优势不仅限于具有长时间运行的查询的巨型表。当从一个表中一次又一次地访问相同的行时，一种称为自适应哈希索引（[Adaptive Hash Index](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_adaptive_hash_index)）的特性会启用，从而使这些查找更快，就好像它们是从哈希表中出来的一样
* 您可以压缩表和关联的索引
* 您可以创建和删除索引，而对性能和可用性的影响要小得多
* 截断（Truncating ）一个（[file-per-table](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_file_per_table) ）表空间文件非常快，可以释放磁盘空间供操作系统重用，而不是释放只有InnoDB才能重用的系统表空间内的空间
* 对于BLOB和长文本字段，使用动态（[DYNAMIC](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_dynamic_row_format) ）**行格式**的表数据存储布局更有效
* 您可以通过查询 [INFORMATION_SCHEMA](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_information_schema)表来监视存储引擎的内部工作
* 您可以通过查询 [Performance Schema](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_performance_schema) 表来监视存储引擎的性能细节
* 你可以自由地将InnoDB表与其他MySQL存储引擎的表混合，甚至在同一条语句中。例如，您可以使用连接操作在一个查询中合并来自InnoDB和[`MEMORY`](https://dev.mysql.com/doc/refman/8.0/en/memory-storage-engine.html)表的数据。
* InnoDB是为处理大数据量时的CPU效率和最高性能而设计的
* InnoDB表可以处理大量数据，即使是在文件大小限制在2GB的操作系统上

对于可以在应用程序代码中应用的InnoDB特定调优技术，请参阅8.5节“[InnoDB表调优](https://dev.mysql.com/doc/refman/8.0/en/optimizing-innodb.html)”。

### 15.1.2 InnoDB表的最佳实践

本节描述使用InnoDB表的最佳实践

* 使用最频繁查询的一列或几列为每个表指定一个主键，如果没有明显的主键，则指定一个自动递增（[auto-increment](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_auto_increment)）的值
* 从多个表中根据相同的ID值提取数据时使用连接join。为了加快连接join的性能，可以在连接列上定义外键，并在每个表中使用相同的数据类型声明这些列。添加外键可以确保引用的列被索引，这可以提高性能。外键还将删除或更新传播到所有受影响的表，并防止在父表中没有对应id的情况下在子表中插入数据
* 关闭自动提交。每秒提交数百次会影响性能(受存储设备的写入速度限制)
* 通过使用`START TRANSACTION`和`COMMIT`语句将相关的[DML](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_dml)操作集分组到事务中。虽然您不想过于频繁地提交，但也不想发出大量的INSERT、UPDATE或DELETE语句，这些语句在没有提交的情况下运行数小时
* 如果没有使用锁表（[`LOCK TABLES`](https://dev.mysql.com/doc/refman/8.0/en/lock-tables.html)）语句，InnoDB可以同时处理对同一个表进行读写的多个会话，而不会牺牲可靠性和高性能。要获得对一些行的独占写访问，请使用 [`SELECT ... FOR UPDATE`](https://dev.mysql.com/doc/refman/8.0/en/innodb-locking-reads.html)语法只会去锁定需要更新的行
* 启用[`innodb_file_per_table`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_file_per_table)选项，或者使用常规表空间将表的数据和索引放在单独的文件中，而不是系统表空间中。`innodb_file_per_table`选项是默认启用的。
* 评估你的数据和访问模式是否受益于InnoDB表或页面压缩（[compression](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_compression)）特性。你可以压缩InnoDB表而不牺牲读/写能力
* 使用选项[`--sql_mode=NO_ENGINE_SUBSTITUTION`](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_sql_mode)运行服务器，以防止在创建表的子句中指定的引擎（engine =）出现问题时使用不同的存储引擎创建表。

### 15.1.3 验证InnoDB是否是默认的存储引擎

执行 [`SHOW ENGINES`](https://dev.mysql.com/doc/refman/8.0/en/show-engines.html) 语句来查看可用的MySQL存储引擎。在InnoDB行中查找默认值

```sql
mysql> SHOW ENGINES;
```

或者，查询`INFORMATION_SCHEMA.ENGINES`表：

```sql
mysql> SELECT * FROM INFORMATION_SCHEMA.ENGINES;
```

### 15.1.4 使用InnoDB进行测试和基准测试

如果InnoDB不是你的默认存储引擎，你可以在命令行添加[`--default-storage-engine=InnoDB`](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_storage_engine)或者在mysql服务的配置文件中的[mysqld]下配置[`--default-storage-engine=InnoDB`](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_storage_engine)来指定默认存储引擎。

由于更改默认存储引擎只会在新表创建时生效，所以请运行所有应用程序安装和设置步骤，以确认所有内容都正确安装了。然后练习所有应用程序特性，以确保所有数据加载、编辑和查询特性都能正常工作。如果一个表依赖于另一个存储引擎的特性，您将收到一个错误;将ENGINE=*`other_engine_name`*子句添加到`CREATE TABLE`语句以避免错误

如果你没有深思熟虑的决定存储引擎，你想预览某些表使用InnoDB是如何工作时，为每个表执行命令`ALTER TABLE table_name engine =InnoDB;`。或者为了运行测试查询和其他语句而不影响原始表，可以复制：

```sql
CREATE TABLE InnoDB_Table (...) ENGINE=InnoDB AS SELECT * FROM other_engine_table;
```

要在实际工作负载下评估完整应用程序的性能，请安装最新的MySQL服务器并运行基准测试。

测试整个应用程序生命周期，从安装到大量使用，再到服务器重启。在数据库繁忙时终止服务器进程以模拟电源故障，并在重启服务器时验证数据已成功恢复。

测试任何复制配置，特别是在主库和从库上使用不同MySQL版本和选项的情况下。

## 15.2 InnoDB和ACID模型

ACID模型是一套数据库设计原则，它强调了可靠性，这对业务数据和关键任务应用程序很重要的。MySQL包含了像InnoDB这样的组件，它严格遵循ACID模型，因此数据不会被破坏，结果也不会被异常情况(如软件崩溃和硬件故障)扭曲。当您依赖于acid兼容的特性时，您不需要重新发明一致性检查和崩溃恢复机制。如果你有额外的软件保护，超可靠的硬件，或者可以容忍少量数据丢失或不一致的应用程序，你可以调整MySQL的设置，以牺牲一些ACID可靠性来获得更好的性能或吞吐量。

以下章节将讨论MySQL功能，特别是InnoDB存储引擎，如何与ACID模型的类别交互:

* **A**: atomicity（原子性）.
* **C**: consistency（一致性）.
* **I:**: isolation（隔离性）.
* **D**: durability（持久性）.

### 原子性

ACID模型的原子性方面主要涉及InnoDB[事务](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_transaction)。相关的MySQL特性包括：

* 自动提交设置
* 提交（[`COMMIT`](https://dev.mysql.com/doc/refman/8.0/en/commit.html)）语句
* 回滚（[`ROLLBACK`](https://dev.mysql.com/doc/refman/8.0/en/commit.html) ）语句
* 来自`INFORMATION_SCHEMA`表的操作数据

### 一致性

ACID模型的一致性方面主要涉及内部InnoDB处理，以防止数据崩溃。相关的MySQL特性包括：

* `InnoDB` [doublewrite buffer](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_doublewrite_buffer)
* `InnoDB` [crash recovery](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_crash_recovery)

### 隔离性

ACID模型的隔离方面主要涉及InnoDB事务，特别是应用于每个事务的隔离级别。相关的MySQL特性包括：

* [自动提交](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_autocommit)设置
* `SET ISOLATION LEVEL` statement.
* InnoDB[锁](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_locking)的底层细节。在性能调优期间，您可以通过`INFORMATION_SCHEMA`表查看这些详细信息

### 持久性

ACID模型的持久性涉及到MySQL软件特性与特定硬件配置的交互。由于CPU、网络和存储设备的能力有很多不同的可能性，因此这个方面是最复杂的，难以提供具体的指导原则。(这些指导方针可能采取购买“新硬件”的形式。)相关的MySQL特性包括：

* InnoDB[doublewrite buffer](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_doublewrite_buffer)，由[`innodb_doublewrite`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_doublewrite) 配置选项开启和关闭
* 配置选项： [`innodb_flush_log_at_trx_commit`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit)
* 配置选项：[`sync_binlog`](https://dev.mysql.com/doc/refman/8.0/en/replication-options-binary-log.html#sysvar_sync_binlog)
* 配置选项：[`innodb_file_per_table`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_file_per_table)
* 在存储设备(如磁盘驱动器、SSD或RAID阵列)中写入缓冲区
* 存储设备中的缓存Battery-backed
* 用于运行MySQL的操作系统，特别是它对`fsync()`系统调用的支持
* 不间断电源(UPS)保护运行MySQL服务器和存储MySQL数据的所有计算机服务器和存储设备的电力。
* 备份策略，例如备份的频率和类型以及备份保留时间
* 对于分布式或托管的数据应用程序，MySQL服务器硬件所在的数据中心的特殊特征，以及数据中心之间的网络连接

## 15.3 InnoDB多版本并发控制

InnoDB是一个多版本存储引擎（[multi-versioned storage engine](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_mvcc)）:它保存了更改行的旧版本信息，以支持并发和回滚等事务特性。这个信息存储在表空间中一个称为回滚段（ [rollback segment](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_rollback_segment) ）的数据结构中(在Oracle中类似的数据结构之后)。InnoDB使用回滚段中的信息来执行事务回滚所需的撤销操作。它还使用这些信息构建行的早期版本，以实现一致的读取。

InnoDB在内部为数据库中存储的每一行添加3个字段。一个6字节的`DB_TRX_ID`字段表示插入或更新行的最后一个事务的事务标识符。此外，删除在内部被视为更新，其中行中的一个特殊位被设置为已删除。每一行还包含一个被叫做回滚指针的字段`DB_ROLL_PTR`，占7字节。回滚指针指向写入回滚段的undo log record。如果该行已更新，那么一条undo log record将包含更新前的一些信息，这些信息用于回滚该行的内容。一个6字节的`DB_ROW_ID`字段包含一个行ID，该行ID在插入新行时单调递增。如果InnoDB自动生成聚集索引（言外之意：新建表的时候没有设置主键？），该索引包含行ID值。否则，`DB_ROW_ID`列不会出现在任何索引中

回滚段中的undo log分为插入undo logs和更新undo logs。只有在事务回滚时才需要插入undo logs，可以在事务提交后立即丢弃。更新undo logs也用于保证读取一致性,但它们只能在innoDB中被标记的数据快照没有事务的时候被丢弃，这个快照中存储了用于重建之前数据版本的一些信息，这个快照的作用是保证一致性读取数据。

定期提交事务，包括那些只发出一致读取的事务。否则，InnoDB无法丢弃更新undo日志中的数据，并且回滚段可能会变得太大，填满表空间。

回滚段中的undo日志记录的物理大小通常小于相应的插入或更新行。您可以使用这些信息计算回滚段所需的空间。

在InnoDB多版本模式中，当你用SQL语句删除某一行时，它不会立即从数据库中物理删除。InnoDB只在删除更新undo日志记录时物理地删除相应的行及其索引记录。这种删除操作称为清除操作（[purge](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_purge)），而且速度非常快，通常所花费的时间与执行删除操作的SQL语句相同。

如果在表中以相同的速度以较小的批插入和删除行，那么清除线程就会开始滞后，并且由于所有的“dead”行，表可能会变得越来越大，从而使所有内容都绑定到磁盘上，并且非常慢。在这种情况下，通过调优 [`innodb_max_purge_lag`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_max_purge_lag) 系统变量来控制新的行操作，并为清除线程分配更多的资源。更多信息请参见15.14节“InnoDB启动选项和系统变量”

### 多版本化和二级索引

InnoDB多版本并发控制(MVCC)处理二级索引与聚集索引不同。聚集索引中的记录被立即更新，并将它们隐藏的系统字段指向undo log entries ，可以从这些条目重建早期版本的记录。与聚集索引记录不同，辅助索引记录不包含隐藏的系统列，也不立即更新。

在更新二级索引（辅助索引）列时，旧的辅助索引记录被标记为删除，插入新记录，并最终清除删除标记的记录。当二级索引记录被删除标记或二级索引页被更新的事务更新时，InnoDB在聚集索引中查找数据库记录。在聚集索引中，检查记录的`DB_TRX_ID`，如果在读取事务开始后对记录进行了修改，则从undo log日志中检索记录的正确版本。（个人理解：参看二级索引 ）。

如果二级索引记录被标记为删除，或者二级索引页被较新的事务更新，则不使用覆盖索引（[covering index](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_covering_index) ）技术，InnoDB不会从索引中返回查询值，而是在聚集索引中查找记录。

但是，如果启用了索引条件下推(ICP)（[index condition pushdown](https://dev.mysql.com/doc/refman/8.0/en/index-condition-pushdown-optimization.html)）优化，并且可以仅使用索引中的字段来计算部分WHERE条件，那么MySQL服务器仍然将这部分WHERE条件下推到存储引擎中，在存储引擎中使用索引来计算。如果没有找到匹配的记录，将避免聚集索引查找。如果找到了匹配的记录，即使是在删除标记的记录中，InnoDB也会在聚集索引中查找该记录

> 个人理解：
>
> 删除数据：
>
> 有2个事务，事务1先执行了查询了数据a，并没有提交事务，然后事务2执行了删除数据a，并提交了事务。那么数据a不会立即被删除，要等到事务1提交之后，update undo log没有用了，会删除update undo log，然后才会删除相关的数据及其索引记录。
>
> 一致性读取的维护：
>
> 事务101更新了数据a，事务100获取数据a，发现数据a的事务id > 当前事务id的值，那么为了维护一致性读取，从update undo log中获取数据a的之前的版本。
>
> 数据的更新：
>
> 如果事务100更新了数据a：
>
>  * 插入update undo log
>  * 更新数据a的数据块，`DB_ROLL_PTR`指向undo log record
>
> 二级索引:
>
> 如果二级索引被更新了，还没更新完成，那么新来的数据查询不会走二级索引，也不会使用到覆盖索引技术。
>
> 索引下推：
>
> 在建立了联合索引的前提下（name, age），我们在查询 `name like 'hello%’and age >10 `，name使用索引过滤出匹配的值，然后age>10也在索引中进行判断，避免了先根据name找到name like ‘hello'的记录，然后去聚集索引中找到相应的记录，再过滤出age>10的记录。从而将服务端计算age>10的操作，下放到存储引擎来计算，达到索引下推。

## 15.4 InnoDB架构

下图显示了包含InnoDB存储引擎架构的内存和磁盘结构。有关每个结构的信息。参见15.5节“InnoDB在内存中的结构”和15.6节“InnoDB在磁盘上的结构”。

图15.1 InnoDB架构

![](innodb-architecture.png)

## 15.5 InnoDB内存结构

本节介绍InnoDB内存结构和相关主题

### 15.5.1 Buffer Pool

缓冲池是主存中InnoDB缓存被访问的表和索引数据的区域。缓冲池允许直接从内存中处理经常使用的数据，从而加快处理速度。在专用服务器上，高达80%的物理内存通常分配给缓冲池。

为了提高大容量读操作的效率，缓冲池被划分为可以容纳多行的页（[pages](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_page) ）。为了提高缓存管理的效率，缓冲池被实现为链表结构的page;很少使用的数据使用LRU算法的一种变体从缓存中过期。

了解如何利用缓冲池将经常访问的数据保存在内存中是MySQL调优的一个重要方面。

#### 缓冲池LRU算法

缓冲池是使用最近最少使用(LRU)算法的变体作为列表来管理的。当需要空间向缓冲池添加新页面时，将剔除最近最少使用的页面，并将一个新页面添加到列表的中间。这种中点插入策略将列表视为两个子列表：

* 在顶部是最近访问的新的(“年轻的”)页面的子列表
* 在尾部，最近访问的旧页面的子列表

图15.2缓冲池列表

![](innodb-buffer-pool-list.png)

该算法在新的子列表中保留大量页面。旧的子列表包含较少使用的页面;这些页可能会被剔除（[eviction](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_eviction)）。

默认情况下，算法操作如下：

* 3/8的缓冲池用于旧的子列表。
* 列表的中点是新的子列表的尾部与旧的子列表的头部之间的边界
* 当InnoDB将一个页面读入缓冲池时，它首先将它插入到中间点(旧子列表的头)。一个页面会被读取，当它被用户发起的操作(比如SQL查询)或InnoDB自动执行的预读操作的一部分。
* 访问旧子列表中的页面会使其“年轻”，并将其移动到新子列表的头部。如果页面是由于用户发起的操作需要而读取的，则会立即进行第一次访问，并使页面处于年轻状态。如果由于预读操作读取了该页，那么第一次访问不会立即发生，而且可能在剔除该页之前根本不会发生
* 在数据库操作时，缓冲池中未被访问的页面将移动到列表的尾部。新的和旧的子列表中的页面都是旧的，其他的页面都是新的。当页面插入到中点时，旧子列表中的页面也会变老。最终，未使用的页面到达旧子列表的尾部并被剔除。

默认情况下，通过查询被读取的页面会立即移动到新的子列表中，这意味着它们在缓冲池中停留的时间更长。例如，对[**mysqldump**](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html)操作或不带WHERE条件的SELECT语句执行，会将大量数据带入缓冲池，并驱逐同等数量的旧数据，即使这些执行读取的新数据永远不再使用。类似地，由预读后台线程加载且只访问一次的页面被移动到新列表的头部。这些情况可以将经常使用的页面推到旧的子列表中，在那里它们将被逐出。关于优化这个行为的信息，请参见15.8.3.3节“使缓冲池抵抗扫描”（[Making the Buffer Pool Scan Resistant](https://dev.mysql.com/doc/refman/8.0/en/innodb-performance-midpoint_insertion.html)）和15.8.3.4节“配置InnoDB缓冲池预取(预读)”（[Configuring InnoDB Buffer Pool Prefetching (Read-Ahead)”](https://dev.mysql.com/doc/refman/8.0/en/innodb-performance-read_ahead.html)）。

InnoDB标准的监视器输出包含了缓冲池和内存的几个字段，关于缓冲池LRU算法的操作，有关详细信息，请参见使用InnoDB标准监视器监视缓冲池（[Monitoring the Buffer Pool Using the InnoDB Standard Monitor](https://dev.mysql.com/doc/refman/8.0/en/innodb-buffer-pool.html#innodb-buffer-pool-monitoring)）。

#### 缓冲池配置

您可以配置缓冲池的各个方面来提高性能：

* 理想情况下，可以将缓冲池的大小设置为尽可能大的值，从而为服务器上的其他进程留下足够的内存，以便在不发生过度分页的情况下运行。缓冲池越大，InnoDB就越像一个内存中的数据库，从磁盘读取一次数据，然后在随后的读取过程中从内存中访问数据。参见15.8.3.1节“配置InnoDB缓冲池大小”。
* 在具有足够内存的64位系统上，可以将缓冲池分割为多个部分，以最大限度地减少并发操作之间对内存结构的争用。详情请参阅15.8.3.2节“配置多个缓冲池实例”。
* 您可以将经常访问的数据保存在内存中，而不考虑将大量不经常访问的数据带入缓冲池的操作导致的活动突然激增。详情请参阅15.8.3.3节“使缓冲池抗扫描”。
* 您可以控制何时以及如何执行预读请求，以异步地将页面预取到缓冲池中，以预期这些页面将很快被需要。详情请参阅15.8.3.4节“配置InnoDB缓冲池预取(预读)”。
* 您可以控制何时发生后台刷新，以及是否根据工作负载动态调整刷新速率。详情请参阅15.8.3.5节“配置缓冲池刷新”。
* 您可以配置InnoDB如何保存当前的缓冲池状态，以避免服务器重启后的长时间预热。详情请参阅15.8.3.6节“保存和恢复缓冲池状态”。

#### 使用InnoDB标准监视器监视缓冲池

InnoDB标准监视器输出，可以使用[`SHOW ENGINE INNODB STATUS`](https://dev.mysql.com/doc/refman/8.0/en/innodb-standard-monitor.html),访问，提供了关于缓冲池操作的指标。缓冲池指标位于InnoDB标准监视器输出的缓冲池和内存部分，看起来类似如下:

```mysql
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 2198863872
Dictionary memory allocated 776332
Buffer pool size   131072
Free buffers       124908
Database pages     5720
Old database pages 2071
Modified db pages  910
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 4, not young 0
0.10 youngs/s, 0.00 non-youngs/s
Pages read 197, created 5523, written 5060
0.00 reads/s, 190.89 creates/s, 244.94 writes/s
Buffer pool hit rate 1000 / 1000, young-making rate 0 / 1000 not
0 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read
ahead 0.00/s
LRU len: 5720, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
```

下表描述了InnoDB标准监视器报告的缓冲池指标。

>注意：
>
>在InnoDB标准监视器输出中提供的每秒平均值是基于InnoDB标准监视器输出上一次一次打印后所经过的时间。

表15.2 InnoDB缓冲池指标：

| Name                         | Description                                                  |
| ---------------------------- | ------------------------------------------------------------ |
| Total memory allocated       | 分配给缓冲池的总内存，单位：字节。                           |
| Dictionary memory allocated  | 分配给InnoDB数据字典的总内存，单位：字节。                   |
| Buffer pool size             | 分配给缓冲池的页的总大小。                                   |
| Free buffers                 | 缓冲池空闲列表中页的总大小。                                 |
| Database pages               | 缓冲池LRU列表中的页的总大小。                                |
| Old database pages           | 缓冲池旧LRU子列表中的页的总大小。                            |
| Modified db pages            | 缓冲池中当前修改的页数                                       |
| Pending reads                | 等待读入缓冲池的缓冲池页数。                                 |
| Pending writes LRU           | The number of old dirty pages within the buffer pool to be written from the bottom of the LRU list. |
| Pending writes flush list    | The number of buffer pool pages to be flushed during checkpointing. |
| Pending writes single page   | 缓冲池中挂起的独立页写的数量                                 |
| Pages made young             | 缓冲池LRU列表中变为年轻的页面总数(移动到“new”页面子列表的头部)。 |
| Pages made not young         | The total number of pages not made young in the buffer pool LRU list (pages that have remained in the “old” sublist without being made young). |
| youngs/s                     | The per second average of accesses to old pages in the buffer pool LRU list that have resulted in making pages young. See the notes that follow this table for more information. |
| non-youngs/s                 | The per second average of accesses to old pages in the buffer pool LRU list that have resulted in not making pages young. See the notes that follow this table for more information. |
| Pages read                   | The total number of pages read from the buffer pool.         |
| Pages created                | The total number of pages created within the buffer pool.    |
| Pages written                | The total number of pages written from the buffer pool.      |
| reads/s                      | The per second average number of buffer pool page reads per second. |
| creates/s                    | The per second average number of buffer pool pages created per second. |
| writes/s                     | The per second average number of buffer pool page writes per second. |
| Buffer pool hit rate         | The buffer pool page hit rate for pages read from the buffer pool memory vs from disk storage. |
| young-making rate            | The average hit rate at which page accesses have resulted in making pages young. See the notes that follow this table for more information. |
| not (young-making rate)      | The average hit rate at which page accesses have not resulted in making pages young. See the notes that follow this table for more information. |
| Pages read ahead             | The per second average of read ahead operations.             |
| Pages evicted without access | The per second average of the pages evicted without being accessed from the buffer pool. |
| Random read ahead            | The per second average of random read ahead operations.      |
| LRU len                      | The total size in pages of the buffer pool LRU list.         |
| unzip_LRU len                | The total size in pages of the buffer pool unzip_LRU list.   |
| I/O sum                      | The total number of buffer pool LRU list pages accessed, for the last 50 seconds. |
| I/O cur                      | The total number of buffer pool LRU list pages accessed.     |
| I/O unzip sum                | The total number of buffer pool unzip_LRU list pages accessed. |
| I/O unzip cur                | The total number of buffer pool unzip_LRU list pages accessed. |

注意：

* 指标`youngs/s`仅适用于旧页面。它基于对页面的访问数量，而不是页面数量。对一个给定页面可以有多次访问，所有访问都被计数。如果在没有发生大型扫描时看到非常低的`youngs/s`值，那么可能需要减少延迟时间，或者增加用于旧子列表的缓冲池的百分比。增加百分比会使旧的子列表更大，因此该子列表中的页面移动到尾部需要更长的时间，这就增加了这些页面再次被访问并变得年轻的可能性。
* 指标`non-youngs/s`仅适用于旧页面。它基于对页面的访问数量，而不是页面数量。对一个给定页面可以有多次访问，所有访问都被计数。如果在执行大型表扫描时没有看到较高的`non-youngs/s`值(和较高的`young /s`值)，则增加延迟值。
* `young-making`速率涉及对所有缓冲池页面的访问，而不仅仅是对旧子列表中的页面的访问。`young-making`和未生成率通常不等于总体缓冲池命中率。旧子列表中的页面点击会导致页面移动到新的子列表中，但是新子列表中的页面点击只会导致页面移动到列表的头部，前提是这些页面与头部之间有一定的距离
* 不是(young-making率)的平均命中率页面访问并没有导致使页面年轻由于[`innodb_old_blocks_time`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_old_blocks_time) 没有被定义的延迟满足,或者由于新子列表页面点击没有导致页面被搬到了头。这个速率用于访问所有缓冲池页面，而不仅仅是访问旧子列表中的页面。

缓冲池服务器状态变量和`INNODB_BUFFER_POOL_STATS`表提供了许多与InnoDB标准监视器输出相同的缓冲池指标。有关更多信息，请参见示例15.10“查询`INNODB_BUFFER_POOL_STATS`表”。

### 15.5.2 Change Buffer

修改缓冲区是一种特殊的数据结构，用来缓存没有在buffer pool中的二级索引页的修改。这些更改可能来自insert、delete、update操作（DML），change buffer中的数据会被合并到buffer pool中去当有其它的读取操作读取时。

图15.3修改缓冲区

![](innodb-change-buffer.png)

与聚集索引不同，辅助索引通常不是唯一的，插入到辅助索引中的顺序相对随机。类似地，删除和更新可能会影响二级索引页。当其他操作将受影响的页读入缓冲池时，在稍后合并缓存的更改，可以避免将辅助索引页从磁盘读入缓冲池所需的大量随机访问I/O。

当系统大部分时间处于空闲状态时或在缓慢关闭（slow shutdown，关机的时候）期间，清除操作会将更新后的索引页写入磁盘。与将每个值立即写入磁盘相比，清除操作可以更有效地写入一系列索引值的磁盘块。

当有许多受影响的行和大量二级索引需要更新时，更改缓冲区合并可能需要几个小时。在此期间，磁盘I/O会增加，这可能导致磁盘绑定查询的速度显著减慢。更改缓冲区合并也可能在事务提交后继续发生，甚至在服务器关闭和重新启动之后(参见15.21.2节，“强制InnoDB恢复”更多信息)。

在内存中，更改缓冲区占用了缓冲池的一部分。在磁盘上，更改缓冲区是system表空间的一部分，当数据库服务器关闭时，修改的缓存将在磁盘上存储。

在修改缓冲区中的数据类型由[`innodb_change_buffering`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_change_buffering)变量控制。有关更多信息，请参见配置更改缓冲。您还可以配置最大修改缓冲区大小。有关更多信息，请参见配置更改缓冲区的最大大小。

如果辅助索引包含降序索引列，或者主键包含降序索引列，则不支持更改缓冲

关于更改缓冲区的常见问题，请参阅A.16，“MySQL 8.0 FAQ: InnoDB更改缓冲区”。

#### 配置change buffer

在表上执行插入、更新和删除操作时，索引列的值(特别是辅助键的值)通常是无序的，需要大量的I/O来使辅助索引来保持最新。当相关的二级索引页不在缓冲池中时，对它的修改将被缓存到change buffer，因此不必立即从磁盘读取页，从而避免了昂贵的I/O操作。当页面加载到缓冲池中时，缓冲的更改将被合并，更新后的页面稍后将刷新到磁盘。InnoDB的主线程在服务器接近空闲时和慢速关机时合并缓冲变化。

因为它可以减少磁盘读写，所以change buffer的特性对于I/ o限制的工作负载最有价值，例如具有大量DML操作(如批量插入)的应用程序。

但是，更改缓冲区占用了缓冲池的一部分，减少了用于缓存数据页的可用内存。如果工作集几乎发生在buffer pool，或者如果表的二级索引相对较少，那么禁用change buffer可能会很有用。如果工作数据集完全在缓冲池，则change buffer不会带来额外的开销，因为它只适用于不在缓冲池中的页面。

您可以使用`innodb_change_buffering`配置参数来控制InnoDB使用change buffer的程度。您可以启用或禁用insert、delete操作(当索引记录最初被标记为删除时)和purge操作(当索引记录被物理删除时)的缓冲。更新操作是插入操作和删除操作的组合。默认的`innodb_change_buffering`值是all。

允许innodb_change_buffering值包括:

* all：默认值:缓冲区插入、删除标记操作和清除。
* none：不缓冲任何操作
* **`inserts`**：缓冲插入操作
* **`changes`**：缓冲插入和删除标记操作
* **`purges`**：缓冲在后台发生的物理删除操作

可以在MySQL选项文件(my.cnf或my.ini)中设置innodb_change_buffering参数，也可以使用set GLOBAL语句动态地修改它，这需要足够的权限来设置全局系统变量。参见5.1.9.1节“系统可变权限”。改变设置会影响新操作的缓冲;现有缓冲项的合并不受影响

#### 配置change buffer的最大大小

`innodb_change_buffer_max_size`变量允许将更改缓冲区的最大大小配置为缓冲池总大小的百分比。默认情况下，`innodb_change_buffer_max_size`设置为25。最大设置为50。

考虑增加`innodb_change_buffer_max_size`在一个有大量插入、更新和删除活动的MySQL服务器上，其中更改缓冲区合并跟不上新的更改缓冲区条目，导致更改缓冲区达到其最大大小限制。

考虑减小`innodb_change_buffer_max_size`的值，当mysql服务上的数据是用于报表的静态数据的时候，或者如果change buffer消耗了太多的buffer pool共享的内存空间，导致页面比预期更快地从缓冲池中老化。

使用具有代表性的工作负载测试不同的设置，以确定最佳配置。`innodb_change_buffer_max_size`的设置是动态的，允许在不重启服务器的情况下进行修改。

#### 监控change buffer

以下选项可用于更改缓冲区监视：

* InnoDB标准监视器输出包括有change buffer的状态信息。要查看监视器数据，执行`SHOW ENGINE INNODB STATUS`。

  ```mysql
  mysql> SHOW ENGINE INNODB STATUS\G
  ```

  改变缓冲区状态信息位于`INSERT BUFFER`和`ADAPTIVE HASH INDEX`（自适应哈希索引）标题下，类似如下:

  ```mysql
  -------------------------------------
  INSERT BUFFER AND ADAPTIVE HASH INDEX
  -------------------------------------
  Ibuf: size 1, free list len 0, seg size 2, 0 merges
  merged operations:
   insert 0, delete mark 0, delete 0
  discarded operations:
   insert 0, delete mark 0, delete 0
  Hash table size 4425293, used cells 32, node heap has 1 buffer(s)
  13577.57 hash searches/s, 202.47 non-hash searches/s
  ```

  更多信息，见15.17.3节，“InnoDB标准监视器和锁定监视器输出”。

* `INFORMATION_SCHEMA.INNODB_METRICS`表提供了InnoDB标准监视器输出中的大部分数据指标，以及其他数据点。要查看change buffer的指标及其描述，执行以下查询:

  ```mysql
  mysql> SELECT NAME, COMMENT FROM INFORMATION_SCHEMA.INNODB_METRICS WHERE NAME LIKE '%ibuf%'\G
  ```

  关于`INNODB_METRICS`表的使用信息，请参见15.15.6节“InnoDB INFORMATION_SCHEMA Metrics表”。

* `INFORMATION_SCHEMA.INNODB_BUFFER_PAGE`表提供了关于缓冲池中每个页面的元数据，包括更改缓冲区索引和更改缓冲区bitmap页面。更改缓冲区页面由`PAGE_TYPE`. `IBUF_INDEX`标志，是用于更改缓冲区索引页的页面类型，`IBUF_BITMAP`是用于更改缓冲区bitmap页的页面类型。

  > 警告：
  >
  > 查询`INNODB_BUFFER_PAGE`表会带来显著的性能开销。为避免影响性能，请在测试实例上重现您想要调查的问题，并在测试实例上运行查询。

  例如，可以查询`INNODB_BUFFER_PAGE`表，以确定`IBUF_INDEX`和`IBUF_BITMAP`页面的大致数量占缓冲池页面总数的百分比。

  ```mysql
  mysql> SELECT (SELECT COUNT(*) FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE
         WHERE PAGE_TYPE LIKE 'IBUF%') AS change_buffer_pages,
         (SELECT COUNT(*) FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE) AS total_pages,
         (SELECT ((change_buffer_pages/total_pages)*100))
         AS change_buffer_page_percentage;
  +---------------------+-------------+-------------------------------+
  | change_buffer_pages | total_pages | change_buffer_page_percentage |
  +---------------------+-------------+-------------------------------+
  |                  25 |        8192 |                        0.3052 |
  +---------------------+-------------+-------------------------------+
  ```

  有关`INNODB_BUFFER_PAGE`表提供的其他数据的信息，请参见25.51.1节“the INFORMATION_SCHEMA INNODB_BUFFER_PAGE表”。相关使用信息，请参见15.15.5节“InnoDB INFORMATION_SCHEMA缓冲池表”。

* [Performance Schema](https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html)为高级性能监视提供了更改缓冲区互斥锁等待检测。要查看change buffer的统计，执行以下查询:

  ```mysql
  mysql> SELECT * FROM performance_schema.setup_instruments
         WHERE NAME LIKE '%wait/synch/mutex/innodb/ibuf%';
  +-------------------------------------------------------+---------+-------+
  | NAME                                                  | ENABLED | TIMED |
  +-------------------------------------------------------+---------+-------+
  | wait/synch/mutex/innodb/ibuf_bitmap_mutex             | YES     | YES   |
  | wait/synch/mutex/innodb/ibuf_mutex                    | YES     | YES   |
  | wait/synch/mutex/innodb/ibuf_pessimistic_insert_mutex | YES     | YES   |
  +-------------------------------------------------------+---------+-------+
  ```

  有关监视InnoDB互斥锁等待的信息，请参见15.16.2节“使用性能模式监视InnoDB互斥锁等待”。

### 15.5.3 自适应哈希索引

当有适当的工作负载且buffer pool有足够的内存的时候，自适应哈希索引使InnoDB更像一个内存数据库，且不会牺牲事务特性或可靠性。自适应哈希索引特性由`innodb_adaptive_hash_index`变量启用，或者在服务器启动时由`--skip-innodb-adaptive-hash-index`关闭。

根据观察到的搜索模式，使用索引键的前缀构建散列索引。前缀可以是任意长度，并且可能只有b树中的某些值出现在哈希索引中。散列索引是根据需要为经常访问的索引页构建的。

如果一个表几乎完全可以放在主内存中，那么哈希索引可以通过直接查找任何元素，将索引值转换为一种指针，从而加快查询速度。InnoDB有一个监控索引搜索的机制。如果InnoDB注意到查询可以从构建哈希索引中获益，它会自动这么做。

在一些工作负载中，哈希索引查找带来的加速远远超过监视索引查找和维护哈希索引结构的额外工作。在繁重的工作负载下，对自适应哈希索引的访问有时会导致竞争，比如多个并发连接。查询语句中使用 `like %`也不会收益。对于不能从自适应哈希索引特性获益的工作负载，关闭它可以减少不必要的性能开销。由于很难预先预测自适应哈希索引特性是否适合特定的系统和工作负载，因此请考虑启用和禁用它来运行基准测试。MySQL 5.6的架构变化使得禁用自适应哈希索引特性比以前的版本更合适。

自适应哈希索引是分区的。每个索引都绑定到一个特定的分区，并且每个分区都由一个单独latch保护。分区由变量`innodb_adaptive_hash_index_parts`控制,变量`innodb_adaptive_hash_index_parts`的默认设置为8，最大为512。

你可以监控自适应哈希的使用和竞争情况，执行[`SHOW ENGINE INNODB STATUS`](https://dev.mysql.com/doc/refman/8.0/en/show-engine.html) 在输出内容的`SEMAPHORE`标题下。如果有许多线程等待在`btr0sea`创建的`RW-latch`上，考虑增加自适应哈希索引分区的数量或禁用自适应哈希索引特性。

有关哈希索引的性能特征的信息，请参见8.3.9节[b树和哈希索引的比较]()。

### 15.5.4 Log Buffer

日志缓存是一个内存区域，用于存储将要写入磁盘上日志文件的数据。日志缓冲区大小由变量`innodb_log_buffer_size`定义，默认大小是16MB。日志缓冲区的内容会定期刷新到磁盘。大型日志缓冲区允许运行大型事务，而无需在事务提交之前将redo log数据写入磁盘。因此，如果事务需要更新、插入或删除许多行，那么增加日志缓冲区的大小可以节省磁盘I/O。

`innodb_flush_log_at_trx_commit`变量控制如何写入和刷新日志缓冲区的内容到磁盘。`innodb_flush_log_at_timeout`变量控制日志刷新频率。

相关信息，请参见内存配置和8.5.4节“优化InnoDB redo log”。

## 15.6 InnoDB磁盘结构

[15.6.1 Tables](https://dev.mysql.com/doc/refman/8.0/en/innodb-tables.html)

[15.6.2 Indexes](https://dev.mysql.com/doc/refman/8.0/en/innodb-indexes.html)

[15.6.3 Tablespaces](https://dev.mysql.com/doc/refman/8.0/en/innodb-tablespace.html)

[15.6.4 Doublewrite Buffer](https://dev.mysql.com/doc/refman/8.0/en/innodb-doublewrite-buffer.html)

[15.6.5 Redo Log](https://dev.mysql.com/doc/refman/8.0/en/innodb-redo-log.html)

[15.6.6 Undo Logs](https://dev.mysql.com/doc/refman/8.0/en/innodb-undo-logs.html)

本节描述InnoDB的磁盘结构和相关主题

#### 15.6.1 表

[15.6.1.1 Creating InnoDB Tables](https://dev.mysql.com/doc/refman/8.0/en/using-innodb-tables.html)

[15.6.1.2 Creating Tables Externally](https://dev.mysql.com/doc/refman/8.0/en/innodb-create-table-external.html)

[15.6.1.3 Importing InnoDB Tables](https://dev.mysql.com/doc/refman/8.0/en/innodb-table-import.html)

[15.6.1.4 Moving or Copying InnoDB Tables](https://dev.mysql.com/doc/refman/8.0/en/innodb-migration.html)

[15.6.1.5 Converting Tables from MyISAM to InnoDB](https://dev.mysql.com/doc/refman/8.0/en/converting-tables-to-innodb.html)

[15.6.1.6 AUTO_INCREMENT Handling in InnoDB](https://dev.mysql.com/doc/refman/8.0/en/innodb-auto-increment-handling.html)

本节涵盖了与InnoDB表相关的主题。

##### 15.6.1.1 创建InnoDB表

要创建一个InnoDB表，使用`create table`语句。

```mysql
CREATE TABLE t1 (a INT, b CHAR (20), PRIMARY KEY (a)) ENGINE=InnoDB;
```

如果InnoDB被定义为默认存储引擎，你不需要指定`ENGINE=InnoDB`子句，因为它是默认的。要检查默认存储引擎，执行以下语句:

```mysql
mysql> SELECT @@default_storage_engine;
+--------------------------+
| @@default_storage_engine |
+--------------------------+
| InnoDB                   |
+--------------------------+
```

如果您计划使用`mysqldump`或`replication`在默认存储引擎不是InnoDB的服务器上重新执行`CREATE TABLE`语句，您可能仍然需要使用`ENGINE=InnoDB`子句。

InnoDB表及其索引可以在[system tablespace](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_system_tablespace)(系统表空间)中创建，也可以在[file-per-table](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_file_per_table)中创建，也可以在[general tablespace](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_general_tablespace)（普通表空间）中创建。当`innodb_file_per_table`被启用时(这是默认的)，一个InnoDB表将隐式地创建在file-per-table表空间中。相反，当`innodb_file_per_table`被禁用时，InnoDB表会隐式地在InnoDB系统表空间中创建。要在普通表空间中创建表，请使用[`CREATE TABLE ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/create-table.html)的语法。更多信息，请参见15.6.3.3节“普通表空间”。

当你在`file-per-table`表空间中创建表时，MySQL在MySQL数据文件夹下的数据库文件夹中创建`.ibd`表空间文件。在InnoDB系统表空间中创建的表是在现有的`ibdata`文件中创建的，该文件位于MySQL数据文件夹中。在常规表空间中创建的表是在现有的常规表空间.ibd文件中创建的。一般的表空间文件可以在MySQL数据目录内部或外部创建。更多信息，请参见15.6.3.3节“一般表空间”。

InnoDB在内部为每个表添加一个条目到数据字典中。条目包括数据库名称。例如，如果表t1是在测test数据库中创建的，那么数据库名称的数据字典条目是`test/t1`。这意味着您可以在不同的数据库中创建同名表(t1)，并且在InnoDB中表名不会发生冲突。

**InnoDB表和行格式**

InnoDB表的默认行格式是由`innodb_default_row_format`配置选项定义的，它的默认值是`DYNAMIC`。[Dynamic](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_dynamic_row_format)和`Compressed`行格式允许您利用InnoDB的特性的优点，比如表压缩和大字段值的高效离线存储。要使用这些行格式，必须启用`innodb_file_per_table`(默认)。

```mysql
SET GLOBAL innodb_file_per_table=1;
CREATE TABLE t3 (a INT, b CHAR (20), PRIMARY KEY (a)) ROW_FORMAT=DYNAMIC;
CREATE TABLE t4 (a INT, b CHAR (20), PRIMARY KEY (a)) ROW_FORMAT=COMPRESSED;
```

或者，您可以使用 [`CREATE TABLE ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/create-table.html) 语法创建一个InnoDB表在一般表空间。一般的表空间支持所有的行格式。更多信息，请参见15.6.3.3节“一般表空间”。

```mysql
CREATE TABLE t1 (c1 INT PRIMARY KEY) TABLESPACE ts1 ROW_FORMAT=DYNAMIC;
```

[`CREATE TABLE ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/create-table.html) 语法还可以用于在系统表空间中创建具有动态行格式的InnoDB表，以及具有紧凑或冗余行格式的表。

```mysql
CREATE TABLE t1 (c1 INT PRIMARY KEY) TABLESPACE = innodb_system ROW_FORMAT=DYNAMIC;
```

更多关于InnoDB行格式的信息，参见15.10节“InnoDB行格式”。关于如何确定一个InnoDB表的行格式和InnoDB行格式的物理特性，参见15.10节“InnoDB行格式”。

**InnoDB表和主键**

总是为InnoDB表定义一个主键，指定一个或多个列:

* 被最重要的查询引用。
* 永远不会为空
* 永远不要有重复的值
* 插入后很少改变值。

例如，在包含有关人员信息的表中，您将不会在(firstname, lastname)上创建主键，因为不止一个人可以拥有相同的名字，有些人的姓氏是空的，有时人们会更改他们的名字。由于存在如此多的约束，通常没有一组明显的列可以用作主键，因此您需要创建一个具有数字ID的新列作为主键的全部或部分。您可以声明一个自动递增的列，以便在插入行时自动填充升序值:

```mysql
# The value of ID can act like a pointer between related items in different tables.
CREATE TABLE t5 (id INT AUTO_INCREMENT, b CHAR (20), PRIMARY KEY (id));

# The primary key can consist of more than one column. Any autoinc column must come first.
CREATE TABLE t6 (id INT AUTO_INCREMENT, a INT, b CHAR (20), PRIMARY KEY (id,a));
```

尽管表在不定义主键的情况下可以正常工作，但主键涉及性能的许多方面，并且对于任何大型或经常使用的表来说，它都是一个至关重要的设计方面。建议始终在CREATE TABLE语句中指定主键。如果创建表、加载数据，然后运行ALTER table以后添加主键，则该操作比创建表时定义主键要慢得多。

**查看InnoDB表属性**

查看innodb表的属性，执行[`SHOW TABLE STATUS`](https://dev.mysql.com/doc/refman/8.0/en/show-table-status.html)语句：

```mysql
mysql> SHOW TABLE STATUS FROM test LIKE 't%' \G;
*************************** 1. row ***************************
           Name: t1
         Engine: InnoDB
        Version: 10
     Row_format: Compact
           Rows: 0
 Avg_row_length: 0
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2015-03-16 15:13:31
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_0900_ai_ci
       Checksum: NULL
 Create_options:
        Comment:
```

有关显示表状态输出的信息，请参见13.7.7.36节“显示表状态语句”。

InnoDB表属性也可以用InnoDB Information Schema表查询:

```mysql
mysql> SELECT * FROM INFORMATION_SCHEMA.INNODB_TABLES WHERE NAME='test/t1' \G
*************************** 1. row ***************************
     TABLE_ID: 45
         NAME: test/t1
         FLAG: 1
       N_COLS: 5
        SPACE: 35
   ROW_FORMAT: Compact
ZIP_PAGE_SIZE: 0
   SPACE_TYPE: Single
```

更多信息，参见15.15.3节“InnoDB INFORMATION_SCHEMA Schema对象表”。

##### 15.6.1.2 创建外部表

从外部创建InnoDB表有不同的原因;也就是说，在数据目录之外创建表。例如，这些原因可能包括空间管理、I/O优化或将表放置在具有特定性能或容量特征的存储设备上。

InnoDB支持以下方法创建外部表:

* 使用DATA DIRECTORY子句
* 使用创建表…表空间的语法
* 外部常规表空间中创建表

**使用DATA DIRECTORY子句**

