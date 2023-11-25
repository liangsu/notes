## mybatis xml解析


SqlSource： 原始的sql语句
	DynamicSqlSource  sql中带有"$"符号、或者带有trim/where/set/foreach/if/choose/when/otherwise/bind/等标签的
	RawSqlSource xml解析中，如果不是`DynamicSqlSource`就是这个原生的sqlSource
	
	ProviderSqlSource
	StaticSqlSource
	VelocitySqlSource
	
	
BoundSql： 根据参数生成的sql语句，简称：绑定了的sql


SqlNode
	StaticTextSqlNode  一般sql，含有"#"
	TextSqlNode sql语句中有$符号，如：`where ${field} = #{fieldValue}`
	
	IfSqlNode
	WhereSqlNode
	ChooseSqlNode
	ForEachSqlNode
	SetSqlNode
	TrimSqlNode  
	VarDeclSqlNode `bind`标签的解析
	
	MixedSqlNode: 表示sql语句是混合的，包含多种类型，一般作为根节点，或者某些标签节点`WhereSqlNode``SetSqlNode`的子节点


<update id="updateAuthorIfNecessary" parameterType="org.apache.ibatis.domain.blog.Author">
    update Author
    <set>
      <if test="username != null">username=#{username},</if>
      <if test="password != null">password=#{password},</if>
    </set>
    where id=#{id}
</update>
 
 
 
 <bind>: 元素允许你在 OGNL 表达式以外创建一个变量，并将其绑定到当前的上下文
 
 <select id="selectBlogsLike" resultType="Blog">
  <bind name="pattern" value="'%' + _parameter.getTitle() + '%'" />
  SELECT * FROM BLOG
  WHERE title LIKE #{pattern}
</select>

 
<trim prefix="WHERE" prefixOverrides="AND |OR ">
  ...
</trim>













