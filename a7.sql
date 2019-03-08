--1. Create a new instructor SCHEMA named instructorschema.
CREATE SCHEMA instructorschema;

--2. Create a VIEW in the instructorschema that provides a roster for section 71. It should include the students first and last names and their email.
CREATE VIEW instructorschema.roster71
AS
SELECT r.studentkey AS "ID",
lastname || ', ' || firstname AS "Name",
email AS "Email"
FROM person p
INNER JOIN student s
ON p.personkey=s.personkey
INNER JOIN roster r
ON s.studentkey=r.studentkey
WHERE sectionkey=71
ORDER BY r.studentkey ASC;

--3. Create an UPDATABLE VIEW in the instructorschema based on the table person that only includes those that live in the state of Washington.
CREATE VIEW instructorschema.people
AS
SELECT personkey AS "PK",
lastname AS "Last",
firstname AS "First",
email AS "Email",
address AS "Address",
city AS "City",
state AS "State",
postalcode AS "Zip",
phone AS "Phone",
dateadded AS "Date Added"
FROM person
WHERE state='WA'
ORDER BY dateadded
WITH CHECK OPTION;

--4. Insert this person information through the VIEW: Melanie Jackson, meljack@gmail.com, 111 South Anderson Street, Seattle, WA, 98002,2065552323. The date added can be the current date and time.
INSERT INTO instructorschema.people("Last", "First", "Email","Address","City","State","Zip","Phone","Date Added")
VALUES('Jackson','Melanie','meljack@gmail.com','111 South Anderson Street','Seattle','WA',98002,2065552323,current_timestamp);

--5. UPDATE through the VIEW to change personkey 330. Set the firstname from “Kane” to “Kenneth”
UPDATE instructorschema.people
SET "First"='Kenneth'
WHERE "PK"=330;

--6. Revise the VIEW to add the CHECK OPTION.
CREATE OR REPLACE VIEW instructorschema.people
AS
SELECT personkey AS "PK",
lastname AS "Last",
firstname AS "First",
email AS "Email",
address AS "Address",
city AS "City",
state AS "State",
postalcode AS "Zip",
phone AS "Phone",
dateadded AS "Date Added"
FROM person
WHERE state='WA'
ORDER BY dateadded
WITH CHECK OPTION;

--7. INSERT the following person through the VIEW: Rachel Norman, rachelnorman@msn.com, 212 Mercer Avenue, New York, NY, 00234, 1035552310. The date can be current date and time. Turn in both the SQL for changed VIEW and the resulting message.
INSERT INTO instructorschema.people(
	"Last","First","Email","Address",
	"City","State","Zip","Phone","Date Added"
)
VALUES(
	'Norman','Rachel','rachelnorman@msn.com',
	'212 Mercer Avenue', 'New York City', 'NY',
	00234, 1035552310, current_timestamp
);
ERROR: new row violates check option for view "people" DETAIL: Failing row contains (406, Norman, Rachel, rachelnorman@msn.com, 212 Mercer Avenue, New York City, NY, 234, 1035552310 , 2019-02-14, t). SQL state: 44000

--8. Create a MATERIALIZED VIEW in the instructorschema that includes the first name, last name, student start date and status of every student.
CREATE MATERIALIZED VIEW instructorschema.studentstatus
AS
SELECT DISTINCT ON (s.studentkey) s.studentkey AS "ID Key",
lastname || ', ' || firstname AS "Name",
studentstartdate AS "Start Date",
statusname AS "Status"
FROM student s
INNER JOIN person p
ON p.personkey=s.personkey
INNER JOIN roster r
ON r.studentkey=s.studentkey
INNER JOIN status st
ON st.statuskey=s.statuskey
ORDER BY s.studentkey ASC
WITH DATA;

--9. Add Melanie Jackson from number 4 above to the student table. Make her start date whatever the start date for the current session is.
INSERT INTO student(
    personkey,
    studentstartdate,
    statuskey
)
VALUES(
	(SELECT personkey FROM person WHERE personkey=405),
	'2019-01-02',
	(SELECT statuskey FROM status WHERE statusname='current')
);

--10. REFRESH THE MATERIALIZED VIEW
REFRESH MATERIALIZED VIEW instructorschema.studentstatus;