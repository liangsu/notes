# elasticSearch

官方文档： <https://www.elastic.co/guide/en/elasticsearch/reference/6.0/indices-create-index.html>



## 1. 概述

Elasticsearch是面向文档(document oriented)的，这意味着它可以存储整个对象或文档(document)。然而它不仅仅是存储，还会索引(index)每个文档的内容使之可以被搜索。在Elasticsearch中，你可以对文档（而非成行成列的数据）进行索引、搜索、排序、过滤。Elasticsearch比传统关系型数据库如下：

```
Relational DB -> Databases -> Tables -> Rows -> Columns
Elasticsearch -> Indices   -> Types  -> Documents -> Fields
```

## 2. 映射mapping

类似于关系数据库的表结构，可以设置某个字段的数据类型、默认值、分析器、是否被索引等等

* 数据类型参考官网：<https://www.elastic.co/guide/en/elasticsearch/reference/6.0/mapping-types.html>



## 3. 简单操作

1. 新增索引

```
PUT		localhost:9200/blog
```

2. 设置mapping

   ```
   http://localhost:9200/blog2/_mappings/article
   
   {
       "article": {
           "properties": {
               "id": {
               	"type": "long",
                   "store": true
               },
               "title": {
               	"type": "text",
                   "store": true,
                   "analyzer":"standard"
               },
               "content": {
               	"type": "text",
                   "store": true,
                   "analyzer":"standard"
               }
           }
       }
   }
   ```

   

3. 新增索引并设置mapping

```json
PUT		localhost:9200/blog

{
    "mappings": {
        "article": {
            "properties": {
                "id": {
                	"type": "long",
                    "store": true
                },
                "title": {
                	"type": "text",
                    "store": true,
                    "analyzer":"standard"
                },
                "content": {
                	"type": "text",
                    "store": true,
                    "analyzer":"standard"
                }
            }
        }
    }
}
```

4. 新增数据

   ```
   put	http://localhost:9200/blog/article/1
   
   {
   	"id": 1,
   	"title": "hello world",
   	"content": "token_count to count the number of tokens in a string"
   }
   ```

   

5. 删除数据

   ```
   delete	http://localhost:9200/blog/article/1
   ```

6. 修改数据

   ```
   post http://localhost:9200/blog/article/1
   
   {
   	"id": 1,
   	"title": "hello world",
   	"content": "阿萨德法师打发斯蒂芬"
   }
   ```

   

7. 根据id查询数据

   ```
   get	http://localhost:9200/blog/article/1
   ```

   ### 4. 复杂查询

   * query_string查询：

     ```
     post http://localhost:9200/blog/article/_search
     
     {
     	"query":{
     		"query_string":{
     			"default_field": "content",
                 "query": "今年"
     		}
     	}
     }
     ```

     