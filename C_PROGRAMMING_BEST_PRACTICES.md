# C 编程最佳实践

## 目录

1. [代码风格与格式](#1-代码风格与格式)
2. [内存管理](#2-内存管理)
3. [错误处理](#3-错误处理)
4. [指针安全](#4-指针安全)
5. [字符串处理](#5-字符串处理)
6. [头文件管理](#6-头文件管理)
7. [预处理器使用](#7-预处理器使用)
8. [数据类型选择](#8-数据类型选择)
9. [并发与线程安全](#9-并发与线程安全)
10. [调试与测试](#10-调试与测试)
11. [性能优化](#11-性能优化)
12. [安全编码](#12-安全编码)
13. [项目结构与构建](#13-项目结构与构建)

---

## 1. 代码风格与格式

### 1.1 命名规范

```c
/* 常量：全大写 + 下划线 */
#define MAX_BUFFER_SIZE 1024
#define PI 3.14159265358979

/* 变量和函数：小写 + 下划线（snake_case） */
int user_count;
void process_request(int request_id);

/* 类型定义：首字母大写或全大写 */
typedef struct {
    int x;
    int y;
} Point;

/* 枚举值：带前缀，全大写 */
typedef enum {
    COLOR_RED,
    COLOR_GREEN,
    COLOR_BLUE
} Color;
```

### 1.2 缩进与括号

```c
/* 推荐：K&R 风格，4 空格缩进 */
if (condition) {
    do_something();
} else {
    do_other();
}

/* 函数定义：左括号独占一行（GNU 风格）或跟在同一行（K&R） */
int calculate_sum(int a, int b)
{
    return a + b;
}
```

### 1.3 注释

```c
/* 文件头注释 */
/**
 * @file   network.c
 * @brief  网络通信模块实现
 * @author Your Name
 * @date   2026-03-14
 */

/* 函数文档注释 */
/**
 * @brief  计算两点之间的距离
 * @param  p1 第一个点
 * @param  p2 第二个点
 * @return 两点间的欧几里得距离
 */
double point_distance(Point p1, Point p2);

/* 行内注释用于解释"为什么"，而非"做了什么" */
timeout *= 2;  /* 指数退避，避免服务端过载 */
```

---

## 2. 内存管理

### 2.1 分配与释放配对

```c
/* 原则：谁分配，谁释放；分配后立即检查 */
char *buf = malloc(size);
if (buf == NULL) {
    perror("malloc failed");
    return -1;
}

/* 使用完毕后释放并置 NULL */
free(buf);
buf = NULL;
```

### 2.2 避免常见内存错误

```c
/* 错误：使用 sizeof 指针而非数组大小 */
int *arr = malloc(n * sizeof(int));        /* 正确 */
int *arr = malloc(n * sizeof(*arr));       /* 更好：类型自动匹配 */

/* 错误：realloc 直接赋值给原指针 */
/* 如果 realloc 失败返回 NULL，原指针丢失 → 内存泄漏 */
int *tmp = realloc(arr, new_size * sizeof(*arr));
if (tmp == NULL) {
    free(arr);
    return -1;
}
arr = tmp;
```

### 2.3 使用 RAII 模式（goto 清理）

```c
int process_file(const char *path)
{
    int ret = -1;
    FILE *fp = NULL;
    char *buf = NULL;

    fp = fopen(path, "r");
    if (fp == NULL)
        goto cleanup;

    buf = malloc(BUF_SIZE);
    if (buf == NULL)
        goto cleanup;

    /* 正常处理逻辑 */
    ret = 0;

cleanup:
    free(buf);
    if (fp != NULL)
        fclose(fp);
    return ret;
}
```

---

## 3. 错误处理

### 3.1 返回值检查

```c
/* 始终检查系统调用和库函数返回值 */
int fd = open(path, O_RDONLY);
if (fd < 0) {
    perror("open");
    return -1;
}

ssize_t n = read(fd, buf, sizeof(buf));
if (n < 0) {
    perror("read");
    close(fd);
    return -1;
}
```

### 3.2 错误码设计

```c
/* 定义明确的错误码枚举 */
typedef enum {
    ERR_OK = 0,
    ERR_NOMEM = -1,
    ERR_IO = -2,
    ERR_INVALID_ARG = -3,
    ERR_TIMEOUT = -4
} ErrorCode;

/* 函数返回错误码，通过指针参数传出结果 */
ErrorCode parse_config(const char *path, Config *out_config);

/* 提供错误码到字符串的转换 */
const char *error_string(ErrorCode err)
{
    switch (err) {
    case ERR_OK:          return "success";
    case ERR_NOMEM:       return "out of memory";
    case ERR_IO:          return "I/O error";
    case ERR_INVALID_ARG: return "invalid argument";
    case ERR_TIMEOUT:     return "timeout";
    default:              return "unknown error";
    }
}
```

### 3.3 使用 errno

```c
#include <errno.h>
#include <string.h>

/* 在调用可能修改 errno 的函数前保存 */
errno = 0;
long val = strtol(str, &endptr, 10);
if (errno == ERANGE || endptr == str) {
    fprintf(stderr, "转换失败: %s\n", strerror(errno));
    return -1;
}
```

---

## 4. 指针安全

### 4.1 初始化与空指针检查

```c
/* 声明时初始化 */
int *ptr = NULL;
struct Node *head = NULL;

/* 使用前检查 */
void process(int *data, size_t len)
{
    if (data == NULL || len == 0)
        return;

    for (size_t i = 0; i < len; i++) {
        /* 安全使用 data[i] */
    }
}
```

### 4.2 避免悬垂指针

```c
/* 释放后立即置 NULL */
free(node->data);
node->data = NULL;

free(node);
node = NULL;

/* 不要返回局部变量的地址 */
/* 错误示例 */
int *bad_func(void)
{
    int local = 42;
    return &local;  /* 未定义行为！ */
}

/* 正确做法 */
int *good_func(void)
{
    int *p = malloc(sizeof(int));
    if (p != NULL)
        *p = 42;
    return p;  /* 调用者负责释放 */
}
```

### 4.3 const 正确性

```c
/* 不修改的数据用 const 修饰 */
size_t string_length(const char *str);
void print_array(const int *arr, size_t len);

/* const 指针 vs 指向 const 的指针 */
const int *p1;        /* 指向 const int 的指针，*p1 不可修改 */
int *const p2 = &x;   /* const 指针，p2 不可重新赋值 */
const int *const p3 = &x;  /* 两者都不可修改 */
```

---

## 5. 字符串处理

### 5.1 安全的字符串函数

```c
/* 避免使用不安全的函数 */
/* 不推荐          推荐替代                    */
/* strcpy()    →  strncpy() / strlcpy()       */
/* strcat()    →  strncat() / strlcat()       */
/* sprintf()   →  snprintf()                  */
/* gets()      →  fgets()                     */

/* snprintf 示例 */
char buf[256];
int n = snprintf(buf, sizeof(buf), "user=%s, id=%d", name, id);
if (n < 0 || (size_t)n >= sizeof(buf)) {
    /* 输出被截断或出错 */
    fprintf(stderr, "buffer too small\n");
}

/* fgets 替代 gets */
char line[1024];
if (fgets(line, sizeof(line), stdin) != NULL) {
    /* 去除末尾换行符 */
    line[strcspn(line, "\n")] = '\0';
}
```

### 5.2 缓冲区溢出防护

```c
/* 始终传递缓冲区大小 */
void safe_copy(char *dst, size_t dst_size, const char *src)
{
    if (dst == NULL || src == NULL || dst_size == 0)
        return;

    size_t src_len = strlen(src);
    size_t copy_len = (src_len < dst_size - 1) ? src_len : dst_size - 1;

    memcpy(dst, src, copy_len);
    dst[copy_len] = '\0';
}
```

---

## 6. 头文件管理

### 6.1 Include Guard

```c
/* 传统方式 */
#ifndef PROJECT_MODULE_H
#define PROJECT_MODULE_H

/* 头文件内容 */

#endif /* PROJECT_MODULE_H */

/* 或者使用编译器扩展（非标准但广泛支持） */
#pragma once
```

### 6.2 头文件组织原则

```c
/* 包含顺序（每组之间空行分隔）：
 * 1. 对应的头文件（如 module.c 先包含 module.h）
 * 2. C 标准库
 * 3. 系统/平台头文件
 * 4. 第三方库
 * 5. 项目内部头文件
 */

/* module.c */
#include "module.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/socket.h>
#include <netinet/in.h>

#include <openssl/ssl.h>

#include "config.h"
#include "utils.h"
```

### 6.3 头文件中的注意事项

```c
/* 头文件中应包含：
 * - 函数声明
 * - 类型定义（struct, enum, typedef）
 * - 宏定义
 * - extern 变量声明
 *
 * 头文件中不应包含：
 * - 函数实现（inline 函数除外）
 * - 变量定义（会导致多重定义）
 * - static 函数
 */
```

---

## 7. 预处理器使用

### 7.1 宏的安全写法

```c
/* 用括号保护宏参数和整体 */
#define SQUARE(x) ((x) * (x))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* 多语句宏使用 do-while(0) */
#define LOG_ERROR(msg) \
    do { \
        fprintf(stderr, "[ERROR] %s:%d: %s\n", __FILE__, __LINE__, (msg)); \
    } while (0)

/* 优先使用 inline 函数替代功能宏 */
static inline int max_int(int a, int b)
{
    return a > b ? a : b;
}
```

### 7.2 条件编译

```c
/* 平台适配 */
#if defined(_WIN32)
    #include <windows.h>
#elif defined(__linux__)
    #include <unistd.h>
#elif defined(__APPLE__)
    #include <mach/mach.h>
#endif

/* 调试开关 */
#ifdef DEBUG
    #define DBG_PRINT(fmt, ...) \
        fprintf(stderr, "[DBG] " fmt "\n", ##__VA_ARGS__)
#else
    #define DBG_PRINT(fmt, ...) ((void)0)
#endif
```

---

## 8. 数据类型选择

### 8.1 使用精确宽度类型

```c
#include <stdint.h>
#include <stdbool.h>

/* 需要精确宽度时使用 stdint.h */
uint8_t  byte_val;      /* 无符号 8 位 */
int32_t  counter;        /* 有符号 32 位 */
uint64_t file_size;      /* 无符号 64 位 */

/* 大小相关使用 size_t / ssize_t */
size_t len = strlen(str);

/* 布尔值使用 stdbool.h */
bool is_valid = true;

/* 指针差值使用 ptrdiff_t */
ptrdiff_t diff = end - begin;
```

### 8.2 避免隐式转换陷阱

```c
/* 有符号 vs 无符号比较 */
int count = -1;
size_t size = 10;
if (count < size) {
    /* 警告：count 会被隐式转换为很大的无符号数！ */
}

/* 正确做法 */
if (count < 0 || (size_t)count < size) {
    /* 安全比较 */
}

/* 整数溢出检查 */
#include <limits.h>
if (a > 0 && b > INT_MAX - a) {
    /* 溢出！ */
}
```

---

## 9. 并发与线程安全

### 9.1 互斥锁使用

```c
#include <pthread.h>

typedef struct {
    int count;
    pthread_mutex_t lock;
} SafeCounter;

int safe_counter_init(SafeCounter *sc)
{
    sc->count = 0;
    return pthread_mutex_init(&sc->lock, NULL);
}

int safe_counter_increment(SafeCounter *sc)
{
    int ret;
    if ((ret = pthread_mutex_lock(&sc->lock)) != 0)
        return ret;

    sc->count++;

    pthread_mutex_unlock(&sc->lock);
    return 0;
}

void safe_counter_destroy(SafeCounter *sc)
{
    pthread_mutex_destroy(&sc->lock);
}
```

### 9.2 避免数据竞争

```c
/* 使用 _Atomic（C11）进行简单的原子操作 */
#include <stdatomic.h>

_Atomic int shared_flag = 0;

void set_flag(void)
{
    atomic_store(&shared_flag, 1);
}

int get_flag(void)
{
    return atomic_load(&shared_flag);
}

/* 线程局部存储 */
_Thread_local int thread_errno;
```

---

## 10. 调试与测试

### 10.1 断言

```c
#include <assert.h>

/* 用断言检查编程错误（不应该发生的情况） */
void array_get(const int *arr, size_t len, size_t index)
{
    assert(arr != NULL);
    assert(index < len);
    return arr[index];
}

/* 不要在断言中放有副作用的表达式 */
/* 错误：NDEBUG 模式下 pop() 不会被调用 */
assert(stack_pop(&s) == 0);

/* 正确 */
int ret = stack_pop(&s);
assert(ret == 0);
```

### 10.2 内存检测工具

```bash
# Valgrind 检测内存泄漏
valgrind --leak-check=full --show-leak-kinds=all ./program

# AddressSanitizer（编译时启用）
gcc -fsanitize=address -g -o program program.c
./program

# UndefinedBehaviorSanitizer
gcc -fsanitize=undefined -g -o program program.c
```

### 10.3 简单测试框架

```c
/* 最小化测试宏 */
#define TEST_ASSERT(cond, msg) \
    do { \
        if (!(cond)) { \
            fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, (msg)); \
            test_failures++; \
        } else { \
            test_passes++; \
        } \
    } while (0)

static int test_passes = 0;
static int test_failures = 0;

void test_addition(void)
{
    TEST_ASSERT(add(2, 3) == 5, "2 + 3 should be 5");
    TEST_ASSERT(add(-1, 1) == 0, "-1 + 1 should be 0");
    TEST_ASSERT(add(0, 0) == 0, "0 + 0 should be 0");
}

int main(void)
{
    test_addition();
    printf("Tests: %d passed, %d failed\n", test_passes, test_failures);
    return test_failures > 0 ? 1 : 0;
}
```

---

## 11. 性能优化

### 11.1 基本原则

```c
/* 1. 先写正确的代码，再优化 */
/* 2. 用 profiler 找到热点，不要猜测 */
/* 3. 优先优化算法复杂度，而非微观优化 */

/* 缓存友好的数据布局（SoA vs AoS） */

/* Array of Structures（AoS）- 遍历单个字段时缓存不友好 */
struct Particle_AoS {
    float x, y, z;
    float vx, vy, vz;
    float mass;
};
struct Particle_AoS particles_aos[N];

/* Structure of Arrays（SoA）- 批量处理单个字段时缓存友好 */
struct Particles_SoA {
    float x[N], y[N], z[N];
    float vx[N], vy[N], vz[N];
    float mass[N];
};
```

### 11.2 减少不必要的开销

```c
/* 循环不变量外提 */
/* 差 */
for (int i = 0; i < n; i++) {
    int len = strlen(str);  /* 每次迭代都计算 */
    /* ... */
}

/* 好 */
int len = strlen(str);
for (int i = 0; i < n; i++) {
    /* ... */
}

/* 使用 restrict 关键字提示编译器无别名 */
void vector_add(float *restrict out,
                const float *restrict a,
                const float *restrict b,
                size_t n)
{
    for (size_t i = 0; i < n; i++)
        out[i] = a[i] + b[i];
}
```

---

## 12. 安全编码

### 12.1 输入验证

```c
/* 验证所有外部输入 */
int parse_port(const char *str, uint16_t *out_port)
{
    if (str == NULL || out_port == NULL)
        return -1;

    char *endptr;
    errno = 0;
    long val = strtol(str, &endptr, 10);

    if (errno != 0 || endptr == str || *endptr != '\0')
        return -1;
    if (val < 1 || val > 65535)
        return -1;

    *out_port = (uint16_t)val;
    return 0;
}
```

### 12.2 防止整数溢出

```c
#include <stdint.h>

/* 安全乘法（检查溢出） */
bool safe_multiply(size_t a, size_t b, size_t *result)
{
    if (a != 0 && b > SIZE_MAX / a)
        return false;  /* 会溢出 */

    *result = a * b;
    return true;
}

/* 安全的内存分配 */
void *safe_calloc(size_t nmemb, size_t size)
{
    size_t total;
    if (!safe_multiply(nmemb, size, &total))
        return NULL;

    return malloc(total);  /* 或使用 calloc */
}
```

### 12.3 敏感数据处理

```c
/* 安全清除敏感数据（防止编译器优化掉） */
#include <string.h>

void secure_zero(void *ptr, size_t len)
{
    volatile unsigned char *p = ptr;
    while (len--)
        *p++ = 0;
}

/* 使用后清除密码 */
char password[128];
/* ... 使用 password ... */
secure_zero(password, sizeof(password));
```

---

## 13. 项目结构与构建

### 13.1 推荐目录结构

```
project/
├── include/          # 公共头文件
│   └── project/
│       ├── core.h
│       └── utils.h
├── src/              # 源文件
│   ├── core.c
│   └── utils.c
├── tests/            # 测试文件
│   ├── test_core.c
│   └── test_utils.c
├── docs/             # 文档
├── CMakeLists.txt    # 构建配置
├── Makefile          # 或 Makefile
└── README.md
```

### 13.2 Makefile 示例

```makefile
CC      = gcc
CFLAGS  = -Wall -Wextra -Wpedantic -std=c11 -g
LDFLAGS =

SRC_DIR = src
OBJ_DIR = build
SRCS    = $(wildcard $(SRC_DIR)/*.c)
OBJS    = $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
TARGET  = program

.PHONY: all clean test

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR):
	mkdir -p $@

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

test: $(TARGET)
	./run_tests.sh
```

### 13.3 编译器警告

```bash
# 推荐的编译选项
gcc -Wall -Wextra -Wpedantic -Werror \
    -Wshadow -Wconversion -Wstrict-prototypes \
    -Wmissing-prototypes -Wold-style-definition \
    -std=c11 -g -O2 \
    -o program program.c

# 静态分析
cppcheck --enable=all --std=c11 src/
clang --analyze src/*.c
```

---

## 快速检查清单

| 类别 | 检查项 |
|------|--------|
| 内存 | 每个 `malloc` 都有对应的 `free` |
| 内存 | `realloc` 使用临时变量接收返回值 |
| 指针 | 释放后置 `NULL` |
| 指针 | 使用前检查 `NULL` |
| 字符串 | 使用 `snprintf` 而非 `sprintf` |
| 字符串 | 使用 `fgets` 而非 `gets` |
| 错误 | 检查所有系统调用返回值 |
| 类型 | 使用 `size_t` 表示大小和索引 |
| 类型 | 注意有符号/无符号混合比较 |
| 并发 | 共享数据有适当的锁保护 |
| 编译 | 开启 `-Wall -Wextra -Werror` |
| 测试 | 使用 Valgrind / ASan 检查内存问题 |

---

## 推荐阅读

- *The C Programming Language* (K&R) — Brian Kernighan, Dennis Ritchie
- *C Interfaces and Implementations* — David Hanson
- *Effective C* — Robert C. Seacord
- *CERT C Coding Standard* — SEI CERT
- *Modern C* — Jens Gustedt (免费在线版)
