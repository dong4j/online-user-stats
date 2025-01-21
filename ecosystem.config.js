module.exports = {
  apps: [
    {
      name: "time-counter-server",
      namespace: 'blog', // 指定命名空间
      version: '1.0.0', // 应用版本
      cwd: "/mnt/4.860.ssd/time-counter",
      script: "./counter",
      args: "", // 传递给脚本的参数
      interpreter: "",
      env: {},
      exec_mode: "fork",
      instances: 1, // 使用两个实例，你可以根据需要调整
      autorestart: true,
      watch: false, // 是否启用文件监控
      error_file: "./logs/error.log", // 错误日志路径
      out_file: "./logs/output.log", // 输出日志路径
      log_date_format: "YYYY-MM-DD HH:mm:ss", // 日志时间格式
    },
  ],
};
