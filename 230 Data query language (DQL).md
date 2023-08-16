# Data query language (DQL)


********************************************************************

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









