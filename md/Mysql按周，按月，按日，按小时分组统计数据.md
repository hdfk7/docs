# Mysql按周，按月，按日，按小时分组统计数据

**按周**
select DATE_FORMAT(create_time,'%Y%u') weeks,count(caseid) count from tc_case group by weeks;

**按月**
select DATE_FORMAT(create_time,'%Y%m') months,count(caseid) count from tc_case group by months;

**按天**
select DATE_FORMAT(create_time,'%Y%m%d') days,count(caseid) count from tc_case group by days;

**按小时**
select DATE_FORMAT(create_time,'%Y%m%d%H') hours,count(caseid) count from tc_case group by hours;

**DATE_FORMAT方法说明**

格式：DATE_FORMAT(date,format)

根据format字符串格式化date值。下列修饰符可以被用在format字符串中：

%M 月名字(January……December)

%W 星期名字(Sunday……Saturday)

%D 有英语前缀的月份的日期(1st, 2nd, 3rd, 等等。）

%Y 年, 数字, 4 位

%y 年, 数字, 2 位

%a 缩写的星期名字(Sun……Sat)

%d 月份中的天数, 数字(00……31)

%e 月份中的天数, 数字(0……31)

%m 月, 数字(01……12)

%c 月, 数字(1……12)

%b 缩写的月份名字(Jan……Dec)

%j 一年中的天数(001……366)

%H 小时(00……23)

%k 小时(0……23)

%h 小时(01……12)

%I 小时(01……12)

%l 小时(1……12)

%i 分钟, 数字(00……59)

%r 时间,12 小时(hh:mm:ss [AP]M)

%T 时间,24 小时(hh:mm:ss)

%S 秒(00……59)

%s 秒(00……59)

%p AM或PM

%w 一个星期中的天数(0=Sunday ……6=Saturday ）

%U 星期(0……52), 这里星期天是星期的第一天

%u 星期(0……52), 这里星期一是星期的第一天

%% 一个文字“%”。


**按年汇总，统计：**
select sum(mymoney) as totalmoney, count(*) as sheets from mytable group by date_format(col, '%Y');

**按月汇总，统计：**
select sum(mymoney) as totalmoney, count(*) as sheets from mytable group by date_format(col, '%Y-%m');

**按季度汇总，统计：**
select sum(mymoney) as totalmoney,count(*) as sheets from mytable group by concat(date_format(col, '%Y'),FLOOR((date_format(col, '%m')+2)/3));
select sum(mymoney) as totalmoney,count(*) as sheets from mytable group by concat(date_format(col, '%Y'),FLOOR((date_format(col, '%m')+2)/3));

**按小时：**
select sum(mymoney) as totalmoney,count(*) as sheets from mytable group by date_format(col, '%Y-%m-%d %H ');

**查询 本年度的数据:**
SELECT * FROM mytable WHERE year(FROM_UNIXTIME(my_time)) = year(curdate());

**查询数据附带季度数:**
SELECT id, quarter(FROM_UNIXTIME(my_time)) FROM mytable;

**查询 本季度的数据:**
SELECT * FROM mytable WHERE quarter(FROM_UNIXTIME(my_time)) = quarter(curdate());

**本月统计:**
select * from mytable where month(my_time1) = month(curdate()) and year(my_time2) = year(curdate());

**本周统计:**
select * from mytable where month(my_time1) = month(curdate()) and week(my_time2) = week(curdate());

**N天内记录:**
WHERE TO_DAYS(NOW())-TO_DAYS(时间字段)<=N
