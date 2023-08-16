# Data query language (DQL)


********************************************************************

***************************************************************

13.2.13 SELECT Statement
13.2.13.1 SELECT ... INTO Statement
13.2.13.2 JOIN Clause
SELECT
    [ALL | DISTINCT | DISTINCTROW ]
    [HIGH_PRIORITY]
    [STRAIGHT_JOIN]
    [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT]
    [SQL_NO_CACHE] [SQL_CALC_FOUND_ROWS]
    select_expr [, select_expr] ...
    [into_option]
    [FROM table_references
      [PARTITION partition_list]]
    [WHERE where_condition]
    [GROUP BY {col_name | expr | position}, ... [WITH ROLLUP]]
    [HAVING where_condition]
    [WINDOW window_name AS (window_spec)
        [, window_name AS (window_spec)] ...]
    [ORDER BY {col_name | expr | position}
      [ASC | DESC], ... [WITH ROLLUP]]
    [LIMIT {[offset,] row_count | row_count OFFSET offset}]
    [into_option]
    [FOR {UPDATE | SHARE}
        [OF tbl_name [, tbl_name] ...]
        [NOWAIT | SKIP LOCKED]
      | LOCK IN SHARE MODE]
    [into_option]

into_option: {
    INTO OUTFILE 'file_name'
        [CHARACTER SET charset_name]
        export_options
  | INTO DUMPFILE 'file_name'
  | INTO var_name [, var_name] ...
}
SELECT is used to retrieve rows selected from one or more tables, and can include UNION operations and subqueries. Beginning with MySQL 8.0.31, INTERSECT and EXCEPT operations are also supported. The UNION, INTERSECT, and EXCEPT operators are described in more detail later in this section. See also Section 13.2.15, “Subqueries”.

A SELECT statement can start with a WITH clause to define common table expressions accessible within the SELECT. See Section 13.2.20, “WITH (Common Table Expressions)”.

The most commonly used clauses of SELECT statements are these:

Each select_expr indicates a column that you want to retrieve. There must be at least one select_expr.

table_references indicates the table or tables from which to retrieve rows. Its syntax is described in Section 13.2.13.2, “JOIN Clause”.

SELECT supports explicit partition selection using the PARTITION clause with a list of partitions or subpartitions (or both) following the name of the table in a table_reference (see Section 13.2.13.2, “JOIN Clause”). In this case, rows are selected only from the partitions listed, and any other partitions of the table are ignored. For more information and examples, see Section 24.5, “Partition Selection”.

The WHERE clause, if given, indicates the condition or conditions that rows must satisfy to be selected. where_condition is an expression that evaluates to true for each row to be selected. The statement selects all rows if there is no WHERE clause.

In the WHERE expression, you can use any of the functions and operators that MySQL supports, except for aggregate (group) functions. See Section 9.5, “Expressions”, and Chapter 12, Functions and Operators.

SELECT can also be used to retrieve rows computed without reference to any table.

For example:

mysql> SELECT 1 + 1;
        -> 2
You are permitted to specify DUAL as a dummy table name in situations where no tables are referenced:

mysql> SELECT 1 + 1 FROM DUAL;
        -> 2
DUAL is purely for the convenience of people who require that all SELECT statements should have FROM and possibly other clauses. MySQL may ignore the clauses. MySQL does not require FROM DUAL if no tables are referenced.

In general, clauses used must be given in exactly the order shown in the syntax description. For example, a HAVING clause must come after any GROUP BY clause and before any ORDER BY clause. The INTO clause, if present, can appear in any position indicated by the syntax description, but within a given statement can appear only once, not in multiple positions. For more information about INTO, see Section 13.2.13.1, “SELECT ... INTO Statement”.

The list of select_expr terms comprises the select list that indicates which columns to retrieve. Terms specify a column or expression or can use *-shorthand:

A select list consisting only of a single unqualified * can be used as shorthand to select all columns from all tables:

SELECT * FROM t1 INNER JOIN t2 ...
tbl_name.* can be used as a qualified shorthand to select all columns from the named table:

SELECT t1.*, t2.* FROM t1 INNER JOIN t2 ...
If a table has invisible columns, * and tbl_name.* do not include them. To be included, invisible columns must be referenced explicitly.

Use of an unqualified * with other items in the select list may produce a parse error. For example:

SELECT id, * FROM t1
To avoid this problem, use a qualified tbl_name.* reference:

SELECT id, t1.* FROM t1
Use qualified tbl_name.* references for each table in the select list:

SELECT AVG(score), t1.* FROM t1 ...
The following list provides additional information about other SELECT clauses:

A select_expr can be given an alias using AS alias_name. The alias is used as the expression's column name and can be used in GROUP BY, ORDER BY, or HAVING clauses. For example:

SELECT CONCAT(last_name,', ',first_name) AS full_name
  FROM mytable ORDER BY full_name;
The AS keyword is optional when aliasing a select_expr with an identifier. The preceding example could have been written like this:

SELECT CONCAT(last_name,', ',first_name) full_name
  FROM mytable ORDER BY full_name;
However, because the AS is optional, a subtle problem can occur if you forget the comma between two select_expr expressions: MySQL interprets the second as an alias name. For example, in the following statement, columnb is treated as an alias name:

SELECT columna columnb FROM mytable;
For this reason, it is good practice to be in the habit of using AS explicitly when specifying column aliases.

It is not permissible to refer to a column alias in a WHERE clause, because the column value might not yet be determined when the WHERE clause is executed. See Section B.3.4.4, “Problems with Column Aliases”.

The FROM table_references clause indicates the table or tables from which to retrieve rows. If you name more than one table, you are performing a join. For information on join syntax, see Section 13.2.13.2, “JOIN Clause”. For each table specified, you can optionally specify an alias.

tbl_name [[AS] alias] [index_hint]
The use of index hints provides the optimizer with information about how to choose indexes during query processing. For a description of the syntax for specifying these hints, see Section 8.9.4, “Index Hints”.

You can use SET max_seeks_for_key=value as an alternative way to force MySQL to prefer key scans instead of table scans. See Section 5.1.8, “Server System Variables”.

You can refer to a table within the default database as tbl_name, or as db_name.tbl_name to specify a database explicitly. You can refer to a column as col_name, tbl_name.col_name, or db_name.tbl_name.col_name. You need not specify a tbl_name or db_name.tbl_name prefix for a column reference unless the reference would be ambiguous. See Section 9.2.2, “Identifier Qualifiers”, for examples of ambiguity that require the more explicit column reference forms.

A table reference can be aliased using tbl_name AS alias_name or tbl_name alias_name. These statements are equivalent:

SELECT t1.name, t2.salary FROM employee AS t1, info AS t2
  WHERE t1.name = t2.name;

SELECT t1.name, t2.salary FROM employee t1, info t2
  WHERE t1.name = t2.name;
Columns selected for output can be referred to in ORDER BY and GROUP BY clauses using column names, column aliases, or column positions. Column positions are integers and begin with 1:

SELECT college, region, seed FROM tournament
  ORDER BY region, seed;

SELECT college, region AS r, seed AS s FROM tournament
  ORDER BY r, s;

SELECT college, region, seed FROM tournament
  ORDER BY 2, 3;
To sort in reverse order, add the DESC (descending) keyword to the name of the column in the ORDER BY clause that you are sorting by. The default is ascending order; this can be specified explicitly using the ASC keyword.

If ORDER BY occurs within a parenthesized query expression and also is applied in the outer query, the results are undefined and may change in a future version of MySQL.

Use of column positions is deprecated because the syntax has been removed from the SQL standard.

Prior to MySQL 8.0.13, MySQL supported a nonstandard syntax extension that permitted explicit ASC or DESC designators for GROUP BY columns. MySQL 8.0.12 and later supports ORDER BY with grouping functions so that use of this extension is no longer necessary. (Bug #86312, Bug #26073525) This also means you can sort on an arbitrary column or columns when using GROUP BY, like this:

SELECT a, b, COUNT(c) AS t FROM test_table GROUP BY a,b ORDER BY a,t DESC;
As of MySQL 8.0.13, the GROUP BY extension is no longer supported: ASC or DESC designators for GROUP BY columns are not permitted.

When you use ORDER BY or GROUP BY to sort a column in a SELECT, the server sorts values using only the initial number of bytes indicated by the max_sort_length system variable.

MySQL extends the use of GROUP BY to permit selecting fields that are not mentioned in the GROUP BY clause. If you are not getting the results that you expect from your query, please read the description of GROUP BY found in Section 12.19, “Aggregate Functions”.

GROUP BY permits a WITH ROLLUP modifier. See Section 12.19.2, “GROUP BY Modifiers”.

Previously, it was not permitted to use ORDER BY in a query having a WITH ROLLUP modifier. This restriction is lifted as of MySQL 8.0.12. See Section 12.19.2, “GROUP BY Modifiers”.

The HAVING clause, like the WHERE clause, specifies selection conditions. The WHERE clause specifies conditions on columns in the select list, but cannot refer to aggregate functions. The HAVING clause specifies conditions on groups, typically formed by the GROUP BY clause. The query result includes only groups satisfying the HAVING conditions. (If no GROUP BY is present, all rows implicitly form a single aggregate group.)

The HAVING clause is applied nearly last, just before items are sent to the client, with no optimization. (LIMIT is applied after HAVING.)

The SQL standard requires that HAVING must reference only columns in the GROUP BY clause or columns used in aggregate functions. However, MySQL supports an extension to this behavior, and permits HAVING to refer to columns in the SELECT list and columns in outer subqueries as well.

If the HAVING clause refers to a column that is ambiguous, a warning occurs. In the following statement, col2 is ambiguous because it is used as both an alias and a column name:

SELECT COUNT(col1) AS col2 FROM t GROUP BY col2 HAVING col2 = 2;
Preference is given to standard SQL behavior, so if a HAVING column name is used both in GROUP BY and as an aliased column in the select column list, preference is given to the column in the GROUP BY column.

Do not use HAVING for items that should be in the WHERE clause. For example, do not write the following:

SELECT col_name FROM tbl_name HAVING col_name > 0;
Write this instead:

SELECT col_name FROM tbl_name WHERE col_name > 0;
The HAVING clause can refer to aggregate functions, which the WHERE clause cannot:

SELECT user, MAX(salary) FROM users
  GROUP BY user HAVING MAX(salary) > 10;
(This did not work in some older versions of MySQL.)

MySQL permits duplicate column names. That is, there can be more than one select_expr with the same name. This is an extension to standard SQL. Because MySQL also permits GROUP BY and HAVING to refer to select_expr values, this can result in an ambiguity:

SELECT 12 AS a, a FROM t GROUP BY a;
In that statement, both columns have the name a. To ensure that the correct column is used for grouping, use different names for each select_expr.

The WINDOW clause, if present, defines named windows that can be referred to by window functions. For details, see Section 12.20.4, “Named Windows”.

MySQL resolves unqualified column or alias references in ORDER BY clauses by searching in the select_expr values, then in the columns of the tables in the FROM clause. For GROUP BY or HAVING clauses, it searches the FROM clause before searching in the select_expr values. (For GROUP BY and HAVING, this differs from the pre-MySQL 5.0 behavior that used the same rules as for ORDER BY.)

The LIMIT clause can be used to constrain the number of rows returned by the SELECT statement. LIMIT takes one or two numeric arguments, which must both be nonnegative integer constants, with these exceptions:

Within prepared statements, LIMIT parameters can be specified using ? placeholder markers.

Within stored programs, LIMIT parameters can be specified using integer-valued routine parameters or local variables.

With two arguments, the first argument specifies the offset of the first row to return, and the second specifies the maximum number of rows to return. The offset of the initial row is 0 (not 1):

SELECT * FROM tbl LIMIT 5,10;  # Retrieve rows 6-15
To retrieve all rows from a certain offset up to the end of the result set, you can use some large number for the second parameter. This statement retrieves all rows from the 96th row to the last:

SELECT * FROM tbl LIMIT 95,18446744073709551615;
With one argument, the value specifies the number of rows to return from the beginning of the result set:

SELECT * FROM tbl LIMIT 5;     # Retrieve first 5 rows
In other words, LIMIT row_count is equivalent to LIMIT 0, row_count.

For prepared statements, you can use placeholders. The following statements return one row from the tbl table:

SET @a=1;
PREPARE STMT FROM 'SELECT * FROM tbl LIMIT ?';
EXECUTE STMT USING @a;
The following statements return the second to sixth rows from the tbl table:

SET @skip=1; SET @numrows=5;
PREPARE STMT FROM 'SELECT * FROM tbl LIMIT ?, ?';
EXECUTE STMT USING @skip, @numrows;
For compatibility with PostgreSQL, MySQL also supports the LIMIT row_count OFFSET offset syntax.

If LIMIT occurs within a parenthesized query expression and also is applied in the outer query, the results are undefined and may change in a future version of MySQL.

The SELECT ... INTO form of SELECT enables the query result to be written to a file or stored in variables. For more information, see Section 13.2.13.1, “SELECT ... INTO Statement”.

If you use FOR UPDATE with a storage engine that uses page or row locks, rows examined by the query are write-locked until the end of the current transaction.

You cannot use FOR UPDATE as part of the SELECT in a statement such as CREATE TABLE new_table SELECT ... FROM old_table .... (If you attempt to do so, the statement is rejected with the error Can't update table 'old_table' while 'new_table' is being created.)

FOR SHARE and LOCK IN SHARE MODE set shared locks that permit other transactions to read the examined rows but not to update or delete them. FOR SHARE and LOCK IN SHARE MODE are equivalent. However, FOR SHARE, like FOR UPDATE, supports NOWAIT, SKIP LOCKED, and OF tbl_name options. FOR SHARE is a replacement for LOCK IN SHARE MODE, but LOCK IN SHARE MODE remains available for backward compatibility.

NOWAIT causes a FOR UPDATE or FOR SHARE query to execute immediately, returning an error if a row lock cannot be obtained due to a lock held by another transaction.

SKIP LOCKED causes a FOR UPDATE or FOR SHARE query to execute immediately, excluding rows from the result set that are locked by another transaction.

NOWAIT and SKIP LOCKED options are unsafe for statement-based replication.

Note
Queries that skip locked rows return an inconsistent view of the data. SKIP LOCKED is therefore not suitable for general transactional work. However, it may be used to avoid lock contention when multiple sessions access the same queue-like table.

OF tbl_name applies FOR UPDATE and FOR SHARE queries to named tables. For example:

SELECT * FROM t1, t2 FOR SHARE OF t1 FOR UPDATE OF t2;
All tables referenced by the query block are locked when OF tbl_name is omitted. Consequently, using a locking clause without OF tbl_name in combination with another locking clause returns an error. Specifying the same table in multiple locking clauses returns an error. If an alias is specified as the table name in the SELECT statement, a locking clause may only use the alias. If the SELECT statement does not specify an alias explicitly, the locking clause may only specify the actual table name.

For more information about FOR UPDATE and FOR SHARE, see Section 15.7.2.4, “Locking Reads”. For additional information about NOWAIT and SKIP LOCKED options, see Locking Read Concurrency with NOWAIT and SKIP LOCKED.

Following the SELECT keyword, you can use a number of modifiers that affect the operation of the statement. HIGH_PRIORITY, STRAIGHT_JOIN, and modifiers beginning with SQL_ are MySQL extensions to standard SQL.

The ALL and DISTINCT modifiers specify whether duplicate rows should be returned. ALL (the default) specifies that all matching rows should be returned, including duplicates. DISTINCT specifies removal of duplicate rows from the result set. It is an error to specify both modifiers. DISTINCTROW is a synonym for DISTINCT.

In MySQL 8.0.12 and later, DISTINCT can be used with a query that also uses WITH ROLLUP. (Bug #87450, Bug #26640100)

HIGH_PRIORITY gives the SELECT higher priority than a statement that updates a table. You should use this only for queries that are very fast and must be done at once. A SELECT HIGH_PRIORITY query that is issued while the table is locked for reading runs even if there is an update statement waiting for the table to be free. This affects only storage engines that use only table-level locking (such as MyISAM, MEMORY, and MERGE).

HIGH_PRIORITY cannot be used with SELECT statements that are part of a UNION.

STRAIGHT_JOIN forces the optimizer to join the tables in the order in which they are listed in the FROM clause. You can use this to speed up a query if the optimizer joins the tables in nonoptimal order. STRAIGHT_JOIN also can be used in the table_references list. See Section 13.2.13.2, “JOIN Clause”.

STRAIGHT_JOIN does not apply to any table that the optimizer treats as a const or system table. Such a table produces a single row, is read during the optimization phase of query execution, and references to its columns are replaced with the appropriate column values before query execution proceeds. These tables appear first in the query plan displayed by EXPLAIN. See Section 8.8.1, “Optimizing Queries with EXPLAIN”. This exception may not apply to const or system tables that are used on the NULL-complemented side of an outer join (that is, the right-side table of a LEFT JOIN or the left-side table of a RIGHT JOIN.

SQL_BIG_RESULT or SQL_SMALL_RESULT can be used with GROUP BY or DISTINCT to tell the optimizer that the result set has many rows or is small, respectively. For SQL_BIG_RESULT, MySQL directly uses disk-based temporary tables if they are created, and prefers sorting to using a temporary table with a key on the GROUP BY elements. For SQL_SMALL_RESULT, MySQL uses in-memory temporary tables to store the resulting table instead of using sorting. This should not normally be needed.

SQL_BUFFER_RESULT forces the result to be put into a temporary table. This helps MySQL free the table locks early and helps in cases where it takes a long time to send the result set to the client. This modifier can be used only for top-level SELECT statements, not for subqueries or following UNION.

SQL_CALC_FOUND_ROWS tells MySQL to calculate how many rows there would be in the result set, disregarding any LIMIT clause. The number of rows can then be retrieved with SELECT FOUND_ROWS(). See Section 12.15, “Information Functions”.

Note
The SQL_CALC_FOUND_ROWS query modifier and accompanying FOUND_ROWS() function are deprecated as of MySQL 8.0.17; expect them to be removed in a future version of MySQL. See the FOUND_ROWS() description for information about an alternative strategy.

The SQL_CACHE and SQL_NO_CACHE modifiers were used with the query cache prior to MySQL 8.0. The query cache was removed in MySQL 8.0. The SQL_CACHE modifier was removed as well. SQL_NO_CACHE is deprecated, and has no effect; expect it to be removed in a future MySQL release.

*******************************************************************************

*******************************************************************************

13.2.13.1 SELECT ... INTO Statement
The SELECT ... INTO form of SELECT enables a query result to be stored in variables or written to a file:

SELECT ... INTO var_list selects column values and stores them into variables.

SELECT ... INTO OUTFILE writes the selected rows to a file. Column and line terminators can be specified to produce a specific output format.

SELECT ... INTO DUMPFILE writes a single row to a file without any formatting.

A given SELECT statement can contain at most one INTO clause, although as shown by the SELECT syntax description (see Section 13.2.13, “SELECT Statement”), the INTO can appear in different positions:

Before FROM. Example:

SELECT * INTO @myvar FROM t1;
Before a trailing locking clause. Example:

SELECT * FROM t1 INTO @myvar FOR UPDATE;
At the end of the SELECT. Example:

SELECT * FROM t1 FOR UPDATE INTO @myvar;
The INTO position at the end of the statement is supported as of MySQL 8.0.20, and is the preferred position. The position before a locking clause is deprecated as of MySQL 8.0.20; expect support for it to be removed in a future version of MySQL. In other words, INTO after FROM but not at the end of the SELECT produces a warning.

An INTO clause should not be used in a nested SELECT because such a SELECT must return its result to the outer context. There are also constraints on the use of INTO within UNION statements; see Section 13.2.18, “UNION Clause”.

For the INTO var_list variant:

var_list names a list of one or more variables, each of which can be a user-defined variable, stored procedure or function parameter, or stored program local variable. (Within a prepared SELECT ... INTO var_list statement, only user-defined variables are permitted; see Section 13.6.4.2, “Local Variable Scope and Resolution”.)

The selected values are assigned to the variables. The number of variables must match the number of columns. The query should return a single row. If the query returns no rows, a warning with error code 1329 occurs (No data), and the variable values remain unchanged. If the query returns multiple rows, error 1172 occurs (Result consisted of more than one row). If it is possible that the statement may retrieve multiple rows, you can use LIMIT 1 to limit the result set to a single row.

SELECT id, data INTO @x, @y FROM test.t1 LIMIT 1;
INTO var_list can also be used with a TABLE statement, subject to these restrictions:

The number of variables must match the number of columns in the table.

If the table contains more than one row, you must use LIMIT 1 to limit the result set to a single row. LIMIT 1 must precede the INTO keyword.

An example of such a statement is shown here:

TABLE employees ORDER BY lname DESC LIMIT 1
    INTO @id, @fname, @lname, @hired, @separated, @job_code, @store_id;
You can also select values from a VALUES statement that generates a single row into a set of user variables. In this case, you must employ a table alias, and you must assign each value from the value list to a variable. Each of the two statements shown here is equivalent to SET @x=2, @y=4, @z=8:

SELECT * FROM (VALUES ROW(2,4,8)) AS t INTO @x,@y,@z;

SELECT * FROM (VALUES ROW(2,4,8)) AS t(a,b,c) INTO @x,@y,@z;
User variable names are not case-sensitive. See Section 9.4, “User-Defined Variables”.

The SELECT ... INTO OUTFILE 'file_name' form of SELECT writes the selected rows to a file. The file is created on the server host, so you must have the FILE privilege to use this syntax. file_name cannot be an existing file, which among other things prevents files such as /etc/passwd and database tables from being modified. The character_set_filesystem system variable controls the interpretation of the file name.

The SELECT ... INTO OUTFILE statement is intended to enable dumping a table to a text file on the server host. To create the resulting file on some other host, SELECT ... INTO OUTFILE normally is unsuitable because there is no way to write a path to the file relative to the server host file system, unless the location of the file on the remote host can be accessed using a network-mapped path on the server host file system.

Alternatively, if the MySQL client software is installed on the remote host, you can use a client command such as mysql -e "SELECT ..." > file_name to generate the file on that host.

SELECT ... INTO OUTFILE is the complement of LOAD DATA. Column values are written converted to the character set specified in the CHARACTER SET clause. If no such clause is present, values are dumped using the binary character set. In effect, there is no character set conversion. If a result set contains columns in several character sets, so is the output data file, and it may not be possible to reload the file correctly.

The syntax for the export_options part of the statement consists of the same FIELDS and LINES clauses that are used with the LOAD DATA statement. For information about the FIELDS and LINES clauses, including their default values and permissible values, see Section 13.2.9, “LOAD DATA Statement”.

FIELDS ESCAPED BY controls how to write special characters. If the FIELDS ESCAPED BY character is not empty, it is used when necessary to avoid ambiguity as a prefix that precedes following characters on output:

The FIELDS ESCAPED BY character

The FIELDS [OPTIONALLY] ENCLOSED BY character

The first character of the FIELDS TERMINATED BY and LINES TERMINATED BY values

ASCII NUL (the zero-valued byte; what is actually written following the escape character is ASCII 0, not a zero-valued byte)

The FIELDS TERMINATED BY, ENCLOSED BY, ESCAPED BY, or LINES TERMINATED BY characters must be escaped so that you can read the file back in reliably. ASCII NUL is escaped to make it easier to view with some pagers.

The resulting file need not conform to SQL syntax, so nothing else need be escaped.

If the FIELDS ESCAPED BY character is empty, no characters are escaped and NULL is output as NULL, not \N. It is probably not a good idea to specify an empty escape character, particularly if field values in your data contain any of the characters in the list just given.

INTO OUTFILE can also be used with a TABLE statement when you want to dump all columns of a table into a text file. In this case, the ordering and number of rows can be controlled using ORDER BY and LIMIT; these clauses must precede INTO OUTFILE. TABLE ... INTO OUTFILE supports the same export_options as does SELECT ... INTO OUTFILE, and it is subject to the same restrictions on writing to the file system. An example of such a statement is shown here:

TABLE employees ORDER BY lname LIMIT 1000
    INTO OUTFILE '/tmp/employee_data_1.txt'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"', ESCAPED BY '\'
    LINES TERMINATED BY '\n';
You can also use SELECT ... INTO OUTFILE with a VALUES statement to write values directly into a file. An example is shown here:

SELECT * FROM (VALUES ROW(1,2,3),ROW(4,5,6),ROW(7,8,9)) AS t
    INTO OUTFILE '/tmp/select-values.txt';
You must use a table alias; column aliases are also supported, and can optionally be used to write values only from desired columns. You can also use any or all of the export options supported by SELECT ... INTO OUTFILE to format the output to the file.

Here is an example that produces a file in the comma-separated values (CSV) format used by many programs:

SELECT a,b,a+b INTO OUTFILE '/tmp/result.txt'
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  FROM test_table;
If you use INTO DUMPFILE instead of INTO OUTFILE, MySQL writes only one row into the file, without any column or line termination and without performing any escape processing. This is useful for selecting a BLOB value and storing it in a file.

TABLE also supports INTO DUMPFILE. If the table contains more than one row, you must also use LIMIT 1 to limit the output to a single row. INTO DUMPFILE can also be used with SELECT * FROM (VALUES ROW()[, ...]) AS table_alias [LIMIT 1]. See Section 13.2.19, “VALUES Statement”.

Note
Any file created by INTO OUTFILE or INTO DUMPFILE is owned by the operating system user under whose account mysqld runs. (You should never run mysqld as root for this and other reasons.) As of MySQL 8.0.17, the umask for file creation is 0640; you must have sufficient access privileges to manipulate the file contents. Prior to MySQL 8.0.17, the umask is 0666 and the file is writable by all users on the server host.

If the secure_file_priv system variable is set to a nonempty directory name, the file to be written must be located in that directory.

In the context of SELECT ... INTO statements that occur as part of events executed by the Event Scheduler, diagnostics messages (not only errors, but also warnings) are written to the error log, and, on Windows, to the application event log. For additional information, see Section 25.4.5, “Event Scheduler Status”.

As of MySQL 8.0.22, support is provided for periodic synchronization of output files written to by SELECT INTO OUTFILE and SELECT INTO DUMPFILE, enabled by setting the select_into_disk_sync server system variable introduced in that version. Output buffer size and optional delay can be set using, respectively, select_into_buffer_size and select_into_disk_sync_delay. For more information, see the descriptions of these system variables.


*******************************************************************************

*******************************************************************************

13.2.3 DO Statement
DO expr [, expr] ...
DO executes the expressions but does not return any results. In most respects, DO is shorthand for SELECT expr, ..., but has the advantage that it is slightly faster when you do not care about the result.

DO is useful primarily with functions that have side effects, such as RELEASE_LOCK().

Example: This SELECT statement pauses, but also produces a result set:

mysql> SELECT SLEEP(5);
+----------+
| SLEEP(5) |
+----------+
|        0 |
+----------+
1 row in set (5.02 sec)
DO, on the other hand, pauses without producing a result set.:

mysql> DO SLEEP(5);
Query OK, 0 rows affected (4.99 sec)
This could be useful, for example in a stored function or trigger, which prohibit statements that produce result sets.

DO only executes expressions. It cannot be used in all cases where SELECT can be used. For example, DO id FROM t1 is invalid because it references a table.


***************************************************************

****************************************************************

13.2.16 TABLE Statement
TABLE is a DML statement introduced in MySQL 8.0.19 which returns rows and columns of the named table.

TABLE table_name [ORDER BY column_name] [LIMIT number [OFFSET number]]
The TABLE statement in some ways acts like SELECT. Given the existence of a table named t, the following two statements produce identical output:

TABLE t;

SELECT * FROM t;
You can order and limit the number of rows produced by TABLE using ORDER BY and LIMIT clauses, respectively. These function identically to the same clauses when used with SELECT (including an optional OFFSET clause with LIMIT), as you can see here:

mysql> TABLE t;
+----+----+
| a  | b  |
+----+----+
|  1 |  2 |
|  6 |  7 |
|  9 |  5 |
| 10 | -4 |
| 11 | -1 |
| 13 |  3 |
| 14 |  6 |
+----+----+
7 rows in set (0.00 sec)

mysql> TABLE t ORDER BY b;
+----+----+
| a  | b  |
+----+----+
| 10 | -4 |
| 11 | -1 |
|  1 |  2 |
| 13 |  3 |
|  9 |  5 |
| 14 |  6 |
|  6 |  7 |
+----+----+
7 rows in set (0.00 sec)

mysql> TABLE t LIMIT 3;
+---+---+
| a | b |
+---+---+
| 1 | 2 |
| 6 | 7 |
| 9 | 5 |
+---+---+
3 rows in set (0.00 sec)

mysql> TABLE t ORDER BY b LIMIT 3;
+----+----+
| a  | b  |
+----+----+
| 10 | -4 |
| 11 | -1 |
|  1 |  2 |
+----+----+
3 rows in set (0.00 sec)

mysql> TABLE t ORDER BY b LIMIT 3 OFFSET 2;
+----+----+
| a  | b  |
+----+----+
|  1 |  2 |
| 13 |  3 |
|  9 |  5 |
+----+----+
3 rows in set (0.00 sec)
TABLE differs from SELECT in two key respects:

TABLE always displays all columns of the table.

Exception: The output of TABLE does not include invisible columns. See Section 13.1.20.10, “Invisible Columns”.

TABLE does not allow for any arbitrary filtering of rows; that is, TABLE does not support any WHERE clause.

For limiting which table columns are returned, filtering rows beyond what can be accomplished using ORDER BY and LIMIT, or both, use SELECT.

TABLE can be used with temporary tables.

TABLE can also be used in place of SELECT in a number of other constructs, including those listed here:

With set operators such as UNION, as shown here:

mysql> TABLE t1;
+---+----+
| a | b  |
+---+----+
| 2 | 10 |
| 5 |  3 |
| 7 |  8 |
+---+----+
3 rows in set (0.00 sec)

mysql> TABLE t2;
+---+---+
| a | b |
+---+---+
| 1 | 2 |
| 3 | 4 |
| 6 | 7 |
+---+---+
3 rows in set (0.00 sec)

mysql> TABLE t1 UNION TABLE t2;
+---+----+
| a | b  |
+---+----+
| 2 | 10 |
| 5 |  3 |
| 7 |  8 |
| 1 |  2 |
| 3 |  4 |
| 6 |  7 |
+---+----+
6 rows in set (0.00 sec)
The UNION just shown is equivalent to the following statement:

mysql> SELECT * FROM t1 UNION SELECT * FROM t2;
+---+----+
| a | b  |
+---+----+
| 2 | 10 |
| 5 |  3 |
| 7 |  8 |
| 1 |  2 |
| 3 |  4 |
| 6 |  7 |
+---+----+
6 rows in set (0.00 sec)
TABLE can also be used together in set operations with SELECT statements, VALUES statements, or both. See Section 13.2.18, “UNION Clause”, Section 13.2.4, “EXCEPT Clause”, and Section 13.2.8, “INTERSECT Clause”, for more information and examples. See also Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”.

With INTO to populate user variables, and with INTO OUTFILE or INTO DUMPFILE to write table data to a file. See Section 13.2.13.1, “SELECT ... INTO Statement”, for more specific information and examples.

In many cases where you can employ subqueries. Given any table t1 with a column named a, and a second table t2 having a single column, statements such as the following are possible:

SELECT * FROM t1 WHERE a IN (TABLE t2);
Assuming that the single column of table t1 is named x, the preceding is equivalent to each of the statements shown here (and produces exactly the same result in either case):

SELECT * FROM t1 WHERE a IN (SELECT x FROM t2);

SELECT * FROM t1 WHERE a IN (SELECT * FROM t2);
See Section 13.2.15, “Subqueries”, for more information.

With INSERT and REPLACE statements, where you would otherwise use SELECT *. See Section 13.2.7.1, “INSERT ... SELECT Statement”, for more information and examples.

TABLE can also be used in many cases in place of the SELECT in CREATE TABLE ... SELECT or CREATE VIEW ... SELECT. See the descriptions of these statements for more information and examples.

**********************************************************

**********************************************************

13.2.14 Set Operations with UNION, INTERSECT, and EXCEPT
Result Set Column Names and Data Types

Set Operations with TABLE and VALUES Statements

Set Operations using DISTINCT and ALL

Set Operations with ORDER BY and LIMIT

Limitations of Set Operations

SQL set operations combine the results of multiple query blocks into a single result. A query block, sometimes also known as a simple table, is any SQL statement that returns a result set, such as SELECT. MySQL 8.0 (8.0.19 and later) also supports TABLE and VALUES statements. See the individual descriptions of these statements elsewhere in this chapter for additional information.

The SQL standard defines the following three set operations:

UNION: Combine all results from two query blocks into a single result, omitting any duplicates.

INTERSECT: Combine only those rows which the results of two query blocks have in common, omitting any duplicates.

EXCEPT: For two query blocks A and B, return all results from A which are not also present in B, omitting any duplicates.

(Some database systems, such as Oracle, use MINUS for the name of this operator. This is not supported in MySQL.)

MySQL has long supported UNION; MySQL 8.0 adds support for INTERSECT and EXCEPT (MySQL 8.0.31 and later).

Each of these set operators supports an ALL modifier. When the ALL keyword follows a set operator, this causes duplicates to be included in the result. See the following sections covering the individual operators for more information and examples.

All three set operators also support a DISTINCT keyword, which suppresses duplicates in the result. Since this is the default behavior for set operators, it is usually not necessary to specify DISTINCT explicitly.

In general, query blocks and set operations can be combined in any number and order. A greatly simplified representation is shown here:

query_block [set_op query_block] [set_op query_block] ...

query_block:
    SELECT | TABLE | VALUES

set_op:
    UNION | INTERSECT | EXCEPT
This can be represented more accurately, and in greater detail, like this:

query_expression:
  [with_clause] /* WITH clause */ 
  query_expression_body
  [order_by_clause] [limit_clause] [into_clause]

query_expression_body:
    query_term
 |  query_expression_body UNION [ALL | DISTINCT] query_term
 |  query_expression_body EXCEPT [ALL | DISTINCT] query_term

query_term:
    query_primary
 |  query_term INTERSECT [ALL | DISTINCT] query_primary

query_primary:
    query_block
 |  '(' query_expression_body [order_by_clause] [limit_clause] [into_clause] ')'

query_block:   /* also known as a simple table */
    query_specification                     /* SELECT statement */
 |  table_value_constructor                 /* VALUES statement */
 |  explicit_table                          /* TABLE statement  */
You should be aware that INTERSECT is evaluated before UNION or EXCEPT. This means that, for example, TABLE x UNION TABLE y INTERSECT TABLE z is always evaluated as TABLE x UNION (TABLE y INTERSECT TABLE z). See Section 13.2.8, “INTERSECT Clause”, for more information.

In addition, you should keep in mind that, while the UNION and INTERSECT set operators are commutative (ordering is not significant), EXCEPT is not (order of operands affects the outcome). In other words, all of the following statements are true:

TABLE x UNION TABLE y and TABLE y UNION TABLE x produce the same result, although the ordering of the rows may differ. You can force them to be the same using ORDER BY; see ORDER BY and LIMIT in Unions.

TABLE x INTERSECT TABLE y and TABLE y INTERSECT TABLE x return the same result.

TABLE x EXCEPT TABLE y and TABLE y EXCEPT TABLE x do not yield the same result. See Section 13.2.4, “EXCEPT Clause”, for an example.

More information and examples can be found in the sections that follow.

Result Set Column Names and Data Types
The column names for the result of a set operation are taken from the column names of the first query block. Example:

mysql> CREATE TABLE t1 (x INT, y INT);
Query OK, 0 rows affected (0.04 sec)

mysql> INSERT INTO t1 VALUES ROW(4,-2), ROW(5,9);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> CREATE TABLE t2 (a INT, b INT);
Query OK, 0 rows affected (0.04 sec)

mysql> INSERT INTO t2 VALUES ROW(1,2), ROW(3,4);
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> TABLE t1 UNION TABLE t2;
+------+------+
| x    | y    |
+------+------+
|    4 |   -2 |
|    5 |    9 |
|    1 |    2 |
|    3 |    4 |
+------+------+
4 rows in set (0.00 sec)

mysql> TABLE t2 UNION TABLE t1;
+------+------+
| a    | b    |
+------+------+
|    1 |    2 |
|    3 |    4 |
|    4 |   -2 |
|    5 |    9 |
+------+------+
4 rows in set (0.00 sec)
This is true for UNION, EXCEPT, and INTERSECT queries.

Selected columns listed in corresponding positions of each query block should have the same data type. For example, the first column selected by the first statement should have the same type as the first column selected by the other statements. If the data types of corresponding result columns do not match, the types and lengths of the columns in the result take into account the values retrieved by all of the query blocks. For example, the column length in the result set is not constrained to the length of the value from the first statement, as shown here:

mysql> SELECT REPEAT('a',1) UNION SELECT REPEAT('b',20);
+----------------------+
| REPEAT('a',1)        |
+----------------------+
| a                    |
| bbbbbbbbbbbbbbbbbbbb |
+----------------------+
Set Operations with TABLE and VALUES Statements
Beginning with MySQL 8.0.19, you can also use a TABLE statement or VALUES statement wherever you can employ the equivalent SELECT statement. Assume that tables t1 and t2 are created and populated as shown here:

CREATE TABLE t1 (x INT, y INT);
INSERT INTO t1 VALUES ROW(4,-2),ROW(5,9);

CREATE TABLE t2 (a INT, b INT);
INSERT INTO t2 VALUES ROW(1,2),ROW(3,4);
The preceding being the case, and disregarding the column names in the output of the queries beginning with VALUES, all of the following UNION queries yield the same result:

SELECT * FROM t1 UNION SELECT * FROM t2;
TABLE t1 UNION SELECT * FROM t2;
VALUES ROW(4,-2), ROW(5,9) UNION SELECT * FROM t2;
SELECT * FROM t1 UNION TABLE t2;
TABLE t1 UNION TABLE t2;
VALUES ROW(4,-2), ROW(5,9) UNION TABLE t2;
SELECT * FROM t1 UNION VALUES ROW(4,-2),ROW(5,9);
TABLE t1 UNION VALUES ROW(4,-2),ROW(5,9);
VALUES ROW(4,-2), ROW(5,9) UNION VALUES ROW(4,-2),ROW(5,9);
To force the column names to be the same, wrap the query block on the left-hand side in a SELECT statement, and use aliases, like this:

mysql> SELECT * FROM (TABLE t2) AS t(x,y) UNION TABLE t1;
+------+------+
| x    | y    |
+------+------+
|    1 |    2 |
|    3 |    4 |
|    4 |   -2 |
|    5 |    9 |
+------+------+
4 rows in set (0.00 sec)
Set Operations using DISTINCT and ALL
By default, duplicate rows are removed from results of set operations. The optional DISTINCT keyword has the same effect but makes it explicit. With the optional ALL keyword, duplicate-row removal does not occur and the result includes all matching rows from all queries in the union.

You can mix ALL and DISTINCT in the same query. Mixed types are treated such that a set operation using DISTINCT overrides any such operation using ALL to its left. A DISTINCT set can be produced explicitly by using DISTINCT with UNION, INTERSECT, or EXCEPT, or implicitly by using the set operations with no following DISTINCT or ALL keyword.

In MySQL 8.0.19 and later, set operations work the same way when one or more TABLE statements, VALUES statements, or both, are used to generate the set.

Set Operations with ORDER BY and LIMIT
To apply an ORDER BY or LIMIT clause to an individual query block used as part of a union, intersection, or other set operation, parenthesize the query block, placing the clause inside the parentheses, like this:

(SELECT a FROM t1 WHERE a=10 AND b=1 ORDER BY a LIMIT 10)
UNION
(SELECT a FROM t2 WHERE a=11 AND b=2 ORDER BY a LIMIT 10);

(TABLE t1 ORDER BY x LIMIT 10) 
INTERSECT 
(TABLE t2 ORDER BY a LIMIT 10);
Use of ORDER BY for individual query blocks or statements implies nothing about the order in which the rows appear in the final result because the rows produced by a set operation are by default unordered. Therefore, ORDER BY in this context typically is used in conjunction with LIMIT, to determine the subset of the selected rows to retrieve, even though it does not necessarily affect the order of those rows in the final result. If ORDER BY appears without LIMIT within a query block, it is optimized away because it has no effect in any case.

To use an ORDER BY or LIMIT clause to sort or limit the entire result of a set operation, place the ORDER BY or LIMIT after the last statement:

SELECT a FROM t1
EXCEPT
SELECT a FROM t2 WHERE a=11 AND b=2
ORDER BY a LIMIT 10;

TABLE t1
UNION 
TABLE t2
ORDER BY a LIMIT 10;
If one or more individual statements make use of ORDER BY, LIMIT, or both, and, in addition, you wish to apply an ORDER BY, LIMIT, or both to the entire result, then each such individual statement must be enclosed in parentheses.

(SELECT a FROM t1 WHERE a=10 AND b=1)
EXCEPT
(SELECT a FROM t2 WHERE a=11 AND b=2)
ORDER BY a LIMIT 10;

(TABLE t1 ORDER BY a LIMIT 10) 
UNION 
TABLE t2 
ORDER BY a LIMIT 10;
A statement with no ORDER BY or LIMIT clause does need to be parenthesized; replacing TABLE t2 with (TABLE t2) in the second statement of the two just shown does not alter the result of the UNION.

You can also use ORDER BY and LIMIT with VALUES statements in set operations, as shown in this example using the mysql client:

mysql> VALUES ROW(4,-2), ROW(5,9), ROW(-1,3) 
    -> UNION 
    -> VALUES ROW(1,2), ROW(3,4), ROW(-1,3) 
    -> ORDER BY column_0 DESC LIMIT 3;
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        5 |        9 |
|        4 |       -2 |
|        3 |        4 |
+----------+----------+
3 rows in set (0.00 sec)
(You should keep in mind that neither TABLE statements nor VALUES statements accept a WHERE clause.)

This kind of ORDER BY cannot use column references that include a table name (that is, names in tbl_name.col_name format). Instead, provide a column alias in the first query block, and refer to the alias in the ORDER BY clause. (You can also refer to the column in the ORDER BY clause using its column position, but such use of column positions is deprecated, and thus subject to eventual removal in a future MySQL release.)

If a column to be sorted is aliased, the ORDER BY clause must refer to the alias, not the column name. The first of the following statements is permitted, but the second fails with an Unknown column 'a' in 'order clause' error:

(SELECT a AS b FROM t) UNION (SELECT ...) ORDER BY b;
(SELECT a AS b FROM t) UNION (SELECT ...) ORDER BY a;
To cause rows in a UNION result to consist of the sets of rows retrieved by each query block one after the other, select an additional column in each query block to use as a sort column and add an ORDER BY clause that sorts on that column following the last query block:

(SELECT 1 AS sort_col, col1a, col1b, ... FROM t1)
UNION
(SELECT 2, col2a, col2b, ... FROM t2) ORDER BY sort_col;
To maintain sort order within individual results, add a secondary column to the ORDER BY clause:

(SELECT 1 AS sort_col, col1a, col1b, ... FROM t1)
UNION
(SELECT 2, col2a, col2b, ... FROM t2) ORDER BY sort_col, col1a;
Use of an additional column also enables you to determine which query block each row comes from. Extra columns can provide other identifying information as well, such as a string that indicates a table name.

Limitations of Set Operations
Set operations in MySQL are subject to some limitations, which are described in the next few paragraphs.

Set operations including SELECT statements have the following limitations:

HIGH_PRIORITY in the first SELECT has no effect. HIGH_PRIORITY in any subsequent SELECT produces a syntax error.

Only the last SELECT statement can use an INTO clause. However, the entire UNION result is written to the INTO output destination.

As of MySQL 8.0.20, these two UNION variants containing INTO are deprecated; you should expect support for them to be removed in a future version of MySQL:

In the trailing query block of a query expression, use of INTO before FROM produces a warning. Example:

... UNION SELECT * INTO OUTFILE 'file_name' FROM table_name;
In a parenthesized trailing block of a query expression, use of INTO (regardless of its position relative to FROM) produces a warning. Example:

... UNION (SELECT * INTO OUTFILE 'file_name' FROM table_name);
Those variants are deprecated because they are confusing, as if they collect information from the named table rather than the entire query expression (the UNION).

Set operations with an aggregate function in an ORDER BY clause are rejected with ER_AGGREGATE_ORDER_FOR_UNION. Although the error name might suggest that this is exclusive to UNION queries, the preceding is also true for EXCEPT and INTERSECT queries, as shown here:

mysql> TABLE t1 INTERSECT TABLE t2 ORDER BY MAX(x);
ERROR 3028 (HY000): Expression #1 of ORDER BY contains aggregate function and applies to a UNION, EXCEPT or INTERSECT
A locking clause (such as FOR UPDATE or LOCK IN SHARE MODE) applies to the query block it follows. This means that, in a SELECT statement used with set operations, a locking clause can be used only if the query block and locking clause are enclosed in parentheses.

****************************************************************

****************************************************************

13.2.18 UNION Clause
query_expression_body UNION [ALL | DISTINCT] query_block
    [UNION [ALL | DISTINCT] query_expression_body]
    [...]

query_expression_body:
    See Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”
UNION combines the result from multiple query blocks into a single result set. This example uses SELECT statements:

mysql> SELECT 1, 2;
+---+---+
| 1 | 2 |
+---+---+
| 1 | 2 |
+---+---+
mysql> SELECT 'a', 'b';
+---+---+
| a | b |
+---+---+
| a | b |
+---+---+
mysql> SELECT 1, 2 UNION SELECT 'a', 'b';
+---+---+
| 1 | 2 |
+---+---+
| 1 | 2 |
| a | b |
+---+---+
UNION Handing in MySQL 8.0 Compared to MySQL 5.7
In MySQL 8.0, the parser rules for SELECT and UNION were refactored to be more consistent (the same SELECT syntax applies uniformly in each such context) and reduce duplication. Compared to MySQL 5.7, several user-visible effects resulted from this work, which may require rewriting of certain statements:

NATURAL JOIN permits an optional INNER keyword (NATURAL INNER JOIN), in compliance with standard SQL.

Right-deep joins without parentheses are permitted (for example, ... JOIN ... JOIN ... ON ... ON), in compliance with standard SQL.

STRAIGHT_JOIN now permits a USING clause, similar to other inner joins.

The parser accepts parentheses around query expressions. For example, (SELECT ... UNION SELECT ...) is permitted. See also Section 13.2.11, “Parenthesized Query Expressions”.

The parser better conforms to the documented permitted placement of the SQL_CACHE and SQL_NO_CACHE query modifiers.

Left-hand nesting of unions, previously permitted only in subqueries, is now permitted in top-level statements. For example, this statement is now accepted as valid:

(SELECT 1 UNION SELECT 1) UNION SELECT 1;
Locking clauses (FOR UPDATE, LOCK IN SHARE MODE) are allowed only in non-UNION queries. This means that parentheses must be used for SELECT statements containing locking clauses. This statement is no longer accepted as valid:

SELECT 1 FOR UPDATE UNION SELECT 1 FOR UPDATE;
Instead, write the statement like this:

(SELECT 1 FOR UPDATE) UNION (SELECT 1 FOR UPDATE);

*********************************************************************************

*********************************************************************************

13.2.4 EXCEPT Clause
query_expression_body EXCEPT [ALL | DISTINCT] query_expression_body
    [EXCEPT [ALL | DISTINCT] query_expression_body]
    [...]

query_expression_body:
    See Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”
EXCEPT limits the result from the first query block to those rows which are (also) not found in the second. As with UNION and INTERSECT, either query block can make use of any of SELECT, TABLE, or VALUES. An example using the tables a, b, and c defined in Section 13.2.8, “INTERSECT Clause”, is shown here:

mysql> TABLE a EXCEPT TABLE b;
+------+------+
| m    | n    |
+------+------+
|    2 |    3 |
+------+------+
1 row in set (0.00 sec)

mysql> TABLE a EXCEPT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    2 |    3 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE b EXCEPT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
+------+------+
1 row in set (0.00 sec)
As with UNION and INTERSECT, if neither DISTINCT nor ALL is specified, the default is DISTINCT.

DISTINCT removes duplicates found on either side of the relation, as shown here:

mysql> TABLE c EXCEPT DISTINCT TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
+------+------+
1 row in set (0.00 sec)

mysql> TABLE c EXCEPT ALL TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    1 |    3 |
+------+------+
2 rows in set (0.00 sec)
(The first statement has the same effect as TABLE c EXCEPT TABLE a.)

Unlike UNION or INTERSECT, EXCEPT is not commutative—that is, the result depends on the order of the operands, as shown here:

mysql> TABLE a EXCEPT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    2 |    3 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE c EXCEPT TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
+------+------+
1 row in set (0.00 sec)
As with UNION, the result sets to be compared must have the same number of columns. Result set column types are also determined as for UNION.

EXCEPT was added in MySQL 8.0.31.

***************************************************************

***************************************************************

13.2.8 INTERSECT Clause
query_expression_body INTERSECT [ALL | DISTINCT] query_expression_body
    [INTERSECT [ALL | DISTINCT] query_expression_body]
    [...]

query_expression_body:
    See Section 13.2.14, “Set Operations with UNION, INTERSECT, and EXCEPT”
INTERSECT limits the result from multiple query blocks to those rows which are common to all. Example:

mysql> TABLE a;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    2 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)

mysql> TABLE b;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    1 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)

mysql> TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    1 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)

mysql> TABLE a INTERSECT TABLE b;
+------+------+
| m    | n    |
+------+------+
|    1 |    2 |
|    3 |    4 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE a INTERSECT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    3 |    4 |
+------+------+
1 row in set (0.00 sec)
As with UNION and EXCEPT, if neither DISTINCT nor ALL is specified, the default is DISTINCT.

DISTINCT can remove duplicates from either side of the intersection, as shown here:

mysql> TABLE c INTERSECT DISTINCT TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    3 |    4 |
+------+------+
2 rows in set (0.00 sec)

mysql> TABLE c INTERSECT ALL TABLE c;
+------+------+
| m    | n    |
+------+------+
|    1 |    3 |
|    1 |    3 |
|    3 |    4 |
+------+------+
3 rows in set (0.00 sec)
(TABLE c INTERSECT TABLE c is the equivalent of the first of the two statements just shown.)

As with UNION, the operands must have the same number of columns. Result set column types are also determined as for UNION.

INTERSECT has greater precedence than and is evaluated before UNION and EXCEPT, so that the two statements shown here are equivalent:

TABLE r EXCEPT TABLE s INTERSECT TABLE t;

TABLE r EXCEPT (TABLE s INTERSECT TABLE t);
For INTERSECT ALL, the maximum supported number of duplicates of any unique row in the left hand table is 4294967295.

INTERSECT was added in MySQL 8.0.31.


***********************************************************************

***********************************************************************

13.2.19 VALUES Statement
VALUES is a DML statement introduced in MySQL 8.0.19 which returns a set of one or more rows as a table. In other words, it is a table value constructor which also functions as a standalone SQL statement.

VALUES row_constructor_list [ORDER BY column_designator] [LIMIT number]

row_constructor_list:
    ROW(value_list)[, ROW(value_list)][, ...]

value_list:
    value[, value][, ...]

column_designator:
    column_index
The VALUES statement consists of the VALUES keyword followed by a list of one or more row constructors, separated by commas. A row constructor consists of the ROW() row constructor clause with a value list of one or more scalar values enclosed in the parentheses. A value can be a literal of any MySQL data type or an expression that resolves to a scalar value.

ROW() cannot be empty (but each of the supplied scalar values can be NULL). Each ROW() in the same VALUES statement must have the same number of values in its value list.

The DEFAULT keyword is not supported by VALUES and causes a syntax error, except when it is used to supply values in an INSERT statement.

The output of VALUES is a table:

mysql> VALUES ROW(1,-2,3), ROW(5,7,9), ROW(4,6,8);
+----------+----------+----------+
| column_0 | column_1 | column_2 |
+----------+----------+----------+
|        1 |       -2 |        3 |
|        5 |        7 |        9 |
|        4 |        6 |        8 |
+----------+----------+----------+
3 rows in set (0.00 sec)
The columns of the table output from VALUES have the implicitly named columns column_0, column_1, column_2, and so on, always beginning with 0. This fact can be used to order the rows by column using an optional ORDER BY clause in the same way that this clause works with a SELECT statement, as shown here:

mysql> VALUES ROW(1,-2,3), ROW(5,7,9), ROW(4,6,8) ORDER BY column_1;
+----------+----------+----------+
| column_0 | column_1 | column_2 |
+----------+----------+----------+
|        1 |       -2 |        3 |
|        4 |        6 |        8 |
|        5 |        7 |        9 |
+----------+----------+----------+
3 rows in set (0.00 sec)
In MySQL 8.0.21 and later, the VALUES statement also supports a LIMIT clause for limiting the number of rows in the output. (Previously, LIMIT was allowed but did nothing.)

The VALUES statement is permissive regarding data types of column values; you can mix types within the same column, as shown here:

mysql> VALUES ROW("q", 42, '2019-12-18'),
    ->     ROW(23, "abc", 98.6),
    ->     ROW(27.0002, "Mary Smith", '{"a": 10, "b": 25}');
+----------+------------+--------------------+
| column_0 | column_1   | column_2           |
+----------+------------+--------------------+
| q        | 42         | 2019-12-18         |
| 23       | abc        | 98.6               |
| 27.0002  | Mary Smith | {"a": 10, "b": 25} |
+----------+------------+--------------------+
3 rows in set (0.00 sec)
Important
VALUES with one or more instances of ROW() acts as a table value constructor; although it can be used to supply values in an INSERT or REPLACE statement, do not confuse it with the VALUES keyword that is also used for this purpose. You should also not confuse it with the VALUES() function that refers to column values in INSERT ... ON DUPLICATE KEY UPDATE.

You should also bear in mind that ROW() is a row value constructor (see Section 13.2.15.5, “Row Subqueries”), whereas VALUES ROW() is a table value constructor; the two cannot be used interchangeably.

VALUES can be used in many cases where you could employ SELECT, including those listed here:

With UNION, as shown here:

mysql> SELECT 1,2 UNION SELECT 10,15;
+----+----+
| 1  | 2  |
+----+----+
|  1 |  2 |
| 10 | 15 |
+----+----+
2 rows in set (0.00 sec)

mysql> VALUES ROW(1,2) UNION VALUES ROW(10,15);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|       10 |       15 |
+----------+----------+
2 rows in set (0.00 sec)
You can union together constructed tables having more than one row, like this:

mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6)
     >     UNION VALUES ROW(10,15),ROW(20,25);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|        3 |        4 |
|        5 |        6 |
|       10 |       15 |
|       20 |       25 |
+----------+----------+
5 rows in set (0.00 sec)
You can also (and it is usually preferable to) omit UNION altogether in such cases and use a single VALUES statement, like this:

mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6), ROW(10,15), ROW(20,25);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|        3 |        4 |
|        5 |        6 |
|       10 |       15 |
|       20 |       25 |
+----------+----------+
VALUES can also be used in unions with SELECT statements, TABLE statements, or both.

The constructed tables in the UNION must contain the same number of columns, just as if you were using SELECT. See Section 13.2.18, “UNION Clause”, for further examples.

In MySQL 8.0.31 and later, you can use EXCEPT and INTERSECT with VALUES in much the same way as UNION, as shown here:

mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6)
    ->   INTERSECT 
    -> VALUES ROW(10,15), ROW(20,25), ROW(3,4);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        3 |        4 |
+----------+----------+
1 row in set (0.00 sec)
 
mysql> VALUES ROW(1,2), ROW(3,4), ROW(5,6)
    ->   EXCEPT 
    -> VALUES ROW(10,15), ROW(20,25), ROW(3,4);
+----------+----------+
| column_0 | column_1 |
+----------+----------+
|        1 |        2 |
|        5 |        6 |
+----------+----------+
2 rows in set (0.00 sec)
See Section 13.2.4, “EXCEPT Clause”, and Section 13.2.8, “INTERSECT Clause”, for more information.

In joins. See Section 13.2.13.2, “JOIN Clause”, for more information and examples.

In place of VALUES() in an INSERT or REPLACE statement, in which case its semantics differ slightly from what is described here. See Section 13.2.7, “INSERT Statement”, for details.

In place of the source table in CREATE TABLE ... SELECT and CREATE VIEW ... SELECT. See the descriptions of these statements for more information and examples.



