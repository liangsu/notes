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

* 使用`DATA DIRECTORY`子句
* 使用[CREATE TABLE ... TABLESPACE](https://dev.mysql.com/doc/refman/8.0/en/innodb-create-table-external.html#innodb-create-table-external-tablespace-syntax) 语法
* 外部普通表空间中创建表

**使用DATA DIRECTORY子句**

通过在create table语句中指定DATA directory子句，可以在外部目录中创建InnoDB表

```mysql
CREATE TABLE t1 (c1 INT PRIMARY KEY) DATA DIRECTORY = '/external/directory';
```

`DATA DIRECTORY`子句支持在`file-per-table`表空间中创建的表。当`innodb_file_per_table`变量启用时(默认情况下是启用的)，表将隐式地在`file-per-table`表空间中创建。

```mysql
mysql> SELECT @@innodb_file_per_table;
+-------------------------+
| @@innodb_file_per_table |
+-------------------------+
|                       1 |
+-------------------------+
```

更多关于`file-per-table`表空间的信息，参见15.6.3.2节“`file-per-table`表空间”。

当在CREATE TABLE语句中指定`DATA DIRECTORY`子句时，表的数据文件(table_name.ibd)将在指定目录下的schema文件夹下。

在MySQL 8.0.21中，使用data directory子句在数据目录之外创建的表和表分区仅限于InnoDB已知的目录。这个要求允许数据库管理员控制表空间数据文件创建的位置，并确保在恢复期间可以找到数据文件(参见崩溃恢复期间的表空间发现)。已知的目录是由datadir、innodb_data_home_dir和innodb_directory变量定义的目录。您可以使用以下语句检查这些设置:

```mysql
mysql> SELECT @@datadir,@@innodb_data_home_dir,@@innodb_directories;
```

如果要使用的目录未知，在创建表之前将其添加到[`innodb_directories`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_directories)设置中。[`innodb_directories`](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_directories)变量是只读的。配置它需要重新启动服务器。有关设置系统变量的一般信息，请参阅5.1.9节“使用系统变量”。

下面的示例演示如何使用DATA directory子句在外部目录中创建表。假设`innodb_file_per_table`变量是启用的，并且InnoDB知道这个目录。

```mysql
mysql> USE test;
Database changed

mysql> CREATE TABLE t1 (c1 INT PRIMARY KEY) DATA DIRECTORY = '/external/directory';

# MySQL creates the table's data file in a schema directory
# under the external directory

shell> cd /external/directory/test
shell> ls
t1.ibd
```

使用注意：

* MySQL最初打开表空间数据文件，防止您卸载设备，但如果服务器繁忙，可能最终会关闭文件。小心不要在MySQL运行时意外地卸除外部设备，或在设备还没有挂载时启动MySQL。在关联数据文件丢失时试图访问表会导致严重错误，需要重新启动服务器。

  如果在预期路径上没有找到数据文件，服务器重启可能会失败。在这种情况下，您可以从备份中恢复表空间数据文件，或者删除表从而使数据字典中删除有关它的信息。

* 在将表放在NFS挂载的卷上之前，检查潜在的问题：[Using NFS with MySQL](https://dev.mysql.com/doc/refman/8.0/en/disk-issues.html#disk-issues-nfs).

* 如果使用LVM快照、文件复制或其他基于文件的机制备份表的数据文件，请始终使用[`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) 语句，以确保在发生备份之前，缓存在内存中的所有更改都被刷新到磁盘。

* 使用DATA DIRECTORY子句在外部目录中创建表的另一个替代方案是使用[symbolic links](https://dev.mysql.com/doc/refman/8.0/en/symbolic-links.html)，符号链接是InnoDB不支持的。

* 在源和副本位于同一台物理主机上的复制环境中，不支持DATA DIRECTORY子句。DATA DIRECTORY子句需要一个完整的目录路径。在本例中复制路径将导致源和副本在相同位置创建表。（主从在同一台物理机上）

* 从MySQL 8.0.21开始，在`file-per-table`表空间中创建的表不能再在undo表空间目录(`innodb_undo_directory`)中创建，除非InnoDB直接知道这个。已知的目录是由datadir、innodb_data_home_dir和innodb_directory变量定义的目录。

**使用CREATE TABLE ... TABLESPACE的语法**

[`CREATE TABLE ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/create-table.html)语法可以与DATA DIRECTORY子句结合使用，在外部目录中创建表。为此，需要指定`innodb_file_per_table`作为表空间名。

```mysql
mysql> CREATE TABLE t2 (c1 INT PRIMARY KEY) TABLESPACE = innodb_file_per_table
       DATA DIRECTORY = '/external/directory';
```

这个方法只支持在`file-per-table`表空间中创建表，但是不需要启用`innodb_file_per_table`变量。在其他方面，这个方法等同于上面描述的`CREATE TABLE ... DATA DIRECTORY`。同样的功能不同的形式。

**在外部常规表空间中创建表**

可以在`general`表空间中创建位于外部目录中的表。

* 有关在外部目录中创建`general`表空间的信息，请参见创建通用表空间。
* 有关在`general`表空间中创建表的信息，请参见向一般表空间添加表。

##### 15.6.1.3 导入innodb表

本节描述如何使用*Transportable Tablespaces*的功能导入表，它允许导入表、分区表或在`file-per-table`表空间中的单个表分区。有很多原因，你可能想要导入表：

* 在非生产MySQL服务器实例上运行报表，以避免对生产服务器增加额外负载
* 将数据复制到新的replica服务器
* 从备份（backed-up）表空间文件恢复表
* 比导入dump文件更快的方式，导入dump文件需要重新插入数据和重新构建索引
* 将你的数据迁移到一个更合适的存储设备。例如，您可以将访问频繁的表移动到SSD硬盘，或者将数据量大的表移动到高容量的HDD硬盘。

***Transportable Tablespaces*特性将在本节的以下主题中进行描述**：

* 准备知识
* 导入表
* 导入分区表
* 导入表分区
* 局限性
* 使用笔记
* 内部构件

**准备知识：**

* 必须启用innodb_file_per_table变量，这是默认情况
* 表空间的页大小必须与目标MySQL服务器实例的页大小匹配。InnoDB页面大小是由`innodb_page_size`变量定义的，它是在初始化MySQL服务器实例时配置的。
* 如果表处于外键关系中，则必须在执行丢弃表空间（`DISCARD TABLESPACE`）之前禁用[`foreign_key_checks`](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_foreign_key_checks) 。另外，您应该在同一逻辑时间点导出所有与外键相关的表，如 [`ALTER TABLE ... IMPORT TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html) 不会对导入的数据强制执行外键约束。为此，请停止更新相关表，提交所有事务，获取表上的共享锁，并执行导出操作。
* 当从另一个MySQL服务器实例导入表时，两个MySQL服务器实例必须具有通用可用性(General Availability, GA)状态，并且必须是相同的版本。否则，该表必须在导入该表的同一MySQL服务器实例上创建。
* 如果表是通过在CREATE table语句中指定DATA directory子句在外部目录中创建的，那么在目标实例上替换的表必须使用相同的DATA directory子句定义。如果子句不匹配，则报出schema不匹配错误。若要确定源表是否使用DATA DIRECTORY子句定义，请使用`SHOW CREATE table`查看表定义。有关使用DATA DIRECTORY子句的信息，请参见15.6.1.2节“创建表外部”。
* 如果没有在表定义中显式定义`ROW_FORMAT`选项，或者使用了`ROW_FORMAT=DEFAULT`，则源实例和目标实例上的`innodb_default_row_format`设置必须相同。否则，在尝试导入操作时将报schema不匹配错误。使用`SHOW CREATE TABLE`检查表定义。使用[`SHOW VARIABLES`](https://dev.mysql.com/doc/refman/8.0/en/show-variables.html)检查`innodb_default_row_format`设置。有关相关信息，请参见定义表的行格式。

**导入表**：

这个示例演示了如何导入一个普通的非分区表，该表驻留在file-per-table表空间中

1. 在目标实例上，创建与要导入的表定义相同的表。(您可以使用SHOW CREATE table语法获得表定义。)如果表定义不匹配，则在尝试导入操作时将报schema不匹配错误

   ```mysql
   mysql> USE test;
   mysql> CREATE TABLE t1 (c1 INT) ENGINE=INNODB;
   ```

2. 在目标实例上，丢弃刚刚创建的表的表空间。(在导入之前，您必须丢弃接收表的表空间。)

   ```mysql
   mysql> ALTER TABLE t1 DISCARD TABLESPACE;
   ```

3. 在源实例上，运行 [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) 静默要导入的表。当一个表被静默时（quiesced），只允许该表上的只读事务。

   ```mysql
   mysql> USE test;
   mysql> FLUSH TABLES t1 FOR EXPORT;
   ```

   [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list)确保已将对指定表的更改刷新到磁盘，以便在服务器运行时可以进行二进制表复制。 当运行[`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list)时，InnoDB在表的schema目录下生成一个.cfg元数据文件，cfg文件包含用于导入操作期间的模式验证的元数据。

4. 将.ibd文件和.cfg元数据文件从源实例复制到目标实例。例如:

   ```shell
   shell> scp /path/to/datadir/test/t1.{ibd,cfg} destination-server:/path/to/datadir/test
   ```

   .ibd文件和.cfg文件必须在释放共享锁之前复制，如下一步所述

   > 注意
   >
   > 如果从加密的表空间导入表，InnoDB会生成一个.cfp文件和一个.cfg元数据文件。必须将.cfp文件与.cfg文件一起复制到目标实例。cfp文件包含一个传输密钥和一个加密的表空间密钥。在导入时，InnoDB使用传输密钥来解密表空间密钥。有关信息，请参见15.13节“InnoDB静态数据加密”。

5. 在源实例上，使用 [`UNLOCK TABLES`](https://dev.mysql.com/doc/refman/8.0/en/lock-tables.html)来释放 [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list)获取的锁。

   ```mysql
   mysql> USE test;
   mysql> UNLOCK TABLES;
   ```

6. 在目标实例中，导入表空间:

   ```mysql
   mysql> USE test;
   mysql> ALTER TABLE t1 IMPORT TABLESPACE;
   ```

**导入分区表**

This example demonstrates how to import a partitioned table, where each table partition resides in a file-per-table tablespace.

1. On the destination instance, create a partitioned table with the same definition as the partitioned table that you want to import. (You can obtain the table definition using [`SHOW CREATE TABLE`](https://dev.mysql.com/doc/refman/8.0/en/show-create-table.html) syntax.) If the table definition does not match, a schema mismatch error will be reported when you attempt the import operation.

   ```sql
   mysql> USE test;
   mysql> CREATE TABLE t1 (i int) ENGINE = InnoDB PARTITION BY KEY (i) PARTITIONS 3;
   ```

   In the `/*`datadir`*/test` directory, there is a tablespace `.ibd` file for each of the three partitions.

   ```terminal
   mysql> \! ls /path/to/datadir/test/
   db.opt  t1.frm  t1#p#p0.ibd  t1#p#p1.ibd  t1#p#p2.ibd
   ```

2. On the destination instance, discard the tablespace for the partitioned table. (Before the import operation, you must discard the tablespace of the receiving table.)

   ```sql
   mysql> ALTER TABLE t1 DISCARD TABLESPACE;
   ```

   The three tablespace `.ibd` files of the partitioned table are discarded from the `/*`datadir`*/test` directory, leaving the following files:

   ```terminal
   mysql> \! ls /path/to/datadir/test/
   db.opt  t1.frm
   ```

3. On the source instance, run [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) to quiesce the partitioned table that you intend to import. When a table is quiesced, only read-only transactions are permitted on the table.

   ```sql
   mysql> USE test;
   mysql> FLUSH TABLES t1 FOR EXPORT;
   ```

   [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) ensures that changes to the named table are flushed to disk so that binary table copy can be made while the server is running. When [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) is run, `InnoDB` generates `.cfg` metadata files in the schema directory of the table for each of the table's tablespace files.

   ```terminal
   mysql> \! ls /path/to/datadir/test/
   db.opt t1#p#p0.ibd  t1#p#p1.ibd  t1#p#p2.ibd
   t1.frm  t1#p#p0.cfg  t1#p#p1.cfg  t1#p#p2.cfg
   ```

   The `.cfg` files contain metadata that is used for schema verification when importing the tablespace. [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) can only be run on the table, not on individual table partitions.

4. Copy the `.ibd` and `.cfg` files from the source instance schema directory to the destination instance schema directory. For example:

   ```terminal
   shell>scp /path/to/datadir/test/t1*.{ibd,cfg} destination-server:/path/to/datadir/test
   ```

   The `.ibd` and `.cfg` files must be copied before releasing the shared locks, as described in the next step.

   Note

   If you are importing a table from an encrypted tablespace, `InnoDB` generates a `.cfp` files in addition to a `.cfg` metadata files. The `.cfp` files must be copied to the destination instance together with the `.cfg` files. The `.cfp` files contain a transfer key and an encrypted tablespace key. On import, `InnoDB` uses the transfer key to decrypt the tablespace key. For related information, see [Section 15.13, “InnoDB Data-at-Rest Encryption”](https://dev.mysql.com/doc/refman/8.0/en/innodb-data-encryption.html).

5. On the source instance, use [`UNLOCK TABLES`](https://dev.mysql.com/doc/refman/8.0/en/lock-tables.html) to release the locks acquired by [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list):

   ```sql
   mysql> USE test;
   mysql> UNLOCK TABLES;
   ```

6. On the destination instance, import the tablespace of the partitioned table:

   ```sql
   mysql> USE test;
   mysql> ALTER TABLE t1 IMPORT TABLESPACE;
   ```

**Importing Table Partitions**

This example demonstrates how to import individual table partitions, where each partition resides in a file-per-table tablespace file.

In the following example, two partitions (`p2` and `p3`) of a four-partition table are imported.

1. On the destination instance, create a partitioned table with the same definition as the partitioned table that you want to import partitions from. (You can obtain the table definition using [`SHOW CREATE TABLE`](https://dev.mysql.com/doc/refman/8.0/en/show-create-table.html) syntax.) If the table definition does not match, a schema mismatch error will be reported when you attempt the import operation.

   ```sql
   mysql> USE test;
   mysql> CREATE TABLE t1 (i int) ENGINE = InnoDB PARTITION BY KEY (i) PARTITIONS 4;
   ```

   In the `/*`datadir`*/test` directory, there is a tablespace `.ibd` file for each of the four partitions.

   ```terminal
   mysql> \! ls /path/to/datadir/test/
   db.opt  t1.frm  t1#p#p0.ibd  t1#p#p1.ibd  t1#p#p2.ibd t1#p#p3.ibd
   ```

2. On the destination instance, discard the partitions that you intend to import from the source instance. (Before importing partitions, you must discard the corresponding partitions from the receiving partitioned table.)

   ```sql
   mysql> ALTER TABLE t1 DISCARD PARTITION p2, p3 TABLESPACE;
   ```

   The tablespace `.ibd` files for the two discarded partitions are removed from the `/*`datadir`*/test` directory on the destination instance, leaving the following files:

   ```terminal
   mysql> \! ls /path/to/datadir/test/
   db.opt  t1.frm  t1#p#p0.ibd  t1#p#p1.ibd
   ```

   Note

   When [`ALTER TABLE ... DISCARD PARTITION ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html) is run on subpartitioned tables, both partition and subpartition table names are permitted. When a partition name is specified, subpartitions of that partition are included in the operation.

3. On the source instance, run [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) to quiesce the partitioned table. When a table is quiesced, only read-only transactions are permitted on the table.

   ```sql
   mysql> USE test;
   mysql> FLUSH TABLES t1 FOR EXPORT;
   ```

   [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) ensures that changes to the named table are flushed to disk so that binary table copy can be made while the instance is running. When [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) is run, `InnoDB` generates a `.cfg` metadata file for each of the table's tablespace files in the schema directory of the table.

   ```terminal
   mysql> \! ls /path/to/datadir/test/
   db.opt  t1#p#p0.ibd  t1#p#p1.ibd  t1#p#p2.ibd t1#p#p3.ibd
   t1.frm  t1#p#p0.cfg  t1#p#p1.cfg  t1#p#p2.cfg t1#p#p3.cfg
   ```

   The `.cfg` files contain metadata that used for schema verification during the import operation. [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) can only be run on the table, not on individual table partitions.

4. Copy the `.ibd` and `.cfg` files for partition `p2` and partition `p3` from the source instance schema directory to the destination instance schema directory.

   ```terminal
   shell> scp t1#p#p2.ibd t1#p#p2.cfg t1#p#p3.ibd t1#p#p3.cfg destination-server:/path/to/datadir/test
   ```

   The `.ibd` and `.cfg` files must be copied before releasing the shared locks, as described in the next step.

   Note

   If you are importing partitions from an encrypted tablespace, `InnoDB` generates a `.cfp` files in addition to a `.cfg` metadata files. The `.cfp` files must be copied to the destination instance together with the `.cfg` files. The `.cfp` files contain a transfer key and an encrypted tablespace key. On import, `InnoDB` uses the transfer key to decrypt the tablespace key. For related information, see [Section 15.13, “InnoDB Data-at-Rest Encryption”](https://dev.mysql.com/doc/refman/8.0/en/innodb-data-encryption.html).

5. On the source instance, use [`UNLOCK TABLES`](https://dev.mysql.com/doc/refman/8.0/en/lock-tables.html) to release the locks acquired by [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list):

   ```sql
   mysql> USE test;
   mysql> UNLOCK TABLES;
   ```

6. On the destination instance, import table partitions `p2` and `p3`:

   ```sql
   mysql> USE test;
   mysql> ALTER TABLE t1 IMPORT PARTITION p2, p3 TABLESPACE;
   ```

   Note

   When [`ALTER TABLE ... IMPORT PARTITION ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html) is run on subpartitioned tables, both partition and subpartition table names are permitted. When a partition name is specified, subpartitions of that partition are included in the operation.

**局限性**

* 可移植表空间特性只支持驻留在`file-per-table `表空间中的表。它不支持驻留在系统表空间或一般表空间中的表。共享表空间中的表不能静默（quiesced）。
* [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list) 在有全文索引的表上不支持，因为无法刷新全文搜索辅助表。在导入具有全文索引的表之后，运行[`OPTIMIZE TABLE`](https://dev.mysql.com/doc/refman/8.0/en/optimize-table.html) 来重新构建全文索引。或者，在导出操作之前删除全文索引，并在将表导入目标实例后重新创建索引。
* 由于.cfg元数据文件限制，在导入分区表时，不会报告分区类型或分区定义差异导致的模式不匹配。列差异被报告。
* 在MySQL 8.0.19之前，索引关键部分排序顺序信息不会存储到表空间导入操作期间使用的.cfg元数据文件中。因此，假定索引键部分的排序顺序为升序，这是默认的。因此，如果导入操作中涉及的一个表是用DESC索引键部分排序顺序定义的，而另一个表不是这样定义的，那么记录可能会以非预期的顺序排序。解决方法是删除并重新创建受影响的索引。有关索引关键部件排序顺序的信息，请参阅13.1.15节“创建索引语句”。

在MySQL 8.0.19中更新了.cfg文件格式，以包含索引关键部分的排序顺序信息。上述问题不会影响MySQL 8.0.19或更高服务器实例之间的导入操作。

**使用笔记**

* [`ALTER TABLE ... IMPORT TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html) 不需要.cfg元数据文件来导入表。但是，在导入没有.cfg文件时，不会执行元数据检查，并且会发出类似于以下的警告:

  ```verilog
  Message: InnoDB: IO Read error: (2, No such file or directory) Error opening '.\
  test\t.cfg', will attempt to import without schema verification
  1 row in set (0.00 sec)
  ```

  只有在没有schema不匹配的情况下，才应该考虑导入没有.cfg元数据文件的表。在元数据不可访问的崩溃恢复场景中，不使用.cfg文件进行导入的能力可能非常有用。

* 在Windows上，InnoDB内部用小写字母存储数据库、表空间和表名。为了避免在Linux和Unix等区分大小写的操作系统上导入问题，可以使用小写名称创建所有数据库、表空间和表。确保用小写字母创建名称的方便方法是在初始化服务器之前将`lower_case_table_names`设置为1。(禁止使用与服务器初始化时使用的设置不同的`lower_case_table_names`来启动服务器。)

  ```mysql
  [mysqld]
  lower_case_table_names=1
  ```

* 运行[`ALTER TABLE ... DISCARD PARTITION ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html) 和 [`ALTER TABLE ... IMPORT PARTITION ... TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)在子分区表上，分区和子分区表名都是允许的。指定分区名称时，该分区的子分区将包括在操作中。

**内部构件**

下信息描述了在表导入过程中写入错误日志的内部内容和消息。

当在目标实例上运行[`ALTER TABLE ... DISCARD TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)时：

	* 表在X模式下被锁定
	* 表空间与表分离

当 [`FLUSH TABLES ... FOR EXPORT`](https://dev.mysql.com/doc/refman/8.0/en/flush.html#flush-tables-for-export-with-list)在源实例上运行:

* 为导出而刷新的表在shared模式下被锁定
* 清除协调器线程（purge coordinator thread）停止
* 脏页被同步到磁盘。
* 表元数据被写入二进制.cfg文件。

此操作的预期错误日志消息：

```
[Note] InnoDB: Sync to disk of '"test"."t1"' started.
[Note] InnoDB: Stopping purge
[Note] InnoDB: Writing table metadata to './test/t1.cfg'
[Note] InnoDB: Table '"test"."t1"' flushed to disk
```

当 [`UNLOCK TABLES`](https://dev.mysql.com/doc/refman/8.0/en/lock-tables.html) 运行在源实例:

* 二进制.cfg文件被删除
* 释放正在导入的一个或多个表上的shared锁，并重新启动purge协调器线程。

此操作的预期错误日志消息:

```
[Note] InnoDB: Deleting the meta-data file './test/t1.cfg'
[Note] InnoDB: Resuming purge
```

当[`ALTER TABLE ... IMPORT TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)在目标实例上运行，导入算法对每个导入的表空间执行以下操作:

* 检查每个表空间页是否损坏
* 更新每个页面上的空间ID和日志序列号(LSNs)。
* 验证头页的标志并更新LSN。
* Btree页面被更新。
* 将页状态设置为dirty以便将其写入磁盘。

此操作的预期错误日志消息:

```
[Note] InnoDB: Importing tablespace for table 'test/t1' that was exported
from host 'host_name'
[Note] InnoDB: Phase I - Update all pages
[Note] InnoDB: Sync to disk
[Note] InnoDB: Sync to disk - done!
[Note] InnoDB: Phase III - Flush changes to disk
[Note] InnoDB: Phase IV - Flush complete
```

> 注意：
>
> 您可能还会收到一个表空间被丢弃的警告(如果您丢弃了目标表的表空间)和一条消息，声明由于缺少.ibd文件，无法计算统计数据:
>
> ```
> [Warning] InnoDB: Table "test"."t1" tablespace is set as discarded.
> 7f34d9a37700 InnoDB: cannot calculate statistics for table
> "test"."t1" because the .ibd file is missing. For help, please refer to
> http://dev.mysql.com/doc/refman/8.0/en/innodb-troubleshooting.html
> ```

##### 15.6.1.4 移动或复制InnoDB表

本节描述移动或复制部分或全部InnoDB表到不同服务器或实例的技术。例如，您可以将整个MySQL实例移动到更大、更快的服务器上;您可能会将整个MySQL实例克隆到一个新的复制服务器;您可以将单个表复制到另一个实例以开发和测试应用程序，或者复制到数据仓库服务器以生成报表。

在Windows上，InnoDB总是用小写字母在内部存储数据库和表名。要以二进制格式将数据库从Unix移动到Windows或从Windows移动到Unix，请使用小写名称创建所有数据库和表。一个方便的方法是在创建数据库或表之前，在my.cnf或my.ini文件的[mysqld]部分添加以下代码:

```mysql
[mysqld]
lower_case_table_names=1
```

> 注意：
>
> 禁止使用与服务器初始化时使用的设置不同的`lower_case_table_names`来启动服务器

移动或复制InnoDB表的技术包括：

* [Importing Tables](https://dev.mysql.com/doc/refman/8.0/en/innodb-migration.html#copy-tables-import)
* [MySQL Enterprise Backup](https://dev.mysql.com/doc/refman/8.0/en/innodb-migration.html#copy-tables-meb)
* 复制数据文件（冷备份方式）
* 从逻辑备份中恢复

**Importing Tables**

可以使用`Transportable Tablespace`的功能从另一个MySQL服务器实例或从备份中导入位于`file-per-table`表空间中的表。参见15.6.1.3节“导入InnoDB表”。

**MySQL Enterprise Backup**

MySQL Enterprise Backup产品允许您备份正在运行的MySQL数据库，它对数据库操作的干扰最小，同时生成数据库的一致快照。当MySQL企业备份正在复制表时，读写可以继续进行。此外，MySQL企业备份可以创建压缩备份文件，并备份表的子集。结合使用MySQL二进制日志，可以执行时间点恢复。MySQL企业备份是MySQL企业订阅的一部分。

更多关于MySQL企业备份的细节，请参见30.2节“MySQL企业备份概述”。

**复制数据文件（冷备份方式）**

你可以通过简单的复制相关的文件来移动一个InnoDB数据库，第15.18.1节，“InnoDB备份”中“冷备份”章节下。

InnoDB数据和日志文件在所有平台上都是二进制兼容的，具有相同的浮点数格式。如果浮点格式不同，但是没有在表中使用FLOAT或DOUBLE数据类型，那么可以使用相同的步骤：简单地复制相关文件。

当您移动或复制`file-per-table`的.ibd文件时，源系统和目标系统上的数据库目录名称必须相同。存储在InnoDB共享表空间中的表定义包括数据库名。存储在表空间文件中的事务id和日志序列号在数据库之间也有所不同。

要将.ibd文件和关联的表从一个数据库移动到另一个数据库，可以使用RENAME table语句:

```shell
RENAME TABLE db1.tbl_name TO db2.tbl_name;
```

如果你有一个“干净（clean）”的`.ibd`文件备份，你可以将它还原到原来的MySQL安装，如下所示:

1. 在复制`.ibd`文件之后，没有删除或截断过表，因为这样做会更改表空间中存储的表ID。

2. 执行[`ALTER TABLE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html) 语句来删除当前的.ibd文件:

   ```mysql
   ALTER TABLE tbl_name DISCARD TABLESPACE;
   ```

3. 将备份的.ibd文件复制到适当的数据库目录。

4. 执行`ALTER TABLE`语句，告诉InnoDB使用新的.ibd文件对表进行处理:

   ```mysql
   ALTER TABLE tbl_name IMPORT TABLESPACE;
   ```

   >注意：
   >
   >[`ALTER TABLE ... IMPORT TABLESPACE`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html) 不会对导入的数据强制执行外键约束。

在这种情况下，“clean”的.ibd文件备份满足以下要求:

* ibd文件中没有事务未提交的修改。
* ibd文件中没有未合并的插入缓冲区条目
* Purge操作已经从.ibd文件中删除了所有删除标记的索引记录。
* mysqld已经将.ibd文件的所有修改页面从缓冲池中刷新到该文件中

您可以使用以下方法制作一个clean的.ibd备份文件：

* 停止mysqld服务器上的所有活动并提交所有事务。
* 等待直到[`SHOW ENGINE INNODB STATUS`](https://dev.mysql.com/doc/refman/8.0/en/show-engine.html)显示没有活动事务，且INNODB的主线程状态是`Waiting for server activity`，然后你可以复制.ibd文件了。

另一种复制.ibd文件的方法是使用MySQL企业备份产品:

1. 使用“MySQL企业备份”备份InnoDB安装
2. 启动第二个mysqld备份服务器，让它清理备份中的.ibd文件。

**从逻辑备份中恢复**

您可以使用[**mysqldump**](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html)之类的实用程序来执行逻辑备份，这将生成一系列的SQL语句，可以执行这些SQL语句来复制原始数据库对象定义和表数据，以便传输到另一个SQL服务器。使用此方法，格式是否不同或表是否包含浮点数据都无关紧要。

要提高此方法的性能，请在导入数据时禁用`autocommit`。仅在导入整个表或表的某一段段后执行提交。

> 个人总结：
>
> 备份的方式：
>
> 1. 使用*Transportable Tablespaces*，依靠复制idb文件进行复制
> 2. 使用mysql企业级备份工具，支持热备
> 3. 直接移动idb文件（和第一点类似）
> 4. 使用mysqldump，备份数据为sql

##### 15.6.1.5 转换表从MyISAM到InnoDB

如果你想将MyISAM表转换为InnoDB以获得更好的可靠性和可伸缩性，那么在转换之前请查看下面的指导原则和提示。

> 注意：
>
> 在MySQL以前的版本中创建的分区MyISAM表与MySQL 8.0不兼容。这些表必须在升级之前准备好，要么删除分区，要么将它们转换为InnoDB。有关更多信息，请参见第23.6.2节“与存储引擎相关的分区限制”。

**调整MyISAM和InnoDB的内存使用**

其它先略



##### 15.6.1.6 InnoDB中的自动递增处理

InnoDB提供了一种可配置的锁定机制，可以显著提高插入有AUTO_INCREMENT列的行的SQL语句的可伸缩性和性能。要在InnoDB表中使用AUTO_INCREMENT机制，必须将AUTO_INCREMENT列定义为索引的一部分，这样就可以在表中执行等价的索引SELECT MAX(ai_col)查找，以获得最大的列值。通常，这是通过将该列作为某些表索引的第一列来实现的。

本节介绍AUTO_INCREMENT锁模式的行为，不同的AUTO_INCREMENT锁模式设置的使用含义，以及InnoDB如何初始化AUTO_INCREMENT计数器。

* InnoDB自增锁模式
* InnoDB AUTO_INCREMENT锁模式使用提示
* 初始化InnoDB自增计数器
* 说明

**InnoDB自动递增锁模式**

本节描述用于生成自增值的AUTO_INCREMENT锁模式的行为，以及每种锁模式如何影响复制。自动增量锁定模式是在启动时使用`innodb_autoinc_lock_mode`配置参数配置的。

以下术语用于描述`innodb_autoinc_lock_mode`设置:

* "[`INSERT`](https://dev.mysql.com/doc/refman/8.0/en/insert.html)-like"语句

  所有在表中生成新行的语句，包括[`INSERT`](https://dev.mysql.com/doc/refman/8.0/en/insert.html), [`INSERT ... SELECT`](https://dev.mysql.com/doc/refman/8.0/en/insert-select.html), [`REPLACE`](https://dev.mysql.com/doc/refman/8.0/en/replace.html), [`REPLACE ... SELECT`](https://dev.mysql.com/doc/refman/8.0/en/replace.html)和[`LOAD DATA`](https://dev.mysql.com/doc/refman/8.0/en/load-data.html)。包括“简单插入（Simple inserts）”、“大容量插入（bulk-inserts）”和“混合模式”插入。

* “Simple inserts”

  可以预先确定要插入的行数的语句(在最初处理语句时)。这包括单行和多行INSERT和REPLACE语句，它们没有嵌套子查询，但没有[`INSERT ... ON DUPLICATE KEY UPDATE`](https://dev.mysql.com/doc/refman/8.0/en/insert-on-duplicate.html)。

* “Bulk inserts” （批量插入）

  不知道要插入的行数(即：需要自动递增多少)的语句。这包括 [`INSERT ... SELECT`](https://dev.mysql.com/doc/refman/8.0/en/insert-select.html), [`REPLACE ... SELECT`](https://dev.mysql.com/doc/refman/8.0/en/replace.html)和[`LOAD DATA`](https://dev.mysql.com/doc/refman/8.0/en/load-data.html) 语句，但不是纯插入。InnoDB在处理每一行时为AUTO_INCREMENT列分配一个新值。

* "Mixed-mode inserts"（混合插入）

  这些是“简单插入”语句，为一些(但不是所有)新行指定自增列的值。例如，c1是表t1的AUTO_INCREMENT列:

  ```mysql
  INSERT INTO t1 (c1,c2) VALUES (1,'a'), (NULL,'b'), (5,'c'), (NULL,'d');
  ```

  另一种“混合模式插入是”[`INSERT ... ON DUPLICATE KEY UPDATE`](https://dev.mysql.com/doc/refman/8.0/en/insert-on-duplicate.html)"，在最坏的情况下，插入之后是更新，其中AUTO_INCREMENT列的分配值可能在更新阶段使用，也可能不使用。

`innodb_autoinc_lock_mode`配置参数有三种可能的设置，对于“traditional”（传统）、“consecutive”（连续）或“interleaved”（交错）锁模式，设置分别为0、1或2。在MySQL 8.0中，交错锁模式(`innodb_autoinc_lock_mode=2`)是默认设置。在MySQL 8.0之前，默认是连续锁定模式(`innodb_autoinc_lock_mode=1`)。

MySQL 8.0中交错锁模式的默认设置，反映了默认复制类型从基于语句的复制到基于行的复制的变化。基于语句的复制需要连续的自动增量锁定模式，以确保对给定的SQL语句序列以可预测和可重复的顺序分配自动增量值，而基于行的复制对SQL语句的执行顺序不敏感。

* `innodb_autoinc_lock_mode = 0` (“traditional” lock mode)

  传统的锁模式提供了之前在MySQL 5.1中引入`innodb_autoinc_lock_mode`配置参数相同的行为。由于可能存在语义上的差异，传统的锁模式选项用于向后兼容性、性能测试和解决“混合模式插入”问题。

  在这种锁定模式下，所有“INSERT-like”的语句都获得一个特殊的表级`AUTO-INC`锁，用于插入到具有AUTO_INCREMENT列的表中。这个锁通常持有到sql语句执行完成之后（而不是事务事务结束之后），以确保一系列的insert语句的auto-increment的值是可预测的、可重复的顺序，还确保给定语句的auto-increment的值是连贯的。

  对于基于语句的复制，这意味着在复制服务器上复制SQL语句时，自动递增列使用与源服务器上相同的值。执行多个INSERT语句的结果是确定性的，副本将复制与源上相同的数据。如果多个INSERT语句生成的auto-increment值是交错的，那么两个并发INSERT语句的结果将是不确定的，并且不能使用基于语句的复制可靠地传播到复制服务器。

  为了清楚地说明这一点，考虑一个使用这个表的例子:

  ```mysql
  CREATE TABLE t1 (
    c1 INT(11) NOT NULL AUTO_INCREMENT,
    c2 VARCHAR(10) DEFAULT NULL,
    PRIMARY KEY (c1)
  ) ENGINE=InnoDB;
  ```

  假设有两个正在运行的事务，每个事务都将行插入一个包含AUTO_INCREMENT列的表中。一个事务使用 [`INSERT ... SELECT`](https://dev.mysql.com/doc/refman/8.0/en/insert-select.html)语句插入1000行，另一个使用简单的INSERT语句插入一行:

  ```mysql
  Tx1: INSERT INTO t1 (c2) SELECT 1000 rows from another table ...
  Tx2: INSERT INTO t1 (c2) VALUES ('xxx');
  ```

  InnoDB不能预先知道在Tx1的INSERT语句中从SELECT语句中检索了多少行，它会在语句进行的时候一次分配一个自增值。对于表级锁(持有到语句末尾)，一次只能执行一条引用表t1的INSERT语句，并且不同语句生成的自动递增的数字不会交织在一起。Tx1生成的自动递增值`insert…SELECT`语句是连续的，而Tx2中的INSERT语句使用的(单个)自动递增值比Tx1使用的所有值都要小或大，这取决于哪条语句先执行。

  只要从二进制日志中重放SQL语句时(使用基于语句的复制或在恢复场景中)，与Tx1和Tx2首次在源数据库运行时的结果是一样的。因此，表级锁一直保持到语句结束，使得使用自动递增的INSERT语句在基于语句的复制中使用是安全的。但是，当多个事务同时执行insert语句时，这些表级锁会限制并发性和可伸缩性。

  在前面的示例中，如果没有表级锁，则Tx2中用于插入的自动递增列的值完全取决于语句执行的时间。如果Tx2的插入是在Tx1的插入运行时执行的(而不是在Tx1开始之前或完成之后)，那么两个INSERT语句分配的自增值是不确定的，并且可能随着每次运行而变化。

  在连续（[consecutive](https://dev.mysql.com/doc/refman/8.0/en/innodb-auto-increment-handling.html#innodb-auto-increment-lock-mode-consecutive)）锁模式下，对预先知道行数的“simple insert”语句，InnoDB可以避免使用使用表级别`AUTO-INC`锁，同时仍然保证执行的确定性和基于语句复制的安全性。

  如果你不使用二进制日志重播SQL语句来恢复或复制，交叉锁（[interleaved](https://dev.mysql.com/doc/refman/8.0/en/innodb-auto-increment-handling.html#innodb-auto-increment-lock-mode-interleaved) ）模式可以用来取消使用表级别的锁`AUTO-INC`，从而获得更大的并发性和性能。前提是允许自增列在每次并发交错执行都可能产生不同的自增值。

* `innodb_autoinc_lock_mode = 1` 连续锁模式

  在这种模式下，“批量插入”使用特殊的AUTO-INC表级锁，并持有它直到语句结束，这适用于所有[`INSERT ... SELECT`](https://dev.mysql.com/doc/refman/8.0/en/insert-select.html), [`REPLACE ... SELECT`](https://dev.mysql.com/doc/refman/8.0/en/replace.html),和[`LOAD DATA`](https://dev.mysql.com/doc/refman/8.0/en/load-data.html) 语句。在同一时间只有一条语句能持有`AUTO-INC`锁。如果批量插入操作的原表与目标表不同，那么目标表的`AUTO-INC`锁的获取在源表中获取共享锁（第一行数据被查出时获取共享锁）之后。如果原表与目标表相同，那么获取`AUTO-INC`锁将共享锁（在select出所有行之后获取共享锁）之后。

  “简单的插入”(提前已经知道要插入的行数)可以避免表级锁`AUTO-INC`，在执行期间获取一把互斥锁（重量级锁）然后生成需要自增多少，就不用持有`AUTO-INC`锁到语句执行完成。表级别的锁AUTO-INC不会被使用除非有另一个事务获得了`AUTO-INC`锁，如果另一个事务获得了`AUTO-INC`锁，那么“简单插入”会等待`AUTO-INC`锁，就像它是“批量插入”一样。

  这个锁定模式能够确保，在INSERT的行数提前是不知道的(随着语句的进行，分配自动递增的数字),对于“insert-like”语句所有的自增值是连续的，并在基于语句的复制数据是安全的。

  简单地说，这种锁模式显著提高了可伸缩性，同时对基于语句的复制使用是安全的。而且，与“传统”锁模式一样，任何给定语句分配的自动递增的数字都是连续的。与使用自动递增的“传统”模式相比，使用自动递增的语句在语义上没有任何变化，但有一个重要的例外。

  例外情况是“混合模式插入”，在这种情况下，用户为多行“简单插入”中的一些(而不是全部)行提供AUTO_INCREMENT列的显式值。对于这样的插入，InnoDB分配的自动递增值比要插入的行数还要多。但是，自动分配的所有值都是连续生成的(因此大于)最近执行的前面语句生成的自动递增值。“多余的”数字丢失了。

* `innodb_autoinc_lock_mode = 2` (交错`interleaved`锁模式)

  在这种锁定模式下，“[`INSERT`](https://dev.mysql.com/doc/refman/8.0/en/insert.html)-like”语句不会使用表级自动inc锁定，多条语句可以同时执行。这是最快、最可伸缩的锁模式，但是当使用基于语句的复制或恢复场景(从二进制日志中重放SQL语句)时，它不安全。

  在这种锁定模式下，自动递增的值保证是惟一的，并且在所有并发执行的“insert-like”语句中单调递增。但是，由于多个语句可以同时生成数字(即，数字的分配在语句之间交错)，因此由任何给定语句插入的行生成的值可能不是连续的。

  如果执行的语句都是“simple inserts”，其中要插入的行数是预先知道的，那么除了“混合模式插入”之外，为单个语句生成的数字不会有缺口。但是，在执行“批量插入”时，任何给定语句的自增值都可能不连续。

  

**InnoDB AUTO_INCREMENT锁模式使用提示**

* 在复制场景中使用auto-increment

  如果使用基于语句的复制，请将`innodb_autoinc_lock_mode`设置为0或1，并在源及其副本上使用相同的值。如果使用`innodb_autoinc_lock_mode = 2`(“交错”)或在源和副本不使用相同锁模式的配置中，不能确保副本上的自动增量值与源上的相同。

  如果使用基于行或混合格式的复制，那么所有的auto-increment模式都是安全的，因为基于行的复制对SQL语句的执行顺序不敏感（混合格式会对不安全的语句使用基于行的复制）。

* “丢失”auto-increment的值并产生序列间隙

  在所有锁模式(0,1,2)中，如果生成自动递增值的事务回滚，这些自动递增的值将“丢失”。一旦为自动增量列生成了值，就不能回滚该值，无论“insert-like”语句是否完成，也无论包含的事务是否回滚。这些丢失的值不会被重用。因此，在表的AUTO_INCREMENT列中存储的值可能存在不连续。

* 为AUTO_INCREMENT列指定NULL或0

  在所有的锁模式(0,1，和2)中，如果用户在插入时为AUTO_INCREMENT列指定了NULL或0,InnoDB就会像未指定值一样处理该行，并为其生成一个新值。

* 如果AUTO_INCREMENT值大于指定整数类型的最大整数

  在所有锁模式(0、1和2)中，如果值大于指定整数类型中可以存储的最大整数，则不要定义自动增量机制的行为。

* “批量插入”的自动递增值中的间隙

  `innodb_autoinc_lock_mode`设置为0(“传统”)或1(“连续”),任何给定的语句生成的自动递增值是连续的，没有间隙，因为表级锁AUTO-INC持有到语句执行的最后，且同一时间只有一条插入的语句可以执行。

  innodb_autoinc_lock_mode设置为2(“interleaved”)时，“批量插入”生成的自动递增值可能会有间隙，但只有在并发执行“inert-like”语句时才会这样。

  对于锁模式1或2，连续语句之间可能会出现差距，因为对于批量插入，可能不知道每个语句所需的自动递增值的确切数量，可能会高估“simple-like”的值。

* 在“混合模式插入”分配的自动递增值

  考虑一个“混合模式插入”，其中“简单插入”指定一些(但不是全部)结果行的自动递增值。这样的语句在锁定模式0、1和2中表现不同。例如，假设c1是表t1的一个AUTO_INCREMENT列，并且最近自动生成的序列号是100。

  ```mysql
  mysql> CREATE TABLE t1 (
      -> c1 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
      -> c2 CHAR(1)
      -> ) ENGINE = INNODB;
  ```

  现在，考虑下面的“混合模式插入”语句：

  ```mysql
  mysql> INSERT INTO t1 (c1,c2) VALUES (1,'a'), (NULL,'b'), (5,'c'), (NULL,'d');
  ```

  `innodb_autoinc_lock_mode`设置为0(“传统”)，这4个新行是：

  ```sql
  mysql> SELECT c1, c2 FROM t1 ORDER BY c2;
  +-----+------+
  | c1  | c2   |
  +-----+------+
  |   1 | a    |
  | 101 | b    |
  |   5 | c    |
  | 102 | d    |
  +-----+------+
  ```

  下一个可用的自动递增值是103，因为自动递增值是一次分配一个，而不是在语句开始执行时一次性分配所有的值。无论是否有并发执行的“insert-like”语句(任何类型)，此结果都为真。

  `innodb_autoinc_lock_mode`设置为1(“连续”)，这4个新行也是:

  ```mysql
  mysql> SELECT c1, c2 FROM t1 ORDER BY c2;
  +-----+------+
  | c1  | c2   |
  +-----+------+
  |   1 | a    |
  | 101 | b    |
  |   5 | c    |
  | 102 | d    |
  +-----+------+
  ```

  但是，在本例中，下一个可用的自动递增值是105，而不是103，因为在处理语句时分配了四个自动递增值，但只使用了两个。无论是否有并发执行的“类插入”语句(任何类型)，此结果都为真。

  innodb_autoinc_lock_mode设置为模式2 (" interleaved ")，这4个新行是:

  ```mysql
  mysql> SELECT c1, c2 FROM t1 ORDER BY c2;
  +-----+------+
  | c1  | c2   |
  +-----+------+
  |   1 | a    |
  |   x | b    |
  |   5 | c    |
  |   y | d    |
  +-----+------+
  ```

  x和y的值是惟一的，并且比以前生成的任何行都大。但是，x和y的特定值取决于并发执行语句自增了多少。

  最后，考虑以下语句，当最近生成的序列号为100时执行:

  ```mysql
  mysql> INSERT INTO t1 (c1,c2) VALUES (1,'a'), (NULL,'b'), (101,'c'), (NULL,'d');
  ```

  使用任何`innodb_autoinc_lock_mode`设置，该语句会生成重复值，并报出error 23000(Can't write; duplicate key in table)，因为101被分配给了行(NULL， 'b')，而行(101，'c')插入失败。

* 在一系列插入语句的中间修改AUTO_INCREMENT列值

  在MySQL 5.7和更早的版本中，在一系列INSERT语句中间修改AUTO_INCREMENT列值可能会导致“Duplicate entry”的错误。例如，如果执行更新操作，将一行数据的AUTO_INCREMENT列值更改为大于当前最大自动递增值的值，则随后的使用自增插入的可能会导致“Duplicate entry”错误。在MySQL 8.0及以后版本中，如果您将一行数据的AUTO_INCREMENT列的值修改为一个大于当前最大自动递增值的值，那么新值将被持久化，随后的插入操作将从新的更大的值开始分配自动递增的值。下面的示例演示了此行为。

  ```mysql
  mysql> CREATE TABLE t1 (
      -> c1 INT NOT NULL AUTO_INCREMENT,
      -> PRIMARY KEY (c1)
      ->  ) ENGINE = InnoDB;
  
  mysql> INSERT INTO t1 VALUES(0), (0), (3);
  
  mysql> SELECT c1 FROM t1;
  +----+
  | c1 |
  +----+
  |  1 |
  |  2 |
  |  3 |
  +----+
  
  mysql> UPDATE t1 SET c1 = 4 WHERE c1 = 1;
  
  mysql> SELECT c1 FROM t1;
  +----+
  | c1 |
  +----+
  |  2 |
  |  3 |
  |  4 |
  +----+
  
  mysql> INSERT INTO t1 VALUES(0);
  
  mysql> SELECT c1 FROM t1;
  +----+
  | c1 |
  +----+
  |  2 |
  |  3 |
  |  4 |
  |  5 |
  +----+
  ```

  

  **初始化InnoDB AUTO_INCREMENT计数器**

  本节描述InnoDB如何初始化AUTO_INCREMENT计数器。

  如果你为InnoDB表指定了一个AUTO_INCREMENT列，那么内存中的表对象就包含了一个特殊的计数器，叫做auto-increment counter，它在为该列赋新值时使用。

  在MySQL 5.7和更早的版本中，自动递增的计数器只存储在主内存中，而不是磁盘上。在服务器重启后初始化自动增量计数器，InnoDB会在第一次插入包含AUTO_INCREMENT列的表时执行如下语句的等价语句。

  ```mysql
SELECT MAX(ai_col) FROM table_name FOR UPDATE;
  ```

  在MySQL 8.0中，这个方式被改变了。当前的最大自动增量计数器值在每次更改时被写入redo日志，并保存到每个检查点上的引擎私有系统表中。这些更改使得当前的最大自动递增计数器值在服务器重启时保持不变。
  
  在服务器正常关闭后重新启动时，InnoDB使用存储在数据字典系统表中的当前最大自动增量值初始化内存中的自动增量计数器。
  
  当服务器在崩溃恢复期间重启时，InnoDB使用存储在数据字典系统表中的当前最大自动增量值初始化内存中的自动增量计数器，并扫描redo日志以获取自上次检查点以来写入的自动增量计数器值。如果redo日志中记录的值大于内存中的计数器值，则使用redo日志中的记录值。但是，在服务器崩溃的情况下，不能保证重用先前分配的自动递增值。每次当前最大自动递增值的改变是由于插入或更新操作，改变后会将新值写入redo日志，但如果在redo日志刷新到磁盘之前发生宕机，在服务器重新启动之后，先前已经分配的值会被再次利用。
  
  InnoDB使用等价于`SELECT MAX(ai_col) FROM table_name`来初始化自动增量计数器的唯一情况是在导入一个没有.cfg元数据文件的表时。否则，当前自动递增的最大计数器值将从.cfg元数据文件(如果存在)中读取。除了计数器值初始化之外，当试图使用语句`ALTER TABLE ... AUTO_INCREMENT = N`将计数器值设置为小于或等于持久化文件中的值时，将使用等价于`SELECT MAX(ai_col) FROM table_name`语句的值来确定当前自动递增的表最大计数器值。例如，您可能尝试在删除一些记录后将计数器值设置为较小的值，在这种情况下，必须搜索表以确保新的计数器值不小于或等于当前实际的最大计数器值。
  
  在MySQL 5.7和更早的版本中，重新启动服务器会丢失`AUTO_INCREMENT = N` 的值，该选项可用于CREATE table或ALTER table语句，分别设置初始计数器值或更改现有的计数器值。在MySQL 8.0中，服务器重启不会丢失`AUTO_INCREMENT = N`的值，如果将自动递增计数器初始化为指定的值，或者将自动递增计数器值更改为更大的值，新值将在服务器重新启动期间是持久化的。
  
  > 注意：
  >
  > [`ALTER TABLE ... AUTO_INCREMENT = N`](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)能够将auto-increment计数器的值修改为一个比当前值更大的值
  
  在MySQL 5.7和更早的版本中，服务器在回滚操作之后立即重启会导致重用之前分配给回滚事务的自增值，有效地回滚当前的最大自动递增值。在MySQL 8.0中，当前最大的自动递增值被持久化，防止重用之前分配的值。
  
  如果一个`SHOW TABLE STATUS`语句在自动递增计数器初始化之前检查了一个表，InnoDB打开表并使用当前存储在数据字典系统表中的最大自增值初始化计数器值。该值存储在内存中，供以后的插入或更新使用。计数器值的初始化会使用对表使用莆田通的它锁读取，该读取一直持续到事务结束。InnoDB在为一个新创建的表初始化自动递增计数器时遵循相同的过程，这个表有一个用户指定的大于0的自动递增值。
  
  自动递增计数器初始化后，如果在插入行时没有显式指定自动递增的值，InnoDB会隐式递增计数器并将新值赋给列。如果插入显式指定自动递增列值的行，且该值大于当前最大计数器值，则计数器将设置为指定值。
  
  InnoDB在服务器运行时使用内存中的自动增量计数器。当服务器停止并重新启动时，InnoDB会重新初始化自动递增的计数器，如前所述。
  
  `auto_increment_offset`配置选项决定AUTO_INCREMENT列值的起点。默认设置为1。
  
  `auto_increment_increment`配置选项控制递增值的步长。默认设置为1。
  
  **说明**
  
  当AUTO_INCREMENT整数列的值用完时，后续的插入操作将返回重复键错误。这是一般的MySQL行为。
  
  

#### 15.6.2 索引

[15.6.2.1 Clustered and Secondary Indexes](https://dev.mysql.com/doc/refman/8.0/en/innodb-index-types.html)

[15.6.2.2 The Physical Structure of an InnoDB Index](https://dev.mysql.com/doc/refman/8.0/en/innodb-physical-structure.html)

[15.6.2.3 Sorted Index Builds](https://dev.mysql.com/doc/refman/8.0/en/sorted-index-builds.html)

[15.6.2.4 InnoDB FULLTEXT Indexes](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html)

本节讨论与InnoDB索引相关的主题。



##### 15.6.2.2 聚集索引与辅助索引

每个InnoDB表都有一个特殊的索引，称为聚集索引，用于存储行数据。通常，聚集索引是主键的同义词。要从查询、插入和其他数据库操作中获得最佳性能，您必须了解InnoDB如何使用聚集索引来优化每个表最常见的查找和DML操作。

* 当你在表上定义一个主键时，InnoDB使用它作为聚集索引。为创建的每个表定义一个主键，如果没有逻辑惟一且非空的列或列集，则添加一个新的自动递增的列，其值将自动填充。
* 如果你没有为你的表定义一个主键，MySQL找到第一个唯一的索引，其中所有的键列不是空的，InnoDB将使用它作为聚集索引
* 如果表没有主键或合适的唯一索引，InnoDB内部会在包含行ID值的合成列上生成一个名为GEN_CLUST_INDEX的隐藏聚集索引。这些行是按照InnoDB给表中的行分配的ID排序的。行ID是一个6字节的字段，在插入新行时单调增加。因此，按行ID排序的行在物理上是按插入顺序排列的。

**聚集索引如何加速查询**

通过聚集索引访问一行数据是非常快的，因为索引搜索直接指向包含所有行数据的页面。如果一个表很大，与使用辅助索引相比，聚集索引体系结构通常会节省一次磁盘I/O操作。

**二级索引如何与聚集索引关联**

聚集索引以外的所有索引都称为辅助索引。在InnoDB中，辅助索引中的每条记录都包含该行的主键列，以及为辅助索引指定的列。InnoDB使用这个主键值在聚集索引中搜索行。

如果主键很长，辅助索引将会使用更多的空间，所以使用较短的主键比较有利。

关于如何利用InnoDB聚集和二级索引的指导，请参见8.3节“优化和索引”。

##### 15.6.2.2 InnoDB索引的物理结构

除了空间索引之外，InnoDB索引是B-tree数据结构。空间索引使用r-tree，r-tree是用于索引空间数据的专用数据结构。索引记录存储在它们的b树或r树数据结构的叶页中。索引页的默认大小为16KB。

当新记录被插入到一个InnoDB聚集索引中时，InnoDB会尝试留出1/16的页面空闲，以备将来对索引记录的插入和更新。如果按顺序(升序或降序)插入索引记录，会导致索引页大约使用15/16的空间。如果记录是按随机顺序插入的，那么页面的满页从1/2到15/16。

InnoDB在创建或重新构建b树索引时执行批量加载，这种创建索引的方法称为排序索引构建。`innodb_fill_factor`配置选项定义在排序索引构建期间填充的每个b树页面上的空间百分比，其余的空间保留用于未来的索引增长。对空间索引不支持排序索引构建。更多信息，请参见15.6.2.3节“排序索引构建”。`innodb_fill_factor`设置为100会使聚集索引页中有1/16的空间空闲，以便将来索引增长。

如果InnoDB索引页的填充因子低于`MERGE_THRESHOLD`(如果没有指定，默认值是50%)，InnoDB尝试收缩索引树来释放页面。`MERGE_THRESHOLD`设置适用于b树和r树索引。更多信息，请参见15.8.11节“为索引页配置合并阈值”。

你可以通过在初始化MySQL实例之前设置`innodb_page_size`配置选项来定义一个MySQL实例中所有InnoDB表空间的页面大小。一旦定义了实例的页面大小，就不能在不重新初始化实例的情况下更改它。支持的大小为64KB、32KB、16KB(默认)、8KB和4KB。

使用特定InnoDB页面大小的MySQL实例不能使用使用不同页面大小的实例的数据文件或日志文件。

##### 15.6.2.3 排序索引的构建

InnoDB在创建或重建索引时执行批量加载，而不是每次插入一条索引记录。这种创建索引的方法也称为排序索引构建。对空间索引不支持排序索引构建。

索引构建有三个阶段。在第一阶段，扫描聚集索引，生成索引条目并添加到排序缓冲区。当排序缓冲区满时，将对条目进行排序并将其写入临时中间文件。这个过程也称为“运行”。在第二阶段，当一次或多次运行写入临时中间文件时，将对文件中的所有条目执行合并排序。在第三个也是最后一个阶段，排序后的元素被插入到b树中。

在引入排序索引构建之前，使用insert api将索引项一次一个地插入到b树中。该方法涉及打开b树游标以查找插入位置，然后使用乐观插入将条目插入到b树页面中。如果由于页面已满而导致插入失败，则将执行悲观插入，这涉及打开b -树游标，并根据需要拆分和合并b -树节点，以便为条目找到空间。这种“自上而下”建立索引的方法的缺点是搜索插入位置的代价，以及b树节点的不断分裂和合并。

排序索引构建使用“自下而上”的方法来构建索引。使用这种方法，对最右叶页面的引用被保存在b树的所有级别上。分配所需b -树深度的最右边的叶页，并根据其排序顺序插入条目。一旦叶页满了，节点指针就被附加到父页，并为下一次插入分配同级叶页。这个过程一直持续到插入所有条目，这可能会导致插入到根级别。当分配一个同级页面时，释放对先前固定的叶页面的引用，新分配的叶页面成为最右边的叶页面和新的默认插入位置。

**为将来的索引增长保留B-tree页面空间**

要为将来的索引增长留出空间，可以使用`innodb_fill_factor`配置选项来保留一定百分比的b -树页面空间。例如，在排序索引构建期间，将`innodb_fill_factor`设置为80可以保留b -树页面中20%的空间。此设置同时适用于B-tree叶页和非叶页。它不适用于用于文本或BLOB条目的外部页面。保留的空间量可能与配置的不完全相同，因为`innodb_fill_factor`值被解释为一个提示，而不是一个硬限制。

**排序索引构建和全文索引支持**

全文索引支持排序索引构建。以前，SQL用于将条目插入到全文索引中。

**排序索引构建和压缩表**

对于压缩的表，前面的索引创建方法在压缩和未压缩的页面上都追加了条目。当修改日志(表示压缩页上的空闲空间)满时，将重新压缩压缩页。如果因为缺少空间而压缩失败，那么页将被分割。使用排序索引构建时，条目只会追加到未压缩的页面。当未压缩的页面已满时，将对其进行压缩。自适应填充用于确保压缩在大多数情况下成功，但如果压缩失败，将分割页面并再次尝试压缩。这个过程一直持续到压缩成功为止。更多关于B-Tree页面压缩的信息，请参见15.9.1.5节，[InnoDB表如何压缩](https://dev.mysql.com/doc/refman/8.0/en/innodb-compression-internals.html)。

**排序索引构建和重做日志记录**

在排序索引构建期间禁用redo日志记录。相反，有一个检查点来确保索引构建能够承受崩溃或失败。检查点强制将所有脏页写入磁盘。在排序索引构建期间，会定期通知页清理器线程刷新脏页，以确保检查点操作可以快速处理。通常，当清理页面的数量低于设置的阈值时，页面清理器线程会清除脏页面。对于已排序的索引构建，脏页面会被迅速刷新，以减少检查点开销，并将I/O和CPU活动并行化。

**排序索引构建和优化器统计**

排序后的索引构建可能导致优化器统计信息与前面的索引创建方法生成的统计信息不同。统计数据的差异不会影响工作负载性能，这是由于用于填充索引的不同算法造成的。



##### 15.6.2.4 InnoDB全文索引

全文索引是在基于文本的列(CHAR、VARCHAR或text列)上创建的，以帮助加快对这些列中包含的数据的查询和DML操作，省略任何定义为stopwords的单词。

全文索引定义为`CREATE TABLE`语句的一部分，或者使用`ALTER TABLE`或`CREATE index`将其添加到现有表中。

全文搜索使用[`MATCH() ... AGAINST`](https://dev.mysql.com/doc/refman/8.0/en/fulltext-search.html#function_match)语法。有关用法的信息，请参阅12.9节“全文检索功能”。

InnoDB全文索引在本节的以下主题下进行描述：

- [InnoDB Full-Text Index Design](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html#innodb-fulltext-index-design)
- [InnoDB Full-Text Index Tables](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html#innodb-fulltext-index-tables)
- [InnoDB Full-Text Index Cache](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html#innodb-fulltext-index-cache)
- [InnoDB Full-Text Index Document ID and FTS_DOC_ID Column](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html#innodb-fulltext-index-docid)
- [InnoDB Full-Text Index Deletion Handling](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html#innodb-fulltext-index-deletion)
- [InnoDB Full-Text Index Transaction Handling](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html#innodb-fulltext-index-transaction)
- [Monitoring InnoDB Full-Text Indexes](https://dev.mysql.com/doc/refman/8.0/en/innodb-fulltext-index.html#innodb-fulltext-index-monitoring)

**InnoDB全文索引设计**

InnoDB全文索引采用倒排索引设计。倒排索引存储有一个单词列表，对于每个单词，存储该单词出现在其中的文档列表。为了支持近距离搜索，还将每个单词的位置信息存储为字节偏移量。

**InnoDB全文索引表**

当创建一个InnoDB全文索引时，会创建一组索引表，如下所示:

```mysql
mysql> CREATE TABLE opening_lines (
       id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
       opening_line TEXT(500),
       author VARCHAR(200),
       title VARCHAR(200),
       FULLTEXT idx (opening_line)
       ) ENGINE=InnoDB;

mysql> SELECT table_id, name, space from INFORMATION_SCHEMA.INNODB_TABLES
       WHERE name LIKE 'test/%';
+----------+----------------------------------------------------+-------+
| table_id | name                                               | space |
+----------+----------------------------------------------------+-------+
|      333 | test/fts_0000000000000147_00000000000001c9_index_1 |   289 |
|      334 | test/fts_0000000000000147_00000000000001c9_index_2 |   290 |
|      335 | test/fts_0000000000000147_00000000000001c9_index_3 |   291 |
|      336 | test/fts_0000000000000147_00000000000001c9_index_4 |   292 |
|      337 | test/fts_0000000000000147_00000000000001c9_index_5 |   293 |
|      338 | test/fts_0000000000000147_00000000000001c9_index_6 |   294 |
|      330 | test/fts_0000000000000147_being_deleted            |   286 |
|      331 | test/fts_0000000000000147_being_deleted_cache      |   287 |
|      332 | test/fts_0000000000000147_config                   |   288 |
|      328 | test/fts_0000000000000147_deleted                  |   284 |
|      329 | test/fts_0000000000000147_deleted_cache            |   285 |
|      327 | test/opening_lines                                 |   283 |
+----------+----------------------------------------------------+-------+
```

前6个表表示倒排索引，称为辅助索引表（auxiliary index tables）。当对传入的文档进行标记时，单个单词(也称为“令牌”)连同位置信息和相关的文档ID (DOC_ID)一起插入索引表。根据单词第一个字符的字符集排序权重，将单词完全排序并在六个索引表中分区。

倒排索引被划分为6个辅助索引表，目的是为了支持并行索引创建。默认情况下，两个线程对索引表进行标记、排序和插入单词和关联数据。线程的数量可以使用`innodb_ft_sort_pll_degree`选项进行配置。在大型表上创建全文索引时，考虑增加线程的数量。

辅助索引表名用`fts_`作为前缀，用`index_*`作为后缀。每个辅助索引表通过被索引表名中的十六进制值与索引表关联，该值与被索引表的`table_id`匹配。例如，`test/opening_lines`表的`table_id`是327，其十六进制值是`0x147`。如上例所示，“147”十六进制值出现在与`test/opening_lines`表关联的辅助索引表的名称中。

表示全文索引的`index_id`的十六进制值也出现在辅助索引表名中。例如，在辅助表名`test/fts_0000000000000147_00000000000001c9_index_1`中，十六进制值`1c9`的十进制值为457，可以通过查询`INFORMATION_SCHEMA.INNODB_INDEXES`表来查询opening_lines表(idx)上定义的索引的index_id，这个值(457)的表。

```mysql
mysql> SELECT index_id, name, table_id, space from INFORMATION_SCHEMA.INNODB_INDEXES
       WHERE index_id=457;
+----------+------+----------+-------+
| index_id | name | table_id | space |
+----------+------+----------+-------+
|      457 | idx  |      327 |   283 |
+----------+------+----------+-------+
```

如果主表是在file-per-table表空间中创建的，那么索引表存储在它们自己的表空间中。

前面示例中显示的其他索引表称为公共索引表（common index tables），用于删除处理和存储全文索引的内部状态。与为每个全文索引创建的反向索引表不同，这组表对于在特定表上创建的所有全文索引是通用（common ）的。

即使删除全文索引，也保留common index tables。删除全文索引时，将保留为索引创建的`FTS_DOC_ID`列，因为删除`FTS_DOC_ID`列将需要重新构建表。需要使用Common axillary tables来管理FTS_DOC_ID列。

* `fts_*_deleted` 和`fts_*_deleted_cache`

  包含已删除但数据尚未从全文索引中删除的文档id (DOC_ID)。`fts_*_deleted_cache`是`fts_*_deleted`表的内存版本。

* `fts_*_being_deleted` 和 `fts_*_being_deleted_cache`

  包含文档id (DOC_ID)，用于已删除的文档以及当前正在从全文索引中删除其数据的文档。`fts_*_being_deleted_cache`表是`fts_*_being_deleted`表的内存版本。

* `fts_*_config`

  存储关于全文索引的内部状态的信息。最重要的是，它存储`FTS_SYNCED_DOC_ID`，它标识已经解析并刷新到磁盘的文档。在崩溃恢复的情况下，使用`FTS_SYNCED_DOC_ID`值来标识尚未刷新到磁盘的文档，以便重新解析文档并将其添加回全文索引缓存中。要查看这个表中的数据，请查询`INFORMATION_SCHEMA.INNODB_FT_CONFIG`表。

  

  









