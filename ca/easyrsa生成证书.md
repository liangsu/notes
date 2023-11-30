# easyrsa生成证书

下载地址：
https://github.com/OpenVPN/easy-rsa/releases/tag/v3.1.1

参考文档：
http://babamumu.com/archives/openvpn
https://zhuanlan.zhihu.com/p/553446054


初始化一个工作目录：用于存放证书的文件夹
```
easyrsa init-pki
```


设置配置文件vars
```


```

生成根证书, nopass表示不需要密码
```
easyrsa build-ca nopass

Enter New CA Key Passphrase: 123456
Re-Enter New CA Key Passphrase: 123456
Enter PEM pass phrase: 123456
Verifying - Enter PEM pass phrase: 123456
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:liangsu
```


生成证书申请，nopass参数表示不对私钥进行加密
```
easyrsa gen-req ${servername} nopass
```

给服务器端证书`${servername}`进行签名
```
easyrsa sign ${servername} server
```

然后创建Diffie-Hellman文件，也就是秘钥交换时的DH算法，确保密钥可以穿越不安全网络。 会生成文件`dh.pem`
```
easyrsa gen-dh
```


## 根证书导入

使用了私自签发的证书后，用浏览器访问本地的站点，会发现浏览器报不安全，要点好几次，才可以真的进入，还会有一个红色的警告。如果嫌麻烦的话，
可以把跟证书，导入到系统的信任证书中。就是咱们在创建 CA 的时候，生成的 CA.crt ，在各种操作系统里，基本双击就可以激活导入程序了，询问的时候，
都点“信任”就可以了。你自己生成的证书，也没什么可怕的了。


https://charlestang.github.io/use-easyrsa-create-self-signed-cert/



{
  "code": 0,
  "data": {},
  "message": "token 无效：bea60dce-e5be-403f-a6a9-294e3ba65737",
  "serverTime": 1697263424,
  "status": 500,
  "success": false
}








