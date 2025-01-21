## online-user-stats

> just a simple online user/time counter

## Update

1. 支持设置多个允许跨域的域名;
2. 修复安全告警;
3. 添加自动化部署脚本;
4. 增加在线人数统计样式;

已在 [个人主页](https://home.dong4j.site/) 上使用.

## Build

1. `git clone https://github.com/soxft/time-counter && cd time-counter`
2. `go build -o counter main.go`
3. 根据提示修改 config.yml
4. 编辑 dist/counter.js 替换链接为自己的, 也可以编辑ts文件自行编译
5. 通过命令 ./counter 启动程序


### 用法：

1. Iframe 引入

```
<center><iframe frameborder=0  height=50px marginwidth=0 scrolling=no src="https://127.0.0.1:3000/room/{Room ID}"></iframe></center>
```

1. JS 引入

```
<script src="https://127.0.0.1:3000/counter.js" async="" id="online-counter" interval="240" api="https://127.0.0.1:3000/counter" room="{Room ID}"></script>

本站当前在线人数 <span style="color: red;" id="online_user"></span> 人

你的在线总时间:  <span style="color: red;" id="online_me"></span>

全站在线总时间:  <span style="color: red;" id="online_total"></span>
```



1. Pjax（例如 Hexo butterfly 主题，若开启了全局播放器 请使用此方案）

```
// 若您的网站有 Pjax 等局部热加载技术，请参考以下代码（Pjax 似乎会忽略 script 的标签内传值）。

      
本站当前在线人数 <span style="color: red;" id="online_user"></span> 人  
你的在线总时间:  <span style="color: red;" id="online_me"></span> 
全站在线总时间:  <span style="color: red;" id="online_total"></span>

      
<script>
    (
function () {

      
getOnlineUser()

      
function getOnlineUser() {
    // 移除之前的 online-counter
    let oldScript = document.getElementById("online-counter");
    if (oldScript) {
        oldScript.remove();
    }
    //create script
    let script = document.createElement("script");
    script.src = "https://127.0.0.1:3000/counter.js";
    script.async = true;
    script.id = "online-counter";
    script.setAttribute("interval", 240);
    script.setAttribute("api", "https://127.0.0.1:3000/counter");
    script.setAttribute("room", "{Room ID}");
    document.head.appendChild(script);
}

      
}
)()
</script>s
```

## Todo

- [ ] 部署说明

## 来源

- [time-counter](https://github.com/soxft/time-counter)
- [原使用说明](https://time-counter.icodeq.com/)