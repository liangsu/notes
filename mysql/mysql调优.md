
show profiles


mysql performance schemal 详解


pscache

物化视图


回表：普通索引的叶子节点存储的是id，查询数据的时候先根据普通索引找到id，再通过id去主键索引查询数据
覆盖索引：查询的数据在索引里面就能找到，比如查询id的时候走了一个普通索引
索引下推：
	在有索引(name, age)的情况下，查询姓张的且年龄大于20岁的人员，where name like '张%' and age > 20，查询方式：
		1. 先查询所有姓张的ids，然后回表查询这些数据，再过滤出age大于20岁的人
		2. 在索引扫描的时候，就过滤出age大于20的人员ids，再回表查询这些数据
	适用情况：


3个查询：
where name = ? and age = ?
where name = ?
where age = ?

如果希望3个查询都能走索引，怎么建立索引：
方式一：  (name, age), age
方式二： (age, name), name
方式1更好，由于name列的长度比age列大，所以方式2的索引文件大于方式1的索引文件，索引文件小能够节省磁盘IO



SELECT e.imei AS imei, e.gpsno AS gpsno, e.model_type AS modelType, e.truck_no AS truckNo, e.truck_id AS truckId, 
		e.active_current_days AS activeCurrentDays, e.active_history_days AS activeHistoryDays, e.capability AS capability, 
		e.out_time AS outTime, e.service_status AS serviceStatus, e.serv_start_time AS servStartTime, e.serv_end_time AS servEndTime, 
		(select count(*) from intelligence_equipment_data) as totalcount 
FROM intelligence_equipment_data e 
inner join ( 
	select id 
	from intelligence_equipment_data 
	where 1 = 1 AND e.truck_no IN #{truckNo} AND e.truck_id IN #{truckId} AND e.imei IN #{imei} AND e.gpsno IN #{gspno} 
		AND e.model_type = #{modelType} AND e.active_history_days = #{activeHistoryDays} AND FIND_IN_SET(#{item},e.capability) 
		AND e.out_time >= #{outTimeStart} AND e.out_time <= #{outTimeEnd} LIMIT 1000000,10 
) t on e.id = t.id




hash索引： memory存储引擎才支持

聚簇索引：		索引数据 + 数据 放在同一个文件
聚簇组索引：	数据文件跟索引文件分开放


hyperloglog



SELECT
        e.imei AS imei,
        e.gpsno AS gpsno,
        e.model_type AS modelType,
        e.truck_no AS truckNo,
        e.truck_id AS truckId,
        e.active_current_days AS activeCurrentDays,
        e.active_history_days AS activeHistoryDays,
        e.capability AS capability,
        e.out_time AS outTime,
        e.service_status AS serviceStatus,
        e.serv_start_time AS servStartTime,
        e.serv_end_time AS servEndTime
        FROM
        intelligence_equipment_data e
        WHERE
        e.id > (
        select id from intelligence_equipment_data
        where
        1 = 1
        <if test="truckNos !=null and truckNos.size > 0">
            AND e.truck_no IN
            <foreach collection="truckNos" item="truckNo" index="index" open="(" close=")" separator=",">
                #{truckNo}
            </foreach>
        </if>
        <if test="truckIds !=null and truckIds.size > 0">
            AND e.truck_id IN
            <foreach collection="truckIds" item="truckId" index="index" open="(" close=")" separator=",">
                #{truckId}
            </foreach>
        </if>
        <if test="imeis !=null and imeis.size > 0">
            AND e.imei IN
            <foreach collection="imeis" item="imei" index="index" open="(" close=")" separator=",">
                #{imei}
            </foreach>
        </if>
        <if test="gspnos !=null and gspnos.size > 0">
            AND e.gpsno IN
            <foreach collection="gspnos" item="gspno" index="index" open="(" close=")" separator=",">
                #{gspno}
            </foreach>
        </if>
        <if test="modelType !=null and modelType != ''">
            AND e.model_type = #{modelType}
        </if>
        <if test="activeHistoryDays !=null">
            AND e.active_history_days = #{activeHistoryDays}
        </if>
        <if test="capabilitys !=null and capabilitys.size > 0">
            <foreach collection="capabilitys" item="item" index="index" separator=" ">
                AND FIND_IN_SET(#{item},e.capabili