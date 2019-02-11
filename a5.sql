
1. Insert a new course called testcourse. It will be worth 0 credits and the description will simple say “this is a test.”
BEGIN TRANSACTION;

CREATE SEQUENCE course_coursekey_seq START;

INSERT INTO course(coursekey, coursename, credits, coursedescription)
VALUES(nextval('course_coursekey_seq'), 'testcourse', 0, 'this is a test');

COMMIT TRANSACTION;

2-4. Add a new student:
Roberta Hernadez
apt 101, 234 Nelson Street
Seattle, WA 98122
2065552019
rhernadez@outlook.com

The date added should be today. You will also need to add her to the logintable. The username should be the first letter of her first name and her whole last name. To get the password, use the CRYPT function like this:

crypt(‘HernadezPass’, gen_salt('bf', 8))
BEGIN TRANSACTION;
INSERT INTO person(lastname,firstname,email,address,city,state,postalcode,phone,dateadded)
VALUES('Hernadez', 'Roberta', 'rhernadez@outlook.com', '234 Nelson Street apt 101', 'Seattle', 'WA', 98122, 2065552019, current_timestamp);

INSERT INTO student(personkey, studentstartdate, statuskey)
VALUES((SELECT MAX(personkey) FROM person), current_timestamp, 1);

INSERT INTO logintable(username, personkey, userpassword, datelastchanged)
SELECT LOWER(SUBSTRING(firstname,1,1) || lastname), MAX(personkey), CRYPT('HernadezPass', gen_salt('bf',8)), current_timestamp
FROM person
WHERE personkey = 405
GROUP BY firstname, lastname;
COMMIT TRANSACTION;

5-7.  Add a new instructor.
Marylin Brenen
1983 South Madison
Seattle. WA, 98122
2065557798

Her work email will be Marylin.Brenen@getcerts.com

Her instructional areas are web design, javascript and mobile apps development.

You will need to add her to the login table just like the student in the exercise above.
BEGIN TRANSACTION;
INSERT INTO person(lastname,firstname,email,address,city,state,postalcode,phone,dateadded)
VALUES('Brenen', 'Marylin', 'marylin.brenen@getcerts.com', '1983 South Madison', 'Seattle', 'WA', 98122, 2065557798, current_timestamp);

INSERT INTO instructor(personkey, hiredate, statuskey)
VALUES((SELECT MAX(personkey) FROM person), current_timestamp, 1);

INSERT INTO instructorarea(instructionalareakey, instructorkey)
VALUES((SELECT instructionalareakey FROM instructionalarea WHERE instructionalareakey=2)
,(SELECT instructorkey FROM instructor WHERE instructorkey=12));
INSERT INTO instructorarea(instructionalareakey, instructorkey)
VALUES((SELECT instructionalareakey FROM instructionalarea WHERE instructionalareakey=3)
,(SELECT instructorkey FROM instructor WHERE instructorkey=12));
INSERT INTO instructorarea(instructionalareakey, instructorkey)
VALUES((SELECT instructionalareakey FROM instructionalarea WHERE instructionalareakey=4)
,(SELECT instructorkey FROM instructor WHERE instructorkey=12));
COMMIT TRANSACTION;

8. Geraldine Clark (personkey 211) notified the school that her last name was wrong, It should be “Clarkston.” Also, her email should be geraldineclark@msn.com. Make those changes.
BEGIN TRANSACTION;
UPDATE person
SET lastname='Clarkston',
email='geraldineclark@msn.com'
WHERE personkey=211;
COMMIT TRANSACTION;

9.    Luke Smith, studentkey 19, was mistakenly give the grade 2.23 for the course with the roster key 1179. It should be 3.22. UPDATE Roster to the correct grade.
BEGIN TRANSACTION;
UPDATE roster
SET finalgrade=3.22
WHERE studentkey=19
AND rosterkey=1179; 
COMMIT TRANSACTION;

10.   Delete testcourse from the course table 
BEGIN TRANSACTION;
DELETE FROM course WHERE coursename='testcourse';
COMMIT TRANSACTION;