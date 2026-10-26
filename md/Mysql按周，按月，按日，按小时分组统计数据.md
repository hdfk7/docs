# MySQL 时间分组统计

示例使用 `events` 表、`created_at` 时间字段和 `amount` 金额字段，执行前替换成实际名称。以下分组不会自动补出没有数据的日期。

## 按小时、日、月统计

```sql
-- 按小时
SELECT DATE_FORMAT(created_at, '%Y-%m-%d %H:00:00') AS period,
       COUNT(*) AS total
FROM events
GROUP BY period
ORDER BY period;

-- 按天
SELECT DATE(created_at) AS period, COUNT(*) AS total
FROM events
GROUP BY period
ORDER BY period;

-- 按月
SELECT DATE_FORMAT(created_at, '%Y-%m') AS period, COUNT(*) AS total
FROM events
GROUP BY period
ORDER BY period;
```

## 按周统计：注意跨年

周一作为一周的开始，使用 ISO 周年 `%x` 搭配周数 `%v`，避免把日历年 `%Y` 与跨年的周数混用。

```sql
SELECT DATE_FORMAT(created_at, '%x-W%v') AS period, COUNT(*) AS total
FROM events
GROUP BY period
ORDER BY period;
```

## 按季度和年份汇总

```sql
SELECT YEAR(created_at) AS year,
       QUARTER(created_at) AS quarter,
       COUNT(*) AS total,
       SUM(amount) AS total_amount
FROM events
GROUP BY YEAR(created_at), QUARTER(created_at)
ORDER BY year, quarter;

SELECT YEAR(created_at) AS year, COUNT(*) AS total, SUM(amount) AS total_amount
FROM events
GROUP BY YEAR(created_at)
ORDER BY year;
```

## 时间范围查询

使用左闭右开的区间：包含开始时间，不包含结束时间。这样能正确处理月末和带小数秒的时间，也避免在查询列上套日期函数。

```sql
-- 本月
SELECT * FROM events
WHERE created_at >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
  AND created_at < DATE_FORMAT(CURDATE() + INTERVAL 1 MONTH, '%Y-%m-01');

-- 本周：周一到下周一，跨月和跨年同样有效
SELECT * FROM events
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)
  AND created_at < DATE_ADD(
      DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 7 DAY
  );

-- 本年度
SELECT * FROM events
WHERE created_at >= MAKEDATE(YEAR(CURDATE()), 1)
  AND created_at < MAKEDATE(YEAR(CURDATE()) + 1, 1);

-- 本季度：先得到当前季度第一天
SET @quarter_start = DATE_ADD(
    MAKEDATE(YEAR(CURDATE()), 1),
    INTERVAL ((QUARTER(CURDATE()) - 1) * 3) MONTH
);
SELECT * FROM events
WHERE created_at >= @quarter_start
  AND created_at < DATE_ADD(@quarter_start, INTERVAL 3 MONTH);

-- 最近 7 × 24 小时，不包含未来时间
SELECT * FROM events
WHERE created_at >= NOW() - INTERVAL 7 DAY
  AND created_at < NOW();
```

## 常用格式符

| 格式符 | 含义 |
| --- | --- |
| `%Y` | 四位日历年 |
| `%m` / `%d` | 两位月份 / 日期 |
| `%H` / `%i` / `%s` | 24 小时制小时 / 分钟 / 秒 |
| `%x` / `%v` | 周一为起点的周年 / 周数，配对使用 |

`CURDATE()`、`NOW()` 与 `FROM_UNIXTIME()` 受 MySQL 会话时区影响，统计前应统一时区。若原始字段存储 Unix 秒时间戳，可对边界使用 `UNIX_TIMESTAMP()` 后比较原始列；毫秒时间戳则需要相应换算。

参考：[MySQL 日期和时间函数](https://dev.mysql.com/doc/refman/8.4/en/date-and-time-functions.html)。
