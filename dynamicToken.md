# Vault 配置数据库动态凭证手册

## step 1: 打开 

```bash
vault secrets enable database   
```

## step 2: 配置MySQL数据库信息   
```bash
vault write database/config/ankr_mysql \
    plugin_name=mysql-database-plugin \
    connection_url="root:Mysql#123@tcp(192.168.1.242:3306)/" \
    allowed_roles="my-role" 
```



## step 3: 创建角色

```bash
vault write database/roles/my-role \
    db_name=ankr_mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="5m"   max_ttl="10m"
```



## step 4: 获取动态密钥

```bash
vault read database/creds/my-role

Key                Value
---                -----
lease_id           database/creds/my-role/Eg41dRiK0T2Dvyiec3gauUcN
lease_duration     5m
lease_renewable    true
password           A1a-1gbNJlcla4Mnt9mn
username           v-token-my-role-7QasxOTHGDWiAgNv
```





