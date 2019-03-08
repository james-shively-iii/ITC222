--1. The user name in the login table is like the user name in Community Assist except it does not put it all in lower case. For instance, Vivian Justice becomes VJustice. Make a FUNCTION that takes in the first name and lastname as parameters and returns a username.
CREATE OR REPLACE FUNCTION makeusername
(firstname TEXT, lastname TEXT)
RETURNS TEXT
AS $$
BEGIN
RETURN SUBSTRING(firstname, 1,1) || lastname;
END;
$$ LANGUAGE plpgsql;
--Check to see if this function works
SELECT makeusername('Sado', 'Slim');

--2. CREATE a FUNCTION that returns the number of credits in a certificate. It takes a certificatekey as a parameter and returns INTEGER. You will need to join course and certificate course to do this. You can return the query to do this. Just write RETURN (SELECT etc.).
CREATE OR REPLACE FUNCTION certcredits(certkey INTEGER)
RETURNS INTEGER
AS $$
BEGIN
RETURN (
	SELECT SUM(credits) 
	FROM course c
	INNER JOIN certificatecourse cc
	ON c.coursekey=cc.coursekey
	INNER JOIN certificate cert 
	ON cc.certificatekey=cert.certificatekey
	WHERE cert.certificatekey=certkey
);
END;
$$ LANGUAGE plpgsql;
--Check to see if this function works
SELECT certcredits(6);

--3. CREATE a FUNCTION that returns the cost of a section. You will need to join course, coursesection and pricehistory to do this. The query should take the sectionkey as a parameter and return NUMERIC.
CREATE OR REPLACE FUNCTION courseprice(sk INTEGER)
RETURNS TABLE( 
	"Base Cost" NUMERIC, 
	"Discounted" NUMERIC
	)
AS $$
BEGIN
RETURN QUERY
SELECT
(SUM(c.credits) * ph.pricepercredit) AS "Base Cost", 
(SUM(c.credits) * ph.pricepercredit * (1 - ph.pricediscount)) AS "Discounted"
FROM course c
INNER JOIN coursesection cs
ON c.coursekey=cs.coursekey
INNER JOIN pricehistory ph
ON ph.pricehistorykey=cs.pricehistorykey
WHERE cs.sectionkey=sk
GROUP BY cs.sectionkey, ph.pricepercredit, ph.pricediscount;
END;
$$ LANGUAGE plpgsql;
--Check to see if this function works
SELECT * FROM courseprice(3);

--4. CREATE a FUNCTION that returns the total number of credits a student has taken.
CREATE OR REPLACE FUNCTION coursecreds(sk INTEGER)
RETURNS TABLE ( 
	"Credits Taken" BIGINT
	)
AS $$
BEGIN
RETURN QUERY
SELECT SUM(c.credits) AS "Credits Taken"
FROM student s
INNER JOIN roster r 
ON s.studentkey = r.studentkey
INNER JOIN coursesection cs
ON r.sectionkey = cs.sectionkey
INNER JOIN course c 
ON cs.coursekey = c.coursekey
WHERE s.studentkey = sk;
END;
$$ LANGUAGE plpgsql;
--Check to see if this function works
SELECT coursecreds(120);

--5. CREATE a FUNCTION that returns a table containing the coursename, credits and grade for each course they have taken
CREATE OR REPLACE FUNCTION coursestaken(sk INTEGER)
RETURNS TABLE(
	"Courses Taken" TEXT, 
	"Course Credits" INTEGER, 
	"Final Grade" NUMERIC
	)
AS $$
BEGIN
RETURN QUERY
SELECT coursename, credits, finalgrade
FROM student s
INNER JOIN roster r 
ON s.studentkey=r.studentkey
INNER JOIN coursesection cs 
ON cs.sectionkey=r.sectionkey
INNER JOIN course c
ON c.coursekey=cs.coursekey
WHERE s.studentkey=sk
AND finalgrade IS NOT NULL;
END;
$$ LANGUAGE plpgsql;
--Check to see if this function works
SELECT * FROM coursestaken(120);

--6. CREATE a procedure type Function that inserts a new student. You will need to INSERTinto person, student and logintable.
CREATE OR REPLACE FUNCTION addstudent(
	"First Name" TEXT, 
	"Last Name" TEXT, 
	Email TEXT, 
	Address TEXT, 
	City TEXT, 
	"State" CHAR(2), 
	Zip TEXT, 
	Phone CHAR(14), 
	Newsletter BOOLEAN, 
	Status INTEGER, 
	Pass TEXT
)
RETURNS VOID
AS $$
INSERT INTO person (firstname, lastname, email, address, city, state, postalcode, phone, dateadded, newsletter)
VALUES ("First Name", "Last Name", Email, Address, City, "State", Zip, Phone, current_timestamp, Newsletter);
INSERT INTO student (personkey, studentstartdate, statuskey)
VALUES (currval('person_personkey_seq'), current_timestamp, Status);
INSERT INTO logintable(username, personkey, userpassword, datelastchanged)
VALUES (makeusername("First Name", "Last Name"), currval('person_personkey_seq'), crypt(Pass, gen_salt('bf', 8)), current_timestamp);
$$ LANGUAGE sql;
--Check to see if this function works
SELECT addstudent('Sara', 'Spring', 'saraspring@example.com', '2896 58th Ave SW.', 'Seattle', 'WA', '98126', '2065559665', true, 4, 'SaraPass');
SELECT * FROM person WHERE lastname='Spring';
SELECT * FROM student WHERE personkey=414;
SELECT * FROM logintable WHERE personkey=414;

--7. CREATE a procedure that lets a student UPDATE their own information (name, email, phone and addresses only.)
CREATE OR REPLACE FUNCTION updatestudent(
	SK INTEGER, 
	"First Name" TEXT, 
	"Last Name" TEXT, 
	Email TEXT, 
	Phone CHAR(14), 
	Address TEXT, 
	City TEXT, 
	"State" CHAR(2), 
	Zip TEXT
)
RETURNS VOID
AS $$
UPDATE person p
SET firstname="First Name", lastname="Last Name", email=Email, phone=Phone, address=Address, city=City, 
state="State", postalcode=Zip
WHERE p.personkey=(SELECT s.personkey FROM student s WHERE s.studentkey=SK);
$$ LANGUAGE sql;
--Check to see if this function works
SELECT updatestudent(
	(SELECT studentkey 
	FROM student 
	WHERE personkey=(
		SELECT personkey 
		FROM person 
		WHERE firstname='Sao')),
	'Sado', 'James', 'sadojames@example.com', '3305555685', '321 Fake Avenue', 'Faux Valley', 'OH', '44512'
);

--8. ALTER the roster table to ADD a Boolean column called lowgradeflag. The DEFAULT is false.
ALTER TABLE roster 
ADD lowgradeflag boolean 
DEFAULT false;

--9. CREATE a trigger FUNCTION that flags a grade if it is less than 2.0.
CREATE OR REPLACE FUNCTION setflag()
RETURNS TRIGGER AS
$BODY$
BEGIN
IF NEW.finalgrade < 2.0
THEN
UPDATE roster r
SET lowgradeflag=TRUE
WHERE r.rosterkey=NEW.rosterkey;
ELSE
SET lowgradeflag=false;
END IF;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;
CREATE TRIGGER flag_finalgrade
AFTER INSERT
ON roster
FOR EACH ROW
EXECUTE PROCEDURE setflag();

--10. CREATE a trigger on the table roster that fires after UPDATE and EXECUTES the TRIGGER FUNCTION created in exercise 9.
CREATE OR REPLACE FUNCTION setflag()
RETURNS TRIGGER AS
$BODY$
BEGIN
IF NEW.finalgrade < 2.0
THEN
UPDATE roster r
SET lowgradeflag = TRUE
WHERE r.rosterkey = NEW.rosterkey;
END IF;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;
CREATE TRIGGER fire_fgf
AFTER UPDATE
ON roster
FOR EACH ROW
EXECUTE PROCEDURE setflag();
/***THIS LAST PROBLEM I WAS HAVING ISSUES WITH AND THIS IS
	THE BEST I COULD COME UP WITH						***/