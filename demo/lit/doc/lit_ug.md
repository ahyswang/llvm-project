# LLVM LIT (LLVM Integrated Tester) 详细使用指南

LLVM LIT 是 LLVM 项目中的轻量级测试工具，用于执行 LLVM 和 Clang 等项目的回归测试。以下是 LLVM LIT 的详细使用方法。

## 1. 安装 LIT

LIT 通常作为 LLVM 项目的一部分安装，也可以通过 pip 单独安装：

```bash
pip install lit
```

## 2. 基本使用

### 运行测试

```bash
lit [options] [test directories or files]
```

常用选项：
- `-v`：详细输出
- `-a`：显示所有测试输出（包括通过的测试）
- `--param PARAM=VALUE`：设置测试参数
- `--filter=REGEX`：只运行匹配正则表达式的测试
- `--shuffle`：随机顺序执行测试
- `--time-tests`：显示测试执行时间

### 示例

```bash
# 运行指定目录下的所有测试
lit ./test

# 运行单个测试文件
lit ./test/foo.ll

# 详细模式运行
lit -v ./test
```

## 3. 测试文件格式

LIT 测试文件通常包含两部分：
1. 测试命令和预期输出（使用 `RUN:` 前缀）
2. 测试检查指令（使用 `CHECK:` 前缀）

### 示例测试文件 (test.ll)

```
; RUN: opt -S -instcombine < %s | FileCheck %s

define i32 @foo(i32 %a) {
  %b = add i32 %a, 0
  ret i32 %b
}

; CHECK-LABEL: @foo
; CHECK-NOT: add i32 %a, 0
; CHECK: ret i32 %a
```

## 4. 测试指令详解

### RUN 指令

指定要运行的命令，可以使用变量：
- `%s`：当前测试文件路径
- `%t`：临时文件路径

```
; RUN: opt -S -instcombine < %s > %t
; RUN: FileCheck %s < %t
```

### CHECK 指令

验证命令输出：
- `CHECK:`：匹配任意行
- `CHECK-NEXT:`：匹配下一行
- `CHECK-NOT:`：确保不匹配
- `CHECK-LABEL:`：标记测试部分
- `CHECK-DAG:`：无序匹配
- `CHECK-SAME:`：在同一行匹配

### 正则表达式

可以在 CHECK 指令中使用正则表达式：
```
; CHECK: add i32 {{\d+}}, 0
```

## 5. 配置测试

### lit.cfg.py

测试目录可以包含 `lit.cfg.py` 配置文件：

```python
import lit.formats

config.name = 'My Test Suite'
config.test_format = lit.formats.ShTest(execute_external=True)
config.suffixes = ['.ll', '.c']
config.excludes = ['broken.ll']
config.substitutions = [('%clang', '/path/to/clang')]
```

### 常用配置选项

- `test_format`：测试格式（ShTest, TclTest等）
- `suffixes`：要处理的文件后缀
- `excludes`：排除的文件
- `substitutions`：命令替换
- `test_source_root`：测试源根目录
- `test_exec_root`：测试执行根目录

## 6. 高级功能

### 并行测试

使用 `-j` 选项并行运行测试：
```bash
lit -j 4 ./test  # 使用4个线程
```

### XFAIL 标记预期失败的测试

在测试文件中添加：
```
; XFAIL: *
```

### REQUIRES 和 UNSUPPORTED

指定测试要求：
```
; REQUIRES: x86-registered-target
; UNSUPPORTED: windows
```

### 自定义测试格式

可以继承 `lit.TestFormat` 创建自定义测试格式。

## 7. 调试技巧

- 使用 `--debug` 显示调试信息
- 使用 `--show-all` 显示所有输出
- 使用 `--filter` 隔离特定测试
- 使用 `--verbose` 查看详细执行过程

## 8. 集成到构建系统

可以在 CMake 中使用 `llvm-lit`：

```cmake
find_program(LLVM_LIT llvm-lit)

add_custom_target(check-all
  COMMAND ${LLVM_LIT} ${CMAKE_CURRENT_SOURCE_DIR}/test
  DEPENDS your-target
  COMMENT "Running regression tests"
)
```