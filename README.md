# Sentinel

一个从零开始写操作系统的入门项目。

当前阶段非常小：做一个 512 字节的 BIOS boot sector，让虚拟机像启动硬盘一样加载它，并在屏幕上打印：

```text
Sentinel OS
Hello from the boot sector.
```

这就是操作系统入口的第一步：CPU 从磁盘第一个扇区读入代码，然后跳到 `0x7C00` 执行。

## 项目结构

```text
src/boot/boot.asm      # 第一个入口：BIOS 加载的 16-bit boot sector
scripts/build.ps1      # Windows/MSYS2 构建脚本
scripts/build.cmd      # 绕过 PowerShell 执行策略的构建入口
scripts/run.ps1        # Windows 上用 QEMU 运行镜像
scripts/run.cmd        # 绕过 PowerShell 执行策略的运行入口
Makefile               # WSL/Linux 构建与运行入口
build/                 # 构建输出目录，已加入 .gitignore
```

## 推荐环境：WSL

我检查过你的 WSL，里面已经有：

```text
/usr/bin/nasm
/usr/bin/qemu-system-i386
/usr/bin/make
```

所以最容易上手的是直接用 WSL：

- `nasm` 编译 boot sector
- `make` 管理构建命令
- `qemu-system-i386` 运行生成的镜像

## WSL 用法

进入项目目录：

```sh
cd /mnt/f/work/github/Sentinel
```

构建：

```sh
make
```

检查镜像大小和启动签名：

```sh
make check
```

不弹窗口做一次 QEMU 启动冒烟测试：

```sh
make smoke
```

运行：

```sh
make run
```

清理：

```sh
make clean
```

## Windows/MSYS2 构建

在 PowerShell 里执行：

```powershell
.\scripts\build.cmd
```

成功后会生成：

```text
build/sentinel.img
```

这个镜像正好 512 字节，末尾带有 BIOS 要求的 `0x55AA` 启动签名。

## Windows/MSYS2 运行

如果 QEMU 已经安装并在 PATH 中，或者安装在 `D:\msys64\mingw64\bin`，执行：

```powershell
.\scripts\run.cmd
```

你应该会看到 QEMU 窗口里输出 Sentinel OS 的欢迎文字。

如果还没有 QEMU，可以在 MSYS2 MinGW64 终端里安装：

```sh
pacman -S --needed mingw-w64-x86_64-qemu
```

当前这台机器上，MSYS2 已有 NASM，但我没有找到 Windows 侧的 QEMU；WSL 侧已经准备好了完整工具链。

## Linux 依赖安装

如果以后换一台新的 WSL/Linux 环境，安装：

```sh
sudo apt update
sudo apt install -y nasm qemu-system-x86 make
```

## 下一步学习路线

1. 理解 `src/boot/boot.asm`：`org 0x7C00`、段寄存器、栈、BIOS 中断、启动签名。
2. 在 boot sector 里读取更多磁盘扇区。
3. 从 boot sector 加载一个更大的 kernel。
4. 进入 32-bit protected mode。
5. 用 C 或 Rust 写内核主体。

这个项目先故意保持极小。能启动、能打印、能反复修改验证，就是写 OS 最重要的第一块地基。
