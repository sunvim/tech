# Docker 配置HTTP/HTTPS代理

1. 创建如下路径的目录

   ```bash
   sudo mkdir -p /etc/systemd/system/docker.service.d
   
   ```

   

2.  设置配置文件

   ```bash
   sudo vim /etc/systemd/system/docker.service.d/http-proxy.conf
   #添加以下内容
   [Service]
   Environment="HTTPS_PROXY=http://127.0.0.1:3945/" "NO_PROXY=localhost,127.0.0.1,registry.docker-cn.com,hub-mirror.c.163.com"
   ```

   

3. 刷新systemd配置 重启docker

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   ```

   

4. 确认配置

   ```bash
   systemctl show --property=Environment docker
   ```

   

5. 总结

   收工