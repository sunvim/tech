# 第三方oAuth认证集锦

## github认证

1. 注册app

   a. 注册github账号

   b. 进入setting--> develop setting-->new OAuth App

2.  创建成功后获取到clientID 和  Client Secret

   测试: curl https://github.com/login/oauth/authorize?client_id=fd3494a12f5173347a17

3. 