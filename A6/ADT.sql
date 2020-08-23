-- create ADT student user and grant privilages, use system role
CREATE USER ADT_student IDENTIFIED BY student DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP;

GRANT CONNECT, RESOURCE TO ADT_student;
ALTER USER ADT_student QUOTA UNLIMITED ON USERS;

-- to remove user
drop user ADT_student;


-- clear steps if needed
drop table TEMP_PERSON;
drop table TEMP_PERSON2;
drop table STUDENT;

drop type PERSON_TY;
drop type NAME_TY;
drop type ADDRESS_TY;

create or replace type NAME_TY as object(
prefix varchar(20),
first varchar(25),
middle varchar(25),
last varchar(25),
suffix varchar(20));

describe NAME_TY;

drop table TEMP_PERSON;
create table TEMP_PERSON(person NAME_TY);

select * from TEMP_PERSON

describe TEMP_PERSON;

insert into TEMP_PERSON (person)
values (NAME_TY('Mr','Jack','','Polnar',''));



select P.person.last, P.person.first, P.person.* from TEMP_PERSON P;

select P.person.last, P.person.first from TEMP_PERSON P;



create or replace type ADDRESS_TY as object(
address1 varchar(50),
address2 varchar(50),
city varchar(25),
state varchar(2),
postcd varchar(15));

drop table TEMP_PERSON2

create table TEMP_PERSON2(
name NAME_TY,
address ADDRESS_TY);


insert into TEMP_PERSON2 (name,address)
values (
        NAME_TY('Mr','Jack','','Polnar',''),
        ADDRESS_TY('808 Commonwealth Avenue','Room 250','Boston','MA', '02215'));
        
        
        insert into TEMP_PERSON2 (name,address)
values (
        NAME_TY('Prof','Robert','','Schudy',''),
        ADDRESS_TY('808 Commonwealth Avenue','Room 250','Boston','MA', '02215'));

select * from TEMP_PERSON2


select P.name.last, P.name.first, P.address.address1, P.address.address2, P.address.city, P.address.state, P.address.postcd 
from TEMP_PERSON2 P;


drop type PERSON_TY;


create or replace type PERSON_TY as object(
name NAME_TY,
address ADDRESS_TY,
DOB DATE);



desc PERSON_TY;

create table STUDENT(
person PERSON_TY,
BUID char(9));


--drop table STUDENT;

select * from STUDENT;
select BUID, S.person.name.first from STUDENT S;

insert into STUDENT(person,BUID)
values
(PERSON_TY(
        NAME_TY('Mr','Jack','','Polnar',''),
        ADDRESS_TY('808 Commonwealth Avenue','Room 250','Boston','MA','02215'),
        TO_DATE('01/01/2000','MM/DD/YYYY')),
        'U12345678');
  
  select S.BUID, S.person.name.last, S.person.name.first,
S.person.address.address1, S.person.address.address2, S.person.address.city, S.person.address.state, S.person.address.postcd 
from STUDENT S;

alter type NAME_TY add attribute gender char(1) CASCADE;

describe NAME_TY;

alter type NAME_TY drop attribute gender CASCADE;

describe NAME_TY;

create or replace type PERSON_TY as object(
name NAME_TY,
address ADDRESS_TY,
DOB DATE,
member function AGE(Birthdate IN DATE) return NUMBER) ;

describe PERSON_TY

alter type PERSON_TY add member function AGE(Birthdate IN DATE) return NUMBER cascade;


create or replace type body PERSON_TY as
member function AGE(Birthdate DATE) return NUMBER is
  begin
    RETURN ROUND(Sysdate-Birthdate)/365.25;
    end;
end;



select S.BUID, S.person.name.last, S.person.name.first, S.person.AGE(S.Person.DOB) as AGE,
S.person.address.address1, S.person.address.address2, S.person.address.city, S.person.address.state, S.person.address.postcd 
from STUDENT S;


create or replace type body PERSON_TY as
member function AGE(Birthdate DATE) return NUMBER is
  begin
    RETURN ROUND(ROUND(Sysdate-Birthdate)/365.25,1);
    end;
end;


select S.BUID, S.person.name.last, S.person.name.first, S.person.AGE(S.Person.DOB) as AGE,
S.person.address.address1, S.person.address.address2, S.person.address.city, S.person.address.state, S.person.address.postcd 
from STUDENT S;



