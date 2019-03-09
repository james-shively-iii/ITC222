-- 1. List all the tables in techcertificates.
SELECT table_name FROM information_schema.tables;

-- 2. List all the columns in Certificate along with their data types. 
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name='certificate';

-- 3. Create an index on lastname in person. 
CREATE INDEX ON person(lastname);

-- 4. Create an index on studentkey in roster. 
CREATE INDEX ON roster(studentkey);

-- 5. Create a multiple column index on coursesection which includes coursekey, quarterkey, and sectionyear. 
CREATE INDEX ON coursesection(coursekey,quarterkey,sectionyear);

-- 6. Backup the Techcertificates database to a SQL File. 
/*OPEN THE COMMAND LINE AND CHANGE DIRECTORY*/
cd C:\program files\postgresql\10\bin
/*THEN CREATE THE BACKUP INTO THE pgbackup FOLDER*/
pg_dump -U postgres -F p TechCert2 > c:\pgbackups\techcertificate.sql

-- 7. Restore Techcertificates to a techcertificates_copy database. (After success, drop the copy). 
/*OPEN THE COMMAND LINE AND CHANGE DIRECTORY*/
cd c:\program files\postgresql\10\bin
/*THEN RESTORE TO A COPIED DB*/
psql -U postgres -d techcert_copy -f c:\pgbackups\techcertificate.sql

-- 8. Create a role called mbrown (for Miriana Brown, one of the instructors) with a LOGIN and a password of ‘P@ssw0rd1’. 
CREATE ROLE mbrown WITH PASSWORD 'P@ssw0rd1' LOGIN INHERIT;

-- 9. Create a role called “instructorrole” that has permission to SELECT from all the tables in the schema public and in the instructorschema. (We only do select for now.) 
CREATE ROLE instructorrole WITH PASSWORD 'P@ssw0rd1' LOGIN;
GRANT CONNECT TO DATABASE TechCert2 TO instructorrole;
GRANT USAGE ON SCHEMA public TO instructorrole;
GRANT USAGE ON SCHEMA instructorschema TO instructorrole;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO instructorrole;
GRANT SELECT ON TABLE attendance TO instructorrole;
GRANT SELECT ON TABLE businessrule TO instructorrole;
GRANT SELECT ON TABLE certadmin TO instructorrole;
GRANT SELECT ON TABLE certificate TO instructorrole;
GRANT SELECT ON TABLE certificatecourse TO instructorrole;
GRANT SELECT ON TABLE course TO instructorrole;
GRANT SELECT ON TABLE coursesection TO instructorrole;
GRANT SELECT ON TABLE instructionalarea TO instructorrole;
GRANT SELECT ON TABLE instructor TO instructorrole;
GRANT SELECT ON TABLE instructorarea TO instructorrole;
GRANT SELECT ON TABLE location TO instructorrole;
GRANT SELECT ON TABLE logintable TO instructorrole;
GRANT SELECT ON TABLE person TO instructorrole;
GRANT SELECT ON TABLE pricehistory TO instructorrole;
GRANT SELECT ON TABLE quarter TO instructorrole;
GRANT SELECT ON TABLE roster TO instructorrole;
GRANT SELECT ON TABLE seminar TO instructorrole;
GRANT SELECT ON TABLE seminardetails TO instructorrole;
GRANT SELECT ON TABLE status TO instructorrole;
GRANT SELECT ON TABLE student TO instructorrole;
GRANT SELECT ON TABLE substitution TO instructorrole;

--10. Grant the instructorrole to mbrown. Test the login and permissions. 
GRANT instructorrole TO mbrown;