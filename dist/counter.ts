(function () {
    let current: HTMLOrSVGScriptElement = document.currentScript,
        interval: string = current.getAttribute("interval") || "60000", // 默认间隔 60 秒
        room: string = current.getAttribute("room") || "", // 房间号
        api: string = current.getAttribute("api") || "http://localhost:8080/counter"; // API 地址

    // 主循环函数
    const loop = () => {
        try {
            let xhr: XMLHttpRequest = new XMLHttpRequest();

            let url = api;
            if (room !== "") url = `${api}?room=${room}`; // 拼接房间号参数

            xhr.open("GET", url, true);

            // 添加 Token 认证头部
            let token = localStorage.getItem("time-counter-uuid");
            if (token !== null) xhr.setRequestHeader("Authorization", "Bearer " + token);

            xhr.onload = () => {
                if (xhr.status === 200) {
                    try {
                        let res = JSON.parse(xhr.responseText);
                        if (res.success === true) {
                            let data = res.data;

                            // 更新在线人数和状态指示灯
                            updateOnlineStatus(Number(data.online_user)); // 确保传递数字类型

                            // 设置新 Token（如果服务器返回）
                            let setToken = xhr.getResponseHeader("uuid");
                            if (token === null && setToken !== null) {
                                localStorage.setItem("time-counter-uuid", setToken);
                            }

                            // 设置下一次调用的定时器
                            setTimeout(loop, parseInt(interval));
                        } else {
                            console.error("API Response Error: ", res.message);
                            alert(res.message);
                        }
                    } catch (err) {
                        console.error("JSON Parse Error: ", err);
                    }
                } else {
                    console.error("Request Failed: ", xhr.status, xhr.statusText);
                }
            };

            xhr.onerror = () => {
                console.error("Network Error: Unable to reach API");
            };

            xhr.send();
        } catch (err) {
            console.error("Unexpected Error: ", err);
        }
    };

    // 更新在线人数和指示灯状态
    const updateOnlineStatus = (onlineCount: number) => {
        const onlineUserElement = document.getElementById("online_user");
        const indicatorElement = document.getElementById("indicator");

        if (onlineUserElement && indicatorElement) {
            // 更新在线人数显示
            onlineUserElement.textContent = String(onlineCount);

            // 根据在线人数更新指示灯颜色
            if (onlineCount > 0) {
                indicatorElement.style.backgroundColor = "green"; // 大于 1 人时显示绿色
            } else {
                indicatorElement.style.backgroundColor = "red"; // 1 人或更少时显示红色
            }
        }
    };

    // 格式化时间（如有需要可用作显示）
    const formatTime = (time: number): string => {
        let day = Math.floor(time / (60 * 60 * 24));
        let hour = Math.floor((time % (60 * 60 * 24)) / (60 * 60));
        let minute = Math.floor((time % (60 * 60)) / 60);
        let second = Math.floor(time % 60);
        return `${day}d ${hour}h ${minute}m ${second}s`;
    };

    // 启动循环
    loop();
})();