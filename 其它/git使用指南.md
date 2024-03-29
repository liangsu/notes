# git

## 配置
1. git ssh key （百度）

2. 代理配置
```
git config --global https.proxy http://127.0.0.1:1080
git config --global https.proxy https://127.0.0.1:1080
git config --global --unset http.proxy
git config --global --unset https.proxy
npm config delete proxy
git config --global http.proxy 'socks5://127.0.0.1:1080'
git config --global https.proxy 'socks5://127.0.0.1:1080'
```

3. 配置忽略文件.gitignore，在项目根目录下新建文件.gitignore，内容：
```
// 忽略所有的txt的文件
*.txt

// 除了a.txt可以提交外
!a.txt

// 忽略整个文件夹
/test

// 忽略这个文件夹下的所有txt文件，但是没有忽略文件夹下的子文件夹的txt文件 /test/other/*.txt 
/test/*.txt

// 忽略这个文件夹及其子文件夹下的所有txt文件
/test/**/*.txt
```

4. 中文乱码，在输入git status会出现中文乱码的问题，解决办法：
方式1：
```
git config --global core.quotepath false
```

方式2：
右键 -- Options -- Text --Character set 选中UTF-8


## 新建仓库
1. 新建一个项目文件夹
2. 鼠标右键菜单， 点击git bash here
3. 执行git init 命令，这时会在项目文件夹下产生.git的一个隐藏文件夹

## git工作区域
1. 工作区（Working Directory）
2. 暂存区stage（或者叫index）
3. 版本库（Repository）
4. 一个文件是从 工作区 -> 暂存区 -> 仓库


## 基本操作
1. 查看文件状态处于工作区、暂存区、还是已提交的命令： git status
2. 将新增/修改的文件加入暂存区： git add <file>
3. 将文件从暂存区删除： git reset HEAD <file> 或者 git rm --cached <file>
4. 将文件删除，工作区不删除：git rm --cached <file>
5. 将一个修改过的文件恢复到修改前的版本： git checkout <file>
6. 将文件从版本库删除： git rm <file>
7. 版本库中修改资料名称（如果使用手动修改文件名，是执行的先删除后新增，文件版本日志会丢失，而使用这种方式便不会出现问题）： git mv <file> <to-file>
8. 日志查看： git log，其它参数百度
9. amend修改最新一次提交事件日志或者把暂存区的文件追加到最后的一次提交中去： git commit -amend

## alias命令别名提高操作效率
1. git的命令比较长，为了提高操作效率，给命令设置别名，例如使用 git s 代替 git status
2. 设置别名的命令： git config --global alias.s status
3. 或者通过修改文件.gitconfig实现 
4. 修改系统级别的别名：
	* 切换到git家目录：cd
	* 打开文件.bash_profile，没有则创建
	* 在这个文件中添加内容： 
	```
		alias gau='git add --update'
		alias gb='git branch'
	```

## git分支管理

							-----------提交4---提交5---------------------------- ask（问答模块的分支）
						   /						\
                          /							 \
------提交1----提交2----提交3--------------------------------------------------------------------------------  master
						  \									/
						   \					           /
							-----------提交6----提交7----提交8------------------------------------------- bbs（论坛模块分支）


1. 查看分支 git branch， *号所在的分支，是当前分支，如下当前分支是在bbs分支下
```
	$ git branch
	  ask
	* bbs
	  master
```
2. 创建ask分支： git branch ask
3. 切换到ask分支： git checkout ask
4. 创建并切换到bbs分支：git checkout -b bbs

5. 合并分支，当我们在ask分支上提交文件后，我们要把ask分支的内容合并到master分支，需要先切换回master分支，然后执行命令：`git merge ask`
```
	$ git merge ask
	Updating 1d3e3aa..024c1a8
	Fast-forward
	 ask.txt | 1 +
	 1 file changed, 1 insertion(+)
	 create mode 100644 ask.txt
```
6. 合并分支解决冲突：如果执行合并的时候，报有冲突，先找到冲突文件，然后解决冲突，然后执行提交到本分支
```
git merge ask
// 这里解决冲突，修改冲突文件
git add .
git commit -m ''
```

7. 删除分支： 当我们把ask分支的内容合并到master分支后，ask分支其实就没有什么用了，我们可以删除掉ask分支： `git branch -d ask`，如果删除没有合并的分支会报错，需要执行：`git branch -D ask`
8. 查看合并了的分支，先切换到主分支，然后执行： git branch --merged
9. 查看合并了的分支，先切换到主分支，然后执行： git branch --no-merged


## stash临时储存区
背景：当我们在一个分支1上进行修改了代码，这时候修改的文件还不具备提交的条件，但是又需要切换另一个分支2上去操作，如果直接切换会报错，这时我们可以先将分支1的内容stash存储一下，
然后再切换分支2去做你的操作，操作完了之后，当你切回分支1进行时，你可以从stash中恢复你之前没有提交的修改

1. 创建stash： git stash
2. 查看临时存储区： git stash list
3. 恢复临时存储区： git stash apply stash@{0}
4. 删除临时存储区： git stash drop stash@{0}
4. 恢复临时存储区并删除： git stash pop

## 使用TAG标签声明项目阶段版本
背景： 当我们开发的项目时，到达了某一个节点时，便可以给发布的这套代码打一个标签

1. 查看标签： git tag
2. 打上标签： git tag v1.0

3. 列出所有tag
```
git tag //默认显示
git tag -l
git tag -n //查看所有tag和说明
git tag -l v1.* //查看匹配到的tag
git ls-remote --tags origin //查看远程所有tag
```


## 生成zip代码发布压缩包
1. 命令： git archive master --prefix='test/' --forma=zip > test.zip
* --prefix： 压缩文件到哪个文件夹下

## 合并分支的问题：
背景： 一个项目的master分支，由项目管理员维护，当要开发一个功能模块时，创建了一个分支ask，ask分支在提交的这段时间中，又有其他人往master做过提交，当ask分支的功能开发完成需要合并到master
的时候，ask开发者通知master的项目管理员，项目管理员合并代码势必会产生冲突，且不知道怎么解决ask开发者的冲突，这时候需要ask开发者重新rebase他自己的ask分支然后解决冲突，再通知项目管理员
去合并分支，这时项目管理员合并分支就不会出现解决冲突的情况了

1. 刚开始开发的分支结构如下：

							-----------提交4---提交5---------------------------- ask（问答模块的分支）
						   /						
                          /							 
------提交1----提交2----提交3---------提交6--------------------------------------------------------------------  master
				
2. rebase分支后
									-----------提交4---提交5---------------------------- ask（问答模块的分支）
								   /						
								  /							 
------提交1----提交2----提交3---提交6--------------------------------------------------------------------  master
		
				
3. rebase操作：
```
// 切换到ask分支，执行rebase命令
git rebase master

// 这时候如果有冲突，可以用git status查看，解决冲突文件，并将冲突文件加入到暂存区
git add <file>

// 冲突文件解决后执行继续合并的操作，这时候rebase成功
git rebase --continue
```
4. 做完上面的的操作，再回到master分支，执行合并分支的时候，就不会出现冲突，也不用解决冲突了





## 远程分支操作：
1. 克隆一个远程分支并提交：
```
// 克隆一个远程分支： 
git clone git@github.com:liangsu/test.git

// .这里做你要添加修改的文件，并提交到本地仓库

// 将本地分支提交到远程：
git push
```

2. 将本地分支关联到一个空的远程分支并提交
```
// 将本地分支关联到一个空的远程分支： 
git remote add origin git@github.com:liangsu/test.git

// 查看远程分支版本： git remote -v

// 将本地当前所在分支推送到远程master分支： 
git push origin master
```

3. 一个克隆到了本地的项目，在本地新建了分支，需要推送到远程的新建分支
```
// 切换当前分支为要推送的分支bbs
git checkout bbs

// 然后将当前分支推送到远程bbs分支
git push --set-upstream origin bbs
```

4. 一个克隆到了本地的项目，远程新建了ask分支，要将这个分支拉取到本地，并创建ask分支
```
// 将远程test分支检到本地test分支
git pull origin test:test

// 查看本地分支，会发现本地分支多了一个test
git branch -a
```

5. 删除远程分支ask
```
git push origin --delete ask
```

6. 将本地新建git项目，推送到远程仓库（采用强制推送）
```
//强制推送到远程（可能会覆盖远程上已有的分支或文件）
//注意：仅第一次需要这样执行，后续在推送代码时，git push 命令不需要再加上 -u 或者 -f 命令，使用正常推送命令就行了。
git push -u origin master -f
```

7. 从远程仓库里拉取一条本地不存在的分支时：
```
git checkout -b 本地分支名 origin/远程分支名
```


8. 合并提交记录
git rebase -i asdfasd
编辑vim并保存
修改提交消息

9. 将某一段commit粘贴到另一个分支上



10. 假设我想将我的linux分支内容替换master分支的内容。
```
# 切换到master分支
git checkout master
# 再将本地的master分支重置成linux
git reset --hard uat  
# 最后推送到远程仓库master分支
git push origin master --force 
```



问题： 更新远程仓库，并解决冲突

## 统计

1. 统计某个作者提交代码行数
```
git log --author=<作者> --pretty=tformat: --numstat | awk '{ add += $1 - $2 } END { printf "Total Lines: %s\n", add }'
```



## git开发流程

1. 从远程仓库将项目clone下来，比如有master、bbs、ask分支
2. 如果你要基于bbs分支开发，那么你需要先基于bbs创建一个新的分支bbs2
3. 当你基于bbs做了一些提交之后，你想push到远程仓库，你可以先切换到bbs分支，pull代码，防止别个有新的提交，如果有新的提交，先rebase bbs2分支，然后切换到bbs分支，合并bbs2分支到bbs分支

## git升级
方式1：
 去官网[https://git-scm.com/downloads]下载新的安装包覆盖安装，不过这样比较麻烦，而且每次还要去看看有没有新版本

方式2：
```
git update-git-for-windows
```

## git秘钥

1. 生成秘钥
```
ssh-keygen -t rsa -C 邮箱
```

2. 查看秘钥
```
cd ~/.ssh

cat id_rsa.pub
```




