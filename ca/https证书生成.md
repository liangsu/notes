# https证书生成

参考： 

[链接1]: https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
[链接2]: https://blog.csdn.net/cuitone/article/details/87966042
[SAN证书的生成]: https://my.oschina.net/sskxyz/blog/1554093?utm_source=debugrun&amp;utm_medium=referral

本文使用openssl生成ca证书

1. 生成根证书

1. 生成服务端证书

## 1. 创建根证书

### 准备文件夹

使用`/root/ca`去存储所有的密钥key和证书

```shell
# mkdir /root/ca
```

创建目录结构。txt和串行文件充当一个平面文件数据库，用来跟踪已签名的证书

```shell
# cd /root/ca
# mkdir certs crl newcerts private
# chmod 700 private
# touch index.txt
# echo 1000 > serial
```

使用AES 256位加密和强密码对根密钥进行加密
```
openssl genrsa -aes256 -out root/root.key.pem 4096
```

创建根证书
```
openssl req -config openssl.cnf \
      -key root/root.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out root/root.cert.pem
	  
```	  





### 准备配置文件

你必须准备一个openssl的配置文件，复制下方的内容到`/root/ca/openssl.cnf`



## 2. 生成服务端证书

### 生成证书申请文件

```shell
openssl req -new -nodes -keyout server.key -out server.csr -config /root/ca/openssl.cnf
```

### 签署证书

```shell
openssl ca -config openssl.cnf \
  -extensions server_cert -days 375 -notext -md sha256 \
  -in www.ls.com/server.csr \
  -out www.ls.com/server.crt
```

openssl ca -config openssl.cnf  -extensions server_cert -days 375 -notext -md sha256  -in openvpn/server.csr -out openvpn/server.cert


因为只有带SAN(Subject Alternative Name，中文：使用者可选名称)字段的证书，google浏览器才不会报连接不安全，如果需要生成的证书带SAN字段，需要在req段落增加下面配置:

```cnf
req_extensions=v3_req
```

这段配置表示在生成 CSR 文件时读取名叫 `v3_req` 的段落的配置信息，因此我们再在此配置文件中加入一段名为 `v3_req` 的配置：

```properties
[ v3_req ]
# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
```

这段配置中最重要的是在最后导入名为 `alt_names` 的配置段，因此我们还需要添加一个名为 `[ alt_names ]` 的配置段：

```properties
[ alt_names ]
DNS.1 = www.ls.com
DNS.2 = www.test.ls.com
```









​	   