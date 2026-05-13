# PID调参助手

极简版黑盒日志分析工具，用于 FPV 穿越机 PID 调参。

## 功能

- 📊 分析黑盒日志（.bbl/.txt/.log）
- 📈 显示阶跃响应曲线
- 🎯 计算 Overshoot 并给出 PID 建议
- 📁 保存飞机配置档案

## 下载

前往 [Releases](../../releases) 下载最新 APK。

## 使用

1. 选择日志文件
2. 点击"开始分析"
3. 查看结果和 PID 建议
4. 可选：保存到档案

## 调参口诀

```
机械先行，P 打基础，D 控过冲，
FF 追跟随，I 保稳定，滤波最后动。
```

## 技术栈

- Flutter
- SharedPreferences（本地存储）
- FL Chart（图表）

---

Made with ❤️ for FPV pilots