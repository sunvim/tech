# 创建基本的`webpack 4.x `项目步骤

1. 运行 `npm init -y`快速初始化项目

2. 创建`src`目录存放项目源代码, `dist`存放发布目录

3. 在`src`目录 创建`index.html & index.js`两个文件

4. 安装`webpack`, 运行`npm i webpack webpack-cli -g`, 可以运行`npm i cnpm -g`来执行安装cnpm

5. 在项目根目录下新建一个文件: `touch webpack.config.js`,内容如下所示:

   ```bash
   //向外暴露一个打包的配置对象
   module.exports = {
       mode: 'development'  // production  development
   }
   ```

6. 输出: `dist目录下产生一个 main.js文件`
7. 在`package.json`文件中的`scripts`位置,新增`"dev": "webpack-dev-server"`, 接着运行`npm run dev`,能实时监控文件变化
8. 安装`npm i html-webpack-plugin` 使得`index.html`文件也可以放在内存中
9. 安装`npm i react react-dom -S`  开发环境



# `React`使用步骤

1. 引入必要的包 

   ```javascript
   import React from 'react'                  // 创建组件 vdom 管理元素生命周期
   import ReactDOM from 'react-dom' // 将创建好的元素展示到页面上
   ```

2. 创建DOM元素

   ```javascript
   // arg 1: DOM element name
   // arg 2: DOM element attribute
   // arg ...: child node or text
   // ex: <h1 id="myh1" title="this is my h1"> big h1</h1>
   const myh1 = React.createElement('h1',
       {id:'myh1',title:"this is my h1"},
       'big H1')
   ```

3. 渲染DOM元素至页面上

```javascript
ReactDOM.render(myh1,document.getElementById('app'))
```

4. 在页面创建放置DOM元素的容器

   ```javascript
   <div id="app"></div>
   ```

   

# `JSX`使用前提

1. 安装`babel`来转换XML语法的标记语句

   ```bash
   npm i babel-core babel-loader@7 babel-plugin-transform-runtime -D
   npm i babel-preset-env babel-preset-stage-0 -D
   npm i babel-preset-react -D
   ```

   

2. 在项目根目录中添加配置文件`.babelrc`

```bash
{
    "presets":[ "env", "stage-0", "react"],
    "plugins": ["transform-runtime"]
}
```

