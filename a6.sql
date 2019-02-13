1. Write the SQL to CREATE the location table. Run it to debug any errors
CREATE TABLE location(
	locationkey SERIAL NOT NULL,
	locationname TEXT NOT NULL,
	locationaddress TEXT NOT NULL,
	locationcity TEXT NOT NULL,
	locationstate CHAR(2) NOT NULL,
	postalcode VARCHAR(12) NOT NULL,
	phone VARCHAR(13) NOT NULL,
	email TEXT NOT NULL UNIQUE,
	CONSTRAINT location_pk PRIMARY KEY (locationkey)
);

2. Write the SQL to CREATE the seminar table. Run it to debug any errors.
CREATE TABLE seminar(
	seminarkey SERIAL NOT NULL,
	locationkey INT NOT NULL,
	theme TEXT NOT NULL,
	seminardate DATE NOT NULL,
	description TEXT,
	CONSTRAINT seminar_pk PRIMARY KEY (seminarkey),
	CONSTRAINT location_locationkey_fk FOREIGN KEY (locationkey)
		REFERENCES location(locationkey) MATCH SIMPLE
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);

3. Write the SQL to create the seminardetails table, but don’t include the keys in the definition.  Run the code to debug for errors.
CREATE TABLE seminardetails(
	seminardetailkey SERIAL NOT NULL,
	seminarkey INT NOT NULL,
	topic TEXT NOT NULL,
	presenttime TIME WITHOUT TIME ZONE,
	room CHAR(5),
	instructorkey INT,
	description TEXT
);

4. ALTER the seminardetails table to add the PRIMARY KEY.
ALTER TABLE seminardetails 
ADD PRIMARY KEY (seminardetailkey);

5. ALTER the seminardetails table to add the FOREIGN KEYS
ALTER TABLE seminardetails
ADD CONSTRAINT seminarkey_fk FOREIGN KEY (seminarkey)
	REFERENCES seminar(seminarkey);
ALTER TABLE seminardetails
ADD CONSTRAINT instructorkey_fk FOREIGN KEY (instructorkey)
	REFERENCES instructor(instructorkey);

6. Write the SQL to create the attendance table. Run the code to debug any errors.
CREATE TABLE attendance(
	attendancekey SERIAL NOT NULL,
	seminardetailkey INT NOT NULL,
	personkey INT NOT NULL,
	CONSTRAINT attendancekey_pk PRIMARY KEY (attendancekey),
	CONSTRAINT seminardetails_seminardk_fk FOREIGN KEY (seminardetailkey)
		REFERENCES seminardetails(seminardetailkey) MATCH SIMPLE
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT person_personkey_fk FOREIGN KEY (personkey)
		REFERENCES person(personkey) MATCH SIMPLE
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);

7. ALTER the person table to add a BOOLEAN column “newsletter” the default is “true.”
ALTER TABLE person 
ADD newsletter BOOLEAN DEFAULT TRUE;

8. Add a CHECK CONSTRAINT to the finalgrade column that sets the range between 0 and 4.
ALTER TABLE roster
ADD CONSTRAINT chk_grade CHECK(finalgrade BETWEEN 0 AND 4);

9. CREATE a TEMP table that contains all the students in roster that have a NULL grade.
CREATE TEMP TABLE nullgrade(
	lastname TEXT,
	firstname TEXT
);

INSERT INTO nullgrade(lastname,firstname)
SELECT lastname, firstname
FROM person p
INNER JOIN student s
ON p.personkey=s.personkey
INNER JOIN roster r
ON r.studentkey=s.studentkey
WHERE finalgrade IS NULL;

10. DROP the TEMP table.
DROP TABLE nullgrade;