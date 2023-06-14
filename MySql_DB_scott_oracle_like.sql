DROP DATABASE IF EXISTS scott;

CREATE DATABASE scott
CHARACTER SET utf8MB4
COLLATE utf8MB4_general_ci;

use scott;

DROP TABLE IF EXISTS SALE;

DROP TABLE IF EXISTS EMP_BACKUP;

DROP TABLE IF EXISTS BONUS;

DROP TABLE IF EXISTS EMP;

DROP TABLE IF EXISTS DEPT;

DROP TABLE IF EXISTS SALGRADE;

DROP TABLE IF EXISTS PROVA;

CREATE TABLE DEPT
(
  DEPTNO  INT UNSIGNED,
  DNAME   VARCHAR(20),
  LOC     VARCHAR(20)
);

ALTER TABLE DEPT ADD (PRIMARY KEY DEPT_PK (DEPTNO));

CREATE TABLE EMP
(
  EMPNO     INT UNSIGNED,
  ENAME     VARCHAR(20),
  JOB       VARCHAR(20),
  MGR       INT UNSIGNED,
  HIREDATE  DATE,
  SAL       DOUBLE,
  COMM      DOUBLE,
  DEPTNO    INT UNSIGNED
);

ALTER TABLE EMP ADD (  PRIMARY KEY EMP_PK (EMPNO));

ALTER TABLE EMP ADD (
	FOREIGN KEY EMP_FK1 (MGR)  REFERENCES EMP (EMPNO),
    FOREIGN KEY EMP_FK2 (DEPTNO) REFERENCES DEPT (DEPTNO)
    );

CREATE TABLE SALGRADE
(
  GRADE     INT UNSIGNED,
  LOSAL     DOUBLE,
  HISAL     DOUBLE
);

CREATE TABLE BONUS
(
  EMPNO     INT UNSIGNED,
  BONUS     DOUBLE
);

ALTER TABLE BONUS ADD ( PRIMARY KEY BONUS_PK  (EMPNO));

ALTER TABLE BONUS ADD (  FOREIGN KEY BONUS_FK1 (EMPNO)   REFERENCES EMP (EMPNO));

start transaction;

insert into dept values (10,'ACCOUNTING','NEW YORK');
insert into dept values (20,'RESEARCH','DALLAS');
insert into dept values (30,'SALES','CHICAGO');
insert into dept values (40,'OPERATIONS','BOSTON');

Insert into EMP
   (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
 Values
    (7839, 'KING', 'PRESIDENT', null,'1981-11-17', 8857.81,    null, 10), 
   (7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01',    5048.96, null, 30),
   (7782, 'CLARK', 'MANAGER', 7839, '1981-06-09',    4340.34, null, 10),
   (7566, 'JONES', 'MANAGER', 7839, '1981-04-02',    5270.4, null, 20),
   (7788, 'SCOTT', 'ANALYST', 7566, '1982-12-09',    5314.68, null, 20),
   (7902, 'FORD', 'ANALYST', 7566, '1981-12-03',    5314.68, null, 20),
   (7369, 'SMITH', 'CLERK', 7902, '1980-12-17',    1714.88, null, 20),
   (7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20',    2834.5, null, 20),
   (7521, 'WARD', 'SALESMAN', 7698, '1981-02-22',    2214.45, 500, 30),
   (7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28',    2214.45, 1400, 30),
   (7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08',    2657.35, 0, 30),
   (7876, 'ADAMS', 'CLERK', 7788, '1983-01-12',    1948.72, null, 20),
    (7900, 'JAMES', 'CLERK', 7698, '1981-12-03',    1682.99, null, 30),
    (7934, 'MILLER', 'CLERK', 7782, '1982-01-23',    2303.03, null, 10)
   ;

insert into salgrade values (1, 0, 1000);
insert into salgrade values (2, 1000.01, 2000);
insert into salgrade values (3, 2000.01, 3000);
insert into salgrade values (4, 3000.01, 4000);
insert into salgrade values (5, 4000.01, 5000);
insert into salgrade values (6, 5000.01, 6000);
insert into salgrade values (7, 6000.01, 7000);
insert into salgrade values (8, 7000.01, 8000);
insert into salgrade values (9, 8000.01, 9000);
insert into salgrade values (10, 9000.01, 99999.99);

commit;

CREATE TABLE PROVA
(
  N  double,
  T  VARCHAR(50),
  D  DATE
);
