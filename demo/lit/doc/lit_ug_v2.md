
LLVM 的 **lit**（LLVM Integrated Tester）配合 **FileCheck** 是 LLVM / MLIR / Clang 项目的核心测试系统之一。

下面我会分三部分系统介绍 lit 的语法与用法：

---

## 一、lit 基础结构

一个 `.mlir`, `.ll`, `.c`, `.cpp`, `.test` 文件都可以是 lit 测试文件。
其核心是 **特殊注释命令**：

```
// RUN: ...
```

lit 会读取这些 `RUN:` 行，然后执行命令，将命令输出交给 `FileCheck` 或其他工具进行验证。

---

## 二、lit 常用命令语法

| 指令                            | 含义                        | 示例                                  |               |
| ----------------------------- | ------------------------- | ----------------------------------- | ------------- |
| `RUN:`                        | 指定要执行的命令                  | `// RUN: mlir-opt %s                | FileCheck %s` |
| `XFAIL:`                      | 标记此测试预期失败                 | `// XFAIL: *` 或 `// XFAIL: aarch64` |               |
| `REQUIRES:`                   | 仅在满足某条件时运行                | `// REQUIRES: asserts`              |               |
| `UNSUPPORTED:`                | 在某些平台不运行                  | `// UNSUPPORTED: windows`           |               |
| `CHECK:`                      | 顺序匹配输出                    | `// CHECK: foo`                     |               |
| `CHECK-NEXT:`                 | 必须紧接上一行                   | `// CHECK-NEXT: bar`                |               |
| `CHECK-SAME:`                 | 同一行匹配                     | `// CHECK-SAME: baz`                |               |
| `CHECK-DAG:`                  | 无序匹配                      | `// CHECK-DAG: %x = ...`            |               |
| `CHECK-NOT:`                  | 确保未出现某模式                  | `// CHECK-NOT: error`               |               |
| `CHECK-LABEL:`                | 匹配标签，重置匹配起点               | `// CHECK-LABEL: func @main`        |               |
| `CHECK-COUNT-N:`              | 匹配模式 N 次                  | `// CHECK-COUNT-3: add`             |               |
| `CHECK-EMPTY:`                | 匹配空行                      | `// CHECK-EMPTY:`                   |               |
| `CHECK-START:` / `CHECK-END:` | 指定匹配范围（较少用）               | `// CHECK-START: foo`               |               |
| `CHECK-IF:` / `CHECK-END-IF:` | 条件匹配 (FileCheck >= 14 支持) | `// CHECK-IF: foo_enabled`          |               |
| `%s`, `%t`, `%p`, `%S` 等变量    | lit 内置路径变量                | 见下表 👇                              |               |

---

## 三、lit 内置变量

| 变量                       | 含义                  |
| ------------------------ | ------------------- |
| `%s`                     | 当前测试文件路径            |
| `%t`                     | 临时文件路径（可写）          |
| `%T`                     | 临时目录                |
| `%p`                     | 当前测试文件所在目录          |
| `%S`                     | 当前测试文件所在源目录         |
| `%{pathsep}`             | 系统路径分隔符 (`:` 或 `;`) |
| `%clang`, `%clang_cc1` 等 | LLVM 工具别名（配置时定义）    |

示例：

```
// RUN: mlir-opt %s -canonicalize -o %t
// RUN: FileCheck %s < %t
```

---

## 四、FileCheck 模式语法详解

FileCheck 是 lit 最常用的验证工具。支持丰富的匹配语法：

| 语法              | 含义        | 示例                                  |
| --------------- | --------- | ----------------------------------- |
| `[[VAR:regex]]` | 定义捕获变量    | `// CHECK: [[X:%.*]] = arith.addi`  |
| `[[VAR]]`       | 使用变量      | `// CHECK: arith.subi [[X]], [[Y]]` |
| `{{regex}}`     | 直接正则匹配    | `// CHECK: {{[0-9]+}}`              |
| `{{.*}}`        | 匹配任意字符    | `// CHECK: {{.*}}foo{{.*}}`         |
| `CHECK-LABEL:`  | 重定位起点     | `// CHECK-LABEL: func @main`        |
| `CHECK-NEXT:`   | 必须紧邻上一匹配行 | `// CHECK-NEXT: return`             |
| `CHECK-NOT:`    | 确认某内容未出现  | `// CHECK-NOT: error`               |
| `CHECK-DAG:`    | 无序匹配      | `// CHECK-DAG: %x`                  |
| `CHECK-SAME:`   | 同行内匹配     | `// CHECK-SAME: =`                  |

---

## 五、组合实例

一个实际的 MLIR 测试例子：

```mlir
// RUN: mlir-opt %s -canonicalize | FileCheck %s

func.func @add(%arg0: i32, %arg1: i32) -> i32 {
  %0 = arith.addi %arg0, %arg1 : i32
  return %0 : i32
}

// CHECK-LABEL: func.func @add
// CHECK: %[[X:.*]] = arith.addi %arg0, %arg1
// CHECK-NEXT: return %[[X]]
```

说明：

* `CHECK-LABEL`：标记函数起点。
* `CHECK:`：匹配下一行。
* `CHECK-NEXT:`：必须紧接上一行。

---

## 六、运行 lit 测试

你可以用以下命令运行 lit 测试：

```bash
$ lit path/to/test/dir
# 或仅运行单个文件
$ lit path/to/test/file.mlir
```

常见参数：

```bash
--verbose        # 显示详细匹配信息
--filter=<regex> # 只运行匹配的测试
--show-all       # 显示所有输出
```

---

## 七、额外高级特性（了解即可）

* `CHECK-NOT` 与 `CHECK-DAG` 可组合，用于“未出现某模式”但顺序无关的情况。
* `CHECK-COUNT-N:` 精确匹配出现次数。
* `CHECK-IF:` / `CHECK-END-IF:` 可用 C-like 条件控制（LLVM ≥ 14）。
* lit 支持 **多行 RUN 命令**：

  ```
  ```

// RUN: mlir-opt %s | 
// RUN: FileCheck %s

```

---

是否希望我给你一个完整、可运行的 **lit + FileCheck 教学示例工程目录结构**（含 `CMakeLists.txt`, `.mlir`, `.td` 测试）？  
这样你可以直接在本地 `ninja check-mlir` 跑起来看每个指令效果。
```
