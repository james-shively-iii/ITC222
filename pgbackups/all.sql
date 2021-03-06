--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE employeerole;
ALTER ROLE employeerole WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE janderson;
ALTER ROLE janderson WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5a6e07e39fe17f79fd3b8b4f1d1fb784f';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md510027034238ff0de7231e34e87ac1ea6';






--
-- Database creation
--

CREATE DATABASE "CommunityAssist" WITH TEMPLATE = template0 OWNER = postgres;
CREATE DATABASE "MilzOdaz" WITH TEMPLATE = template0 OWNER = postgres;
CREATE DATABASE "TechCert2" WITH TEMPLATE = template0 OWNER = postgres;
REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


\connect "CommunityAssist"

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 10.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: clientschema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA clientschema;


ALTER SCHEMA clientschema OWNER TO postgres;

--
-- Name: donorschema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA donorschema;


ALTER SCHEMA donorschema OWNER TO postgres;

--
-- Name: employeeschema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA employeeschema;


ALTER SCHEMA employeeschema OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: getdonations(integer); Type: FUNCTION; Schema: donorschema; Owner: postgres
--

CREATE FUNCTION donorschema.getdonations(donorkey integer) RETURNS TABLE("Date" timestamp without time zone, "Amount" numeric, "Validation" uuid)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT donationdate, donationamount, donationvalidation
FROM donation
WHERE personkey=donorkey;
END;
$$;


ALTER FUNCTION donorschema.getdonations(donorkey integer) OWNER TO postgres;

--
-- Name: donationpercentages(numeric, numeric); Type: FUNCTION; Schema: employeeschema; Owner: postgres
--

CREATE FUNCTION employeeschema.donationpercentages(amount numeric, percentage numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
IF percentage > 1
THEN
	RETURN amount * percentage / 100;
ELSE
	RETURN amount * percentage;
END IF;
END;
$$;


ALTER FUNCTION employeeschema.donationpercentages(amount numeric, percentage numeric) OWNER TO postgres;

--
-- Name: addperson(text, text, text, text, text, text, text, character, character, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addperson(firstname text, lastname text, email text, phone text, apartment text, street text, city text, state character, zipcode character, passwd character varying) RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO person(
	personfirstname, personlastname, personemail, personprimaryphone,
	persondateadded)
VALUES(firstname, lastname, email, phone, current_timestamp);
INSERT INTO personaddress(
	personkey, personaddressapt, personaddressstreet,
	personaddresscity, personaddressstate,
	personaddresszipcode
)
VALUES(CURRVAL('person_personkey_seq'), apartment, street, city, "state", zipcode);
INSERT INTO logintable(personkey, personusername, personpassword)
VALUES(CURRVAL('person_personkey_seq'), makeusername(firstname, lastname), createpassword(passwd));
$$;


ALTER FUNCTION public.addperson(firstname text, lastname text, email text, phone text, apartment text, street text, city text, state character, zipcode character, passwd character varying) OWNER TO postgres;

--
-- Name: createpassword(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.createpassword(pass character varying) RETURNS text
    LANGUAGE sql
    AS $$Select crypt(pass, gen_salt('bf', 8))$$;


ALTER FUNCTION public.createpassword(pass character varying) OWNER TO postgres;

--
-- Name: cube(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cube(num integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN num * num * num;
END;
$$;


ALTER FUNCTION public.cube(num integer) OWNER TO postgres;

--
-- Name: editperson(integer, text, text, text, text, text, text, text, character, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.editperson(pkey integer, firstname text, lastname text, email text, phone text, apartment text, street text, city text, state character, zipcode character) RETURNS void
    LANGUAGE sql
    AS $$
UPDATE person
SET personfirstname=firstname,
personlastname=lastname,
personemail=email,
personprimaryphone=phone
WHERE personkey=pkey;
UPDATE personaddress
SET personaddressapt=apartment,
personaddressstreet="state",
personaddresszipcode=zipcode
WHERE personkey=pkey;
$$;


ALTER FUNCTION public.editperson(pkey integer, firstname text, lastname text, email text, phone text, apartment text, street text, city text, state character, zipcode character) OWNER TO postgres;

--
-- Name: makeusername(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.makeusername(firstname text, lastname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN LOWER(SUBSTRING(firstname, 1,1) || lastname);
END;
$$;


ALTER FUNCTION public.makeusername(firstname text, lastname text) OWNER TO postgres;

--
-- Name: validatelogin(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validatelogin(username character varying, pass character varying) RETURNS integer
    LANGUAGE sql
    AS $$
Select LoginKey from LoginTable where PersonUserName =username
and PersonPassword=crypt(pass,PersonPassword)
$$;


ALTER FUNCTION public.validatelogin(username character varying, pass character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: donation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donation (
    donationkey integer NOT NULL,
    personkey integer,
    donationamount numeric NOT NULL,
    donationdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    donationvalidation uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.donation OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    personkey integer NOT NULL,
    personlastname character varying(255) NOT NULL,
    personfirstname character varying(255),
    personemail character varying(255) NOT NULL,
    personprimaryphone character(13),
    persondateadded date NOT NULL
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: topdonors; Type: MATERIALIZED VIEW; Schema: donorschema; Owner: postgres
--

CREATE MATERIALIZED VIEW donorschema.topdonors AS
 SELECT person.personlastname AS lastname,
    person.personfirstname AS firstname,
    donation.donationdate,
    donation.donationamount AS amount
   FROM (public.person
     JOIN public.donation ON ((person.personkey = donation.personkey)))
  ORDER BY donation.donationamount DESC
 LIMIT 10
  WITH NO DATA;


ALTER TABLE donorschema.topdonors OWNER TO postgres;

--
-- Name: emailview; Type: VIEW; Schema: employeeschema; Owner: postgres
--

CREATE VIEW employeeschema.emailview AS
 SELECT person.personlastname,
    person.personfirstname,
    person.personemail
   FROM public.person
  WITH CASCADED CHECK OPTION;


ALTER TABLE employeeschema.emailview OWNER TO postgres;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    employeekey integer NOT NULL,
    personkey integer
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: employeeposition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employeeposition (
    employeepositionkey integer NOT NULL,
    employeekey integer,
    positionkey integer,
    employeepositionstartdate date
);


ALTER TABLE public.employeeposition OWNER TO postgres;

--
-- Name: jobposition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobposition (
    positionkey integer NOT NULL,
    positionname character varying(255),
    positiondescript character varying(255)
);


ALTER TABLE public.jobposition OWNER TO postgres;

--
-- Name: employeeview; Type: VIEW; Schema: employeeschema; Owner: postgres
--

CREATE VIEW employeeschema.employeeview AS
 SELECT p.personfirstname AS firstname,
    p.personlastname AS lastname,
    p.personemail AS email,
    jp.positionname AS "position",
    ep.employeepositionstartdate AS startdate
   FROM (((public.person p
     JOIN public.employee e ON ((p.personkey = e.personkey)))
     JOIN public.employeeposition ep ON ((e.employeekey = ep.employeekey)))
     JOIN public.jobposition jp ON ((jp.positionkey = ep.positionkey)));


ALTER TABLE employeeschema.employeeview OWNER TO postgres;

--
-- Name: grantapplication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grantapplication (
    grantapplicationkey integer NOT NULL,
    grantapplicationdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    personkey integer,
    granttypekey integer,
    grantapplicationamount numeric NOT NULL,
    grantapplicationexplain text NOT NULL,
    grantapplicationconfirm uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.grantapplication OWNER TO postgres;

--
-- Name: granttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.granttype (
    granttypekey integer NOT NULL,
    granttypename character varying(255),
    granttypeonetimemax numeric NOT NULL,
    granttypelifetimemax numeric NOT NULL
);


ALTER TABLE public.granttype OWNER TO postgres;

--
-- Name: grantreview; Type: MATERIALIZED VIEW; Schema: employeeschema; Owner: postgres
--

CREATE MATERIALIZED VIEW employeeschema.grantreview AS
 SELECT grantapplication.grantapplicationkey AS "Key",
    grantapplication.grantapplicationdate AS "Date",
    granttype.granttypename AS "Grant Name",
    person.personlastname AS "Last Name",
    grantapplication.grantapplicationamount AS "Amount of Grant"
   FROM ((public.person
     JOIN public.grantapplication USING (personkey))
     JOIN public.granttype USING (granttypekey))
  WITH NO DATA;


ALTER TABLE employeeschema.grantreview OWNER TO postgres;

--
-- Name: personaddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personaddress (
    personaddresskey integer NOT NULL,
    personkey integer,
    personaddressstreet character varying(255) NOT NULL,
    personaddresscity character varying(255) DEFAULT 'Seattle'::character varying,
    personaddressstate character(2) DEFAULT 'WA'::bpchar,
    personaddresszipcode character(11) NOT NULL,
    personaddressapt character varying(255)
);


ALTER TABLE public.personaddress OWNER TO postgres;

--
-- Name: seattleaddresses; Type: VIEW; Schema: employeeschema; Owner: postgres
--

CREATE VIEW employeeschema.seattleaddresses AS
 SELECT personaddress.personkey,
    personaddress.personaddressapt AS apartment,
    personaddress.personaddressstreet AS street,
    personaddress.personaddresscity AS city,
    personaddress.personaddressstate AS state,
    personaddress.personaddresszipcode AS postalcode
   FROM public.personaddress
  WHERE ((personaddress.personaddresscity)::text = 'Seattle'::text)
  WITH CASCADED CHECK OPTION;


ALTER TABLE employeeschema.seattleaddresses OWNER TO postgres;

--
-- Name: businessrule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.businessrule (
    businessrulekey integer NOT NULL,
    businessruletext text NOT NULL
);


ALTER TABLE public.businessrule OWNER TO postgres;

--
-- Name: businessrule_businessrulekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.businessrule_businessrulekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.businessrule_businessrulekey_seq OWNER TO postgres;

--
-- Name: businessrule_businessrulekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.businessrule_businessrulekey_seq OWNED BY public.businessrule.businessrulekey;


--
-- Name: donation_donationkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donation_donationkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.donation_donationkey_seq OWNER TO postgres;

--
-- Name: donation_donationkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donation_donationkey_seq OWNED BY public.donation.donationkey;


--
-- Name: employee_employeekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_employeekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_employeekey_seq OWNER TO postgres;

--
-- Name: employee_employeekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_employeekey_seq OWNED BY public.employee.employeekey;


--
-- Name: employeeposition_employeepositionkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employeeposition_employeepositionkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employeeposition_employeepositionkey_seq OWNER TO postgres;

--
-- Name: employeeposition_employeepositionkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employeeposition_employeepositionkey_seq OWNED BY public.employeeposition.employeepositionkey;


--
-- Name: grantapplication_grantapplicationkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grantapplication_grantapplicationkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grantapplication_grantapplicationkey_seq OWNER TO postgres;

--
-- Name: grantapplication_grantapplicationkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grantapplication_grantapplicationkey_seq OWNED BY public.grantapplication.grantapplicationkey;


--
-- Name: grantreview; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grantreview (
    grantreviewkey integer NOT NULL,
    grantapplicationkey integer,
    employeekey integer,
    grantreviewdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    grantreviewcomment text
);


ALTER TABLE public.grantreview OWNER TO postgres;

--
-- Name: grantreview_grantreviewkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grantreview_grantreviewkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grantreview_grantreviewkey_seq OWNER TO postgres;

--
-- Name: grantreview_grantreviewkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grantreview_grantreviewkey_seq OWNED BY public.grantreview.grantreviewkey;


--
-- Name: grantstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grantstatus (
    grantstatuskey integer NOT NULL,
    grantapplicationkey integer,
    statuskey integer DEFAULT 1,
    grantstatusfinalallocation numeric
);


ALTER TABLE public.grantstatus OWNER TO postgres;

--
-- Name: grantstatus_grantstatuskey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grantstatus_grantstatuskey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grantstatus_grantstatuskey_seq OWNER TO postgres;

--
-- Name: grantstatus_grantstatuskey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grantstatus_grantstatuskey_seq OWNED BY public.grantstatus.grantstatuskey;


--
-- Name: granttype_granttypekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.granttype_granttypekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.granttype_granttypekey_seq OWNER TO postgres;

--
-- Name: granttype_granttypekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.granttype_granttypekey_seq OWNED BY public.granttype.granttypekey;


--
-- Name: jobposition_positionkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobposition_positionkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobposition_positionkey_seq OWNER TO postgres;

--
-- Name: jobposition_positionkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobposition_positionkey_seq OWNED BY public.jobposition.positionkey;


--
-- Name: loginhistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loginhistory (
    loginhistorykey integer NOT NULL,
    loginkey integer,
    logintimestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.loginhistory OWNER TO postgres;

--
-- Name: loginhistory_loginhistorykey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.loginhistory_loginhistorykey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loginhistory_loginhistorykey_seq OWNER TO postgres;

--
-- Name: loginhistory_loginhistorykey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.loginhistory_loginhistorykey_seq OWNED BY public.loginhistory.loginhistorykey;


--
-- Name: logintable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logintable (
    loginkey integer NOT NULL,
    personkey integer,
    personusername character varying(50) NOT NULL,
    personpassword text NOT NULL
);


ALTER TABLE public.logintable OWNER TO postgres;

--
-- Name: logintable_loginkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logintable_loginkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logintable_loginkey_seq OWNER TO postgres;

--
-- Name: logintable_loginkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logintable_loginkey_seq OWNED BY public.logintable.loginkey;


--
-- Name: numberserved; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.numberserved AS
 SELECT date_part('year'::text, grantapplication.grantapplicationdate) AS "Year",
    count(grantapplication.grantapplicationkey) AS "Number",
    sum(grantapplication.grantapplicationamount) AS "Total"
   FROM public.grantapplication
  GROUP BY (date_part('year'::text, grantapplication.grantapplicationdate))
  ORDER BY (date_part('year'::text, grantapplication.grantapplicationdate));


ALTER TABLE public.numberserved OWNER TO postgres;

--
-- Name: people; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.people AS
 SELECT person.personkey AS "ID",
    person.personfirstname AS "FirstName",
    person.personlastname AS "LastName",
    person.personemail AS "Email",
    person.personprimaryphone AS "Phone",
    person.persondateadded AS "DateAdded"
   FROM public.person
  ORDER BY person.persondateadded;


ALTER TABLE public.people OWNER TO postgres;

--
-- Name: person_personkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_personkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_personkey_seq OWNER TO postgres;

--
-- Name: person_personkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_personkey_seq OWNED BY public.person.personkey;


--
-- Name: personaddress_personaddresskey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personaddress_personaddresskey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personaddress_personaddresskey_seq OWNER TO postgres;

--
-- Name: personaddress_personaddresskey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personaddress_personaddresskey_seq OWNED BY public.personaddress.personaddresskey;


--
-- Name: pk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pk_seq OWNER TO postgres;

--
-- Name: status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status (
    statuskey integer NOT NULL,
    statusname character varying(255) NOT NULL
);


ALTER TABLE public.status OWNER TO postgres;

--
-- Name: status_statuskey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_statuskey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_statuskey_seq OWNER TO postgres;

--
-- Name: status_statuskey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_statuskey_seq OWNED BY public.status.statuskey;


--
-- Name: businessrule businessrulekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.businessrule ALTER COLUMN businessrulekey SET DEFAULT nextval('public.businessrule_businessrulekey_seq'::regclass);


--
-- Name: donation donationkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donation ALTER COLUMN donationkey SET DEFAULT nextval('public.donation_donationkey_seq'::regclass);


--
-- Name: employee employeekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee ALTER COLUMN employeekey SET DEFAULT nextval('public.employee_employeekey_seq'::regclass);


--
-- Name: employeeposition employeepositionkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employeeposition ALTER COLUMN employeepositionkey SET DEFAULT nextval('public.employeeposition_employeepositionkey_seq'::regclass);


--
-- Name: grantapplication grantapplicationkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantapplication ALTER COLUMN grantapplicationkey SET DEFAULT nextval('public.grantapplication_grantapplicationkey_seq'::regclass);


--
-- Name: grantreview grantreviewkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantreview ALTER COLUMN grantreviewkey SET DEFAULT nextval('public.grantreview_grantreviewkey_seq'::regclass);


--
-- Name: grantstatus grantstatuskey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantstatus ALTER COLUMN grantstatuskey SET DEFAULT nextval('public.grantstatus_grantstatuskey_seq'::regclass);


--
-- Name: granttype granttypekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.granttype ALTER COLUMN granttypekey SET DEFAULT nextval('public.granttype_granttypekey_seq'::regclass);


--
-- Name: jobposition positionkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobposition ALTER COLUMN positionkey SET DEFAULT nextval('public.jobposition_positionkey_seq'::regclass);


--
-- Name: loginhistory loginhistorykey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loginhistory ALTER COLUMN loginhistorykey SET DEFAULT nextval('public.loginhistory_loginhistorykey_seq'::regclass);


--
-- Name: logintable loginkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logintable ALTER COLUMN loginkey SET DEFAULT nextval('public.logintable_loginkey_seq'::regclass);


--
-- Name: person personkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person ALTER COLUMN personkey SET DEFAULT nextval('public.person_personkey_seq'::regclass);


--
-- Name: personaddress personaddresskey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personaddress ALTER COLUMN personaddresskey SET DEFAULT nextval('public.personaddress_personaddresskey_seq'::regclass);


--
-- Name: status statuskey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status ALTER COLUMN statuskey SET DEFAULT nextval('public.status_statuskey_seq'::regclass);


--
-- Data for Name: businessrule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.businessrule (businessrulekey, businessruletext) FROM stdin;
\.


--
-- Data for Name: donation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donation (donationkey, personkey, donationamount, donationdate, donationvalidation) FROM stdin;
1	6	500.00	2017-05-12 00:00:00	74222c8c-b7f3-4d67-b8d4-8f43a07f9225
2	7	2500.00	2017-05-21 00:00:00	01ff6159-b134-43d5-be9d-d6ea5c9106aa
3	8	350.00	2017-06-01 00:00:00	6618b608-079a-4bd2-84fa-61981b3a1cee
4	9	1200.00	2017-06-10 00:00:00	7bb28f93-6937-4f0a-bec0-9f4df128f3ce
5	10	500.00	2017-06-15 00:00:00	f51c6b38-a935-42a0-b06e-e4e1b5ce37f1
6	11	5000.00	2017-06-17 00:00:00	16393bc5-2c5a-40bb-a079-f72dcc5f0cc0
7	12	150.00	2017-06-17 00:00:00	c38ce26b-0397-4e9b-b8b4-cee2a87240b6
8	13	750.00	2017-06-02 00:00:00	d888b0cd-76de-4d56-aad7-4bf6bac6d390
9	14	500.00	2017-07-03 00:00:00	02a78f2f-0dd9-4b20-8d11-6b28bea299b9
10	15	1500.00	2017-07-06 00:00:00	912f87be-0bae-461e-8e3a-d352f3d40ef5
11	19	3000.00	2017-07-15 00:00:00	263cb5f6-51c5-401b-bd2f-0bdb617b4abe
12	20	250.00	2017-07-15 00:00:00	1f210920-96eb-413a-a95c-989574f576b3
13	21	1500.00	2017-08-10 00:00:00	8b11cc9f-07a8-4f85-8736-31e2442dd567
14	22	1000.00	2017-08-22 00:00:00	b1d39d36-8f19-4dbf-ab65-95432f9697f0
15	23	3000.00	2017-08-23 00:00:00	d3546e5a-a234-450f-9301-27d3df8fecbe
16	28	345.50	2017-09-05 00:00:00	8ec89fca-e872-4952-ae9b-53871c304b67
17	30	1360.00	2017-09-10 00:00:00	4e4c5f84-d263-4655-be64-94db974f20d9
18	31	1000.50	2017-09-15 00:00:00	fb92ade3-f133-4476-8780-039221a26bc1
19	33	500.50	2017-09-18 00:00:00	d6b6798d-a4d4-4e55-aae4-170f2899d85f
20	35	125.50	2017-09-21 00:00:00	d9ecc45d-567e-4a6d-a60e-757b3f03215c
21	38	100	2017-10-10 00:00:00	90c75b08-73fe-4ce3-82a5-c26ef12f2318
22	39	125.50	2017-10-15 00:00:00	1fcf0a59-c8ca-4646-873b-b728653c94c4
23	42	350.00	2017-10-18 00:00:00	c7a21fb4-5bf9-4c0d-9340-28b177ff5be8
24	43	500.00	2017-10-22 00:00:00	ff9de7ab-67f0-4305-ad4a-039296198a81
25	44	50.00	2017-10-28 00:00:00	53dede8b-ba60-4bf7-8f0f-c1f182a3f905
26	48	900.00	2017-11-15 00:00:00	f55ff3cb-cf60-4484-86a0-917c9df87d69
27	50	25	2017-11-20 00:00:00	d58ad6f4-f1e2-4cc8-bfed-920d061abb58
28	52	250	2017-11-25 00:00:00	3f4a1b2f-2820-4e13-ba9f-7094258ba7a2
29	55	650	2017-12-02 00:00:00	0f3c90a1-2f9e-432c-a83f-026322546b04
30	57	100	2017-12-05 00:00:00	d71da278-4bdd-42ed-866e-62adb6796509
31	60	365	2017-12-16 00:00:00	fd1c7807-28ac-4803-bc59-999317ee1cae
32	61	25	2017-12-20 00:00:00	b3c35b14-b0bc-4647-9b7d-723915e2717a
33	13	400	2017-12-23 00:00:00	4ea7a776-097c-4833-b85b-bc716e7f58d6
34	20	25	2017-12-23 00:00:00	967f7773-e0f7-40a3-91a5-c33bb2b49c73
35	28	500	2017-12-29 00:00:00	3becd3e7-c105-49bc-ab2b-abd6ee7a0936
36	66	300	2018-01-06 00:00:00	7b025821-99ab-438b-9a14-df5e4d3189b8
37	68	150.00	2018-01-15 00:00:00	d9c87cc3-95c9-4d03-88d4-41fa0947ee33
38	69	1250.95	2018-01-18 00:00:00	6c0436d0-747e-4cfc-8b63-018f0c42c09d
39	70	500	2018-01-27 00:00:00	51b8f165-ddc2-4138-b80a-57bf00166f4f
40	73	450.00	2018-02-05 00:00:00	835b3553-af82-4675-9204-696691f43ab1
41	74	325.50	2018-02-12 00:00:00	7225be5f-53a8-4e2c-8b3b-a145b8a9a9fa
42	77	5000.00	2018-03-18 00:00:00	4a669977-3d23-4d6a-a08c-4e0c80ff09c9
43	79	5000.00	2018-03-20 00:00:00	f49f3e4e-02e8-4922-aa86-f8c2c4600423
44	80	225.00	2018-03-26 00:00:00	477f4a32-4ee8-4d21-ad27-1f5a900501d7
45	84	500.00	2018-04-18 00:00:00	56a72eeb-60ad-45cd-8275-12b76af926c0
46	87	500.00	2018-05-12 00:00:00	b33aba05-cbdb-4bf5-95ae-c8c329d87084
47	88	325.00	2018-05-15 00:00:00	f7660d83-794a-40d9-9cdd-f74122c53267
48	89	1200.00	2018-05-18 00:00:00	7f367adf-eeb4-4c0a-b116-4cf99388cdc0
49	94	145.00	2018-07-07 00:00:00	20b08b43-4a8d-4689-ba88-f72f55bb2098
50	97	2500.00	2018-07-18 00:00:00	81437882-2985-423e-98e6-f127ccfcfa96
51	100	1200.00	2018-07-28 00:00:00	7d729637-5229-4c2a-a333-a60c56e87f1b
52	101	500.00	2018-08-12 00:00:00	4f892380-c3ea-4fe8-9a14-2fdacd8c92d0
53	102	250.00	2018-08-12 00:00:00	4698ab71-b562-4346-a3f4-82c39198588a
54	103	900.00	2018-08-12 00:00:00	cd639c83-d973-4972-bf6e-7e59f95a1c5b
55	105	325.50	2018-09-07 00:00:00	8869868b-ea7d-4971-8d8f-19af621a5008
56	106	750.50	2018-09-13 00:00:00	b7500e8c-2b44-4e0a-ab61-2773ce2646fe
57	107	200.00	2018-09-21 00:00:00	0dd00e41-2c92-4cca-9446-64b5b5cab299
58	112	450.00	2018-10-13 00:00:00	1b14a299-f77b-429b-aa78-5266a728e4c3
59	113	500.00	2018-10-13 00:00:00	e646ea03-161d-4103-932e-55904d32a378
60	114	950.00	2018-10-13 00:00:00	748732ca-129c-4253-989a-fc1ce3488363
61	116	1300.00	2018-11-03 00:00:00	178f8f74-ec8f-4fc1-ba35-f75c9c5ff6e5
62	120	250.00	2018-11-19 00:00:00	ee4512d3-d447-4930-a909-cd6c893d12a9
63	121	2500.00	2018-11-21 00:00:00	3c76b2e5-e3a5-4d12-9925-10060a2289a6
64	122	10000.00	2018-11-03 00:00:00	130227fd-7b2b-4738-af0a-33dc41c7e602
65	127	200.00	2018-12-13 00:00:00	21246a8d-898f-4167-9fa3-2d100df5286b
66	128	500.00	2018-12-15 00:00:00	05447efd-f66c-4709-ad7f-c8d8ba3de842
67	131	700.00	2018-12-20 00:00:00	2ee17529-be8b-47b3-b90d-892de6f2c427
68	79	10100.00	2019-02-14 19:45:35.048392	c550f76e-21e7-4e76-b840-db3e89761ee1
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (employeekey, personkey) FROM stdin;
1	1
2	3
3	4
4	5
5	17
6	29
7	58
\.


--
-- Data for Name: employeeposition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employeeposition (employeepositionkey, employeekey, positionkey, employeepositionstartdate) FROM stdin;
9	1	1	2017-02-02
10	1	2	2017-02-02
11	1	6	2017-02-02
12	2	4	2017-02-03
13	3	3	2017-02-02
14	4	5	2017-02-03
15	4	7	2017-02-03
16	5	7	2017-03-01
17	6	4	2017-09-10
5	7	\N	2017-12-05
\.


--
-- Data for Name: grantapplication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grantapplication (grantapplicationkey, grantapplicationdate, personkey, granttypekey, grantapplicationamount, grantapplicationexplain, grantapplicationconfirm) FROM stdin;
1	2017-07-06 00:00:00	16	3	450	I managed tuition but I cannot afford the math and biology text books	43ae7bd1-7dc1-4f6a-9406-2b0ee41dd6f4
2	2017-07-13 00:00:00	18	2	500	I am short on rent this month	7cf2b79d-83fb-4d8e-8869-fd8e3bbccc3f
3	2017-08-25 00:00:00	24	7	200	I need help with childcare until my check comes in from my new job	c7111d67-2784-4d84-ae84-8932c3542db9
4	2017-08-25 00:00:00	15	1	225	I need help with food for my family	0c0616a2-1119-49c8-b6fa-daea1e701789
5	2017-08-26 00:00:00	26	4	200	I need help paying my dental bill	d7d7ce2a-caa9-45fd-880a-67de04a168ef
7	2017-09-17 00:00:00	32	2	600	I need help covering my rent this month	030dc2f8-36c0-40d3-9c86-586dcfd6f827
8	2017-10-03 00:00:00	36	1	150	I need help with groceries	17a94dcb-a532-4c8b-ad8a-485527ba1afd
9	2017-10-10 00:00:00	37	7	425	I can't conver child care this month	ae61fd44-3de8-479b-9d5b-55329c23bd89
6	2017-08-23 00:00:00	28	9	200	I need house repairs that can't wait	9d689406-698a-4c13-a229-d311884d7ff2
10	2017-10-17 00:00:00	40	4	426.79	I had emergancy dental work and cannot pay this remainder	8fae8cc6-f830-4b98-beba-b746cd80e9f5
11	2017-10-18 00:00:00	41	1	120.00	I need extra grocery money to feed the kids	7a8e1a68-9594-4f5f-8501-9055dff79965
12	2017-11-01 00:00:00	45	2	200	I am 200 short this month on my rent	c144e697-dae6-4bb5-b3be-8f9df00b9106
13	2017-11-03 00:00:00	46	7	500	I have unexpected child care costs	9019e32a-e7a3-4184-9dbb-167b9a19d04a
14	2017-11-10 00:00:00	47	2	350	A roomate left and I have to cover his rent this month	47c69261-fe1e-4e5c-9955-29ae37c1c368
15	2017-11-17 00:00:00	49	9	125.00	I have higher than usual utility bills this month	c2d639d5-b056-4926-8fa5-8e0e594bd2d0
16	2017-11-26 00:00:00	53	3	450.00	My financial aid was dropped and I need this much to retain classes	2f58d290-fbcb-4fed-b1b6-f15c244fd0c8
17	2017-11-27 00:00:00	54	1	150.00	food stamp allotment was lowered	213c77cc-54ca-4d75-a0ca-88d3b13340b7
18	2017-12-03 00:00:00	56	2	800.00	I can't cover rent this month	4730b1ca-8437-4fab-8cd2-b1d6f8007404
19	2017-12-15 00:00:00	59	7	375.50	Just started a new job and need help with first childcare payment	87aa9d67-604f-41b8-900a-dd8a233e9f2f
20	2017-12-20 00:00:00	62	1	450.00	Just need a little help with groceries	fc4c3921-2697-4bec-8ac2-7ca96fc28f4a
21	2017-12-21 00:00:00	63	4	650.00	I had to have an emergancy root canal	5836d15c-6cc3-4f52-a09b-0f188add1bcc
22	2018-02-03 00:00:00	72	2	1300.00	Unable to pay rent this month	08ae6b8d-5a7b-4a8c-b33e-f5c947be993a
23	2018-02-21 00:00:00	75	7	250	Need help with childcare this month	90578696-ae0a-4cf7-8701-4ca24cf91707
24	2018-03-12 00:00:00	76	3	200	I need help getting my school books	69bcdedf-8027-49f4-b3e6-2cff4fffec06
25	2018-03-20 00:00:00	78	5	800.74	I had an accident and had unexpected medical costs	d240b254-8e29-4267-8d1d-5b50730df217
26	2018-04-01 00:00:00	81	4	600	I must have a wisdom tooth extracted	9c952804-af0a-40ed-b94c-37c78513c520
27	2018-04-05 00:00:00	82	4	300	I need help with childcare	6ec30c2c-52f2-4780-92b4-3519485cdcf6
28	2018-04-11 00:00:00	83	1	200	After bills I have nothing left to buy food with	b4f3b81c-9f38-439b-a018-a48a517d5290
29	2018-04-01 00:00:00	85	7	200	I have a new job and need help with childcare until I am paid	4e40f3b5-2e84-47bd-9584-9f9e7a840bb3
30	2018-05-05 00:00:00	86	1	200	Rent took all my money and I have none left over for food	03277d80-a434-46b7-b827-3a1b22f463c7
31	2018-05-23 00:00:00	90	7	200	I am a little short for childcare this month	484796e4-0925-45af-881f-5f1d632504ba
32	2018-06-08 00:00:00	91	4	200	I needed a root canal. This 200 only makes one payment	f6d2b5a3-d409-498d-829f-3e2c772d9807
33	2018-06-19 00:00:00	92	7	250	I can't make my childcare payment this month	cf05b39e-aed5-4fa8-9800-42a1fde04ca0
34	2018-06-08 00:00:00	93	2	800	A roomate left and I have to cover his payment until I get a new roomate	2704f8ad-0953-434c-bea7-20adaf905473
35	2018-07-12 00:00:00	95	5	500.00	I injured my back while moving to this apartment	8cdad9e0-4bb7-4153-baf8-53ea5427ddfb
36	2018-07-13 00:00:00	96	1	200	I need help feeding my kids	1f334ca3-7c7d-4fc5-87d5-3cfe02029462
37	2018-07-21 00:00:00	98	5	300.00	I injured my back while moving to this apartment	4abc24bb-340e-4690-b88e-fdb9f9aefe50
38	2018-07-12 00:00:00	99	4	200.00	I need help paying for an emergency dental appointment	4c7096d4-252b-473f-8c20-e844e40a9e4f
39	2018-09-03 00:00:00	104	3	500.00	Financial aid is not covering all my tuition	8dc5dc81-4e99-41cc-b9b5-08047f8ae642
40	2018-09-07 00:00:00	108	3	300.00	I need help purchasing textbooks	37af5a0d-5c35-4d73-b22a-e58021e10ead
41	2018-09-23 00:00:00	109	2	500.00	I need help paying the deposit on my new apartment	1ffacefd-45b1-4140-9672-8bbc207af22b
42	2018-09-27 00:00:00	110	7	500.00	Childcare has an initial deposit that I can't pay	6c2ed5fe-4e8a-4c5d-a7e7-69f86a124891
43	2018-09-30 00:00:00	111	9	150.00	I need this to pay dues for an apprentiship	6e8356d7-222d-4526-8321-7c56ea404380
44	2018-10-20 00:00:00	115	7	200.00	Need help with childcare expenses	2561c601-031a-4d78-a508-29ae24893fb8
45	2018-11-07 00:00:00	117	2	200.00	I spent all my money on rent and school	87c3f963-840d-42ee-8ce0-82adbd213c95
46	2018-11-12 00:00:00	118	1	800.00	I lost a roommate and can't cover his rent	5b1a6865-82e8-453f-806e-f37753d96ea0
47	2018-11-16 00:00:00	119	3	200.00	I really need to get the biology textbook	b421d5de-641a-46f1-b86c-1c54a4535b84
48	2018-11-25 00:00:00	123	4	200.00	I need to make a payment to my dentist	15f41439-5121-4527-a0d2-ee3230ad725c
49	2018-11-28 00:00:00	124	1	200.00	I overspent my budget this month and can't afford groceries	63a04145-a3df-4f88-81c3-c5c324eceec3
50	2018-12-02 00:00:00	125	7	150.00	I had to change child care providers and there is an intial deposit	11e1d585-1d98-4629-a207-70e3fa93fa87
51	2018-12-07 00:00:00	126	7	300.00	I need money for an initial child care payment	6d4d4cef-d680-4538-85d1-4601c119b752
52	2018-12-18 00:00:00	129	3	450.00	I need help with tuition for the comming quarter. It is my last quarter	bff6e559-76ed-4289-81f6-b708f79ceb4f
53	2018-12-20 00:00:00	130	3	600.00	I need to purchase a laptop for my computer classes	a1137b89-b408-46d5-8a04-ec385c5c796b
54	2018-12-22 00:00:00	132	5	400.00	Help paying off an emergancy room visit	06032ddb-1598-40ed-b409-b9c67770d2b3
55	2019-02-21 11:23:53.415573	50	1	400.00	lunch time	fcab5d18-c443-44ae-9471-b10340cd2af8
\.


--
-- Data for Name: grantreview; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grantreview (grantreviewkey, grantapplicationkey, employeekey, grantreviewdate, grantreviewcomment) FROM stdin;
1	1	2	2017-07-07 00:00:00	request seems reasonable, recommend grant
2	2	2	2017-07-15 00:00:00	recommend grant
3	3	2	2017-08-27 00:00:00	recommend grant
4	4	2	2017-08-27 00:00:00	We have located other resources to help, reduce grant to 150
5	5	2	2017-08-27 00:00:00	Looking into making a payment arrangement with dentist
6	5	2	2017-07-07 00:00:00	Payment arranged, deny grant
7	6	6	2017-08-25 00:00:00	we found other means for the applicant to get help with house repairs
8	7	2	2017-09-20 00:00:00	recommend grant but explore other solutions for future shortfalls
9	8	6	2017-10-05 00:00:00	recommend grant
10	9	6	2017-10-11 00:00:00	Recommend one time grant
11	10	2	2017-10-18 00:00:00	very specific amount. Suggest granting
12	11	2	2017-10-18 00:00:00	Grant one time, but we should look at alternative funding
13	12	6	2017-10-18 00:00:00	Suggest granting
14	13	6	2017-11-03 00:00:00	This is a reasonable one time request
15	14	6	2017-11-12 00:00:00	suggest grant
16	15	2	2017-11-18 00:00:00	grant
17	16	6	2017-11-27 00:00:00	can't pay tuition for this person every quarter
18	16	6	2017-11-28 00:00:00	On follow up, this is last quarter, recomment grant
19	17	2	2017-11-28 00:00:00	This could be an ongoing problem grant once then follow up to find other solutions
20	18	2	2017-12-03 00:00:00	We can't fund every month's rent
21	18	2	2017-12-04 00:00:00	We arranged an additional roomate. Request reduced to 300--one time only
22	19	6	2017-12-15 00:00:00	Grant
23	20	2	2017-12-21 00:00:00	Need to find additional funding directed to foodbank reduce to 150
24	21	2	2017-12-23 00:00:00	Arranged payment schedule with Dentist, reduce to 200
25	22	1	2018-02-03 00:00:00	This looks like a recurring issue. We should find alternate solution
26	22	6	2018-02-04 00:00:00	Agreed. have directed the client to Rent Assistance org
27	23	1	2018-02-23 00:00:00	Grant request
28	24	1	2018-03-14 00:00:00	Recommend granting
29	25	1	2018-03-24 00:00:00	Recommend granting but would like another review
30	25	6	2018-03-25 00:00:00	I concur. It is a onetime expense
31	26	1	2018-04-02 00:00:00	We met with dentist and have reduced the amount to 300
32	27	1	2018-04-06 00:00:00	This is a recurring problem. I directed her to other agencies that could provide more long term help.
33	28	6	2018-04-11 00:00:00	recommend grant but also getting client enrolled for financial planning
34	29	1	2018-04-12 00:00:00	Recommend. Somehow this one got away from me. Took too long to respond.
35	30	6	2018-05-05 00:00:00	Doesn't seem to be an on-going problem. Recommend grant
36	31	6	2018-05-25 00:00:00	Recommend Grant
37	32	1	2018-06-10 00:00:00	Recommend pay
38	33	6	2018-06-20 00:00:00	recommend pay but also help find other resources
39	34	6	2018-06-10 00:00:00	recommend, also help find a roomate
40	35	6	2018-07-14 00:00:00	Not sure of this one. I don't think it is a legitimate claim
41	35	1	2018-07-15 00:00:00	I agree. There is no medical record
42	35	6	2018-07-15 00:00:00	Decision to deny
43	36	1	2018-07-15 00:00:00	Legitimate, but we need to find longer term assitance.
44	36	6	2018-07-15 00:00:00	Grant one time. Referred to other services
45	37	6	2018-07-22 00:00:00	Similar to recent claim, but this one does have medical documentation. Grant
46	38	6	2018-07-14 00:00:00	Grant
47	39	1	2018-09-04 00:00:00	recommend granting but also finding other assistance
48	40	1	2018-09-09 00:00:00	recommend grant
49	41	6	2018-09-29 00:00:00	recommend grant
50	42	6	2018-09-29 00:00:00	recommend grant
51	43	1	2018-10-01 00:00:00	recommend granting but also finding other assistance
52	44	1	2018-10-20 00:00:00	Suggest granting but find other longer term help
58	45	1	2018-11-08 00:00:00	recommend granting with further counceling
59	46	6	2018-11-14 00:00:00	Found a roomate. Cancel request
60	47	6	2018-11-16 00:00:00	Grant
61	48	1	2018-11-27 00:00:00	Grant. Also note: we really need to increase size of grants for dental
62	49	6	2018-11-29 00:00:00	Not specific about how overspent. Deny and provide counceling.
63	50	1	2018-12-02 00:00:00	grant
64	51	1	2018-12-07 00:00:00	grant
65	52	1	2018-12-18 00:00:00	grant
66	53	6	2018-12-02 00:00:00	I suggest grant. Also we should maybe make computers and phones a new category for grants.
67	54	6	2018-12-22 00:00:00	grant
\.


--
-- Data for Name: grantstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grantstatus (grantstatuskey, grantapplicationkey, statuskey, grantstatusfinalallocation) FROM stdin;
1	1	2	450
2	2	2	500
3	3	2	300
4	4	3	150
5	5	4	0
6	6	4	0
7	7	1	600
8	8	1	150
9	9	1	425
10	10	2	469.79
11	11	2	120
12	12	2	200
13	13	2	500
14	14	2	350
15	15	2	125
16	16	2	450.00
17	17	2	150.00
18	18	3	300.00
19	19	2	375.50
20	20	3	150.00
21	21	2	200.00
22	22	4	0.00
23	23	2	250.00
24	24	2	200.00
25	25	2	800.74
26	26	3	300
27	27	4	0.00
28	28	2	200
29	29	2	200
30	30	2	200.00
31	31	2	200.00
32	32	2	200.00
33	33	2	250.00
34	34	2	800
35	35	4	0.00
36	36	2	200.00
37	37	2	300.00
38	38	2	200.00
39	39	2	500.00
40	40	2	300.00
41	41	2	500.00
42	42	2	500.00
43	43	2	150.00
44	44	2	200.00
45	45	2	200.00
46	46	4	0.00
47	47	2	200.00
48	48	2	200.00
49	45	4	0.00
50	50	2	150.00
51	51	2	300.00
52	52	2	450.00
53	53	2	600.00
54	54	2	400.00
\.


--
-- Data for Name: granttype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.granttype (granttypekey, granttypename, granttypeonetimemax, granttypelifetimemax) FROM stdin;
1	Food	220.5000	661.5000
2	Rent	882.0000	1764.0000
3	School	661.5000	2646.0000
4	Dental	220.5000	661.5000
5	Medical	771.7500	3307.5000
6	Travel	661.5000	3087.0000
7	Childcare	330.7500	5512.5000
8	Funerary	992.2500	992.2500
9	Misc	220.5000	882.0000
\.


--
-- Data for Name: jobposition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobposition (positionkey, positionname, positiondescript) FROM stdin;
1	President	\N
2	Overall Manager	\N
3	Grant Manager	\N
4	Grant Reviewer	\N
5	Donation Mananger	\N
6	Public relations	\N
7	Accounting	\N
8	Volunteer	\N
9	vice president	\N
10	cook and bottle washer	\N
11	garbage dumper	\N
\.


--
-- Data for Name: loginhistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.loginhistory (loginhistorykey, loginkey, logintimestamp) FROM stdin;
1	30	2018-04-13 10:29:58.370608
\.


--
-- Data for Name: logintable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logintable (loginkey, personkey, personusername, personpassword) FROM stdin;
113	112	tmandela	$2a$08$CpZasMah9wlv8cRfRtSsI..DQvjluKq3uXK/va.qvVfIb6NEGZyXa
114	113	lsnow	$2a$08$8qNOJHfRXCaRpBkqZ3f0cuExU9BePwCauXkB4uxcZ3ZXk2aonU.jC
115	114	amiller	$2a$08$thkuP/o3ULNIAAzYwqEkmez9gcodXMDv1FggZUA1u3TcemjGx64FC
116	115	jrogers	$2a$08$n7TBCiiYyPvJ8nv04dGuDOlQOFH5XYErUYApc6/irDW99pxmf2Kgq
117	116	msung	$2a$08$k0IPFAHYVg/huXkAkzhI0.Gm2h8QnOz2IKFMveixRxZ7X6Iugcd4G
118	117	ljones	$2a$08$97GMkGYs4uXqydwFbpf.VOxQam.w0CFDBCjTFPIy38qwiuebKpUXS
119	118	nxui	$2a$08$qDkkpGAgltr.uZMRfQHepedHo3Uc7s8oBdR3ID7yXlgDHAC9Polv2
120	119	lyun	$2a$08$4FZNeBR0F4D3FJmN4Cdw6uW4COHmx9CKMPCCYTSx6QMEFptkDiB.q
121	120	pkendrick	$2a$08$yHH47j7TEQlozEN6wen.muHdCNXMjQYxsSL4eFKclLALLPq6R90ae
122	121	tbaker	$2a$08$wcsQoQydsmCwdqdg0VG4NO33FjPDx4gwq9r2XSkx0lVzwGQvRgQke
123	122	sliddell	$2a$08$sjgKF7IZFEP63o5NtMV3OuRPuU25RSHyIYhgyCcarxoYouFuLCXE6
124	123	lnguyen	$2a$08$eJNiqYlBTOlfmwHZisERV.XfAMB4rbCYGMJX9KLoRJzslHQPr1.Ni
125	124	sbrowning	$2a$08$.ZAQFneFqhkOKnrSTAOb.uhIoFhwDZruOwDvFw9wDW7N04tqcBSYu
126	125	cstevens	$2a$08$I1c7MPF3gs4LHKAuWGh0KerfIr73QgSr/yqZCvvqQW0P6y8bj8Grq
127	126	bsteeler	$2a$08$SbafHG2nIDtU2tynOUTYq.IYSohqWtliwUsnpLYVuKvky0Z1A8cBS
128	127	pdavidson	$2a$08$P9xcBjS6yuWLyaqpwVp.sOjSKa30aiZyM7I0022cVsUDkdaMKhXzm
129	128	jdexter	$2a$08$emuXaCD4SUM4NIIXIKDxduhne8M6ETsYjqZw6xQXFrSwzqVZw9hLG
130	129	jnorman	$2a$08$zuknjbek3IuryzDW/ypmJO7g5V5UUu9UJ8uDBpr4ot.lZhKDaJ3Dq
131	130	mnelson	$2a$08$UjlIlUoSeDBlyhSsVcxwdOI402IGEZwOgoFUFpY.2f7WH3k9UbSdq
132	131	tmason	$2a$08$Inp0.8FsTlDWBxYCd0gZiusC9au7t94fCNS0FB9JafqBg/S4OQij2
133	132	fjohnson	$2a$08$Vo.oCXfumxFTtvl.5Ol84OxegpY46YCQqmo.2pxuU3aclJ9VWLM/W
2	2	clinda	$2a$08$3VFMFhs0pc3KjTqEmzZLbu5.liR2wYfW5AetcLS117.cqRVRLn3X2
3	1	klynn	$2a$08$eDP36KhlLNZnub/VPLyPK.Wq8TzO9afit.hgWdIj98qZiAZmefUEa
4	3	janderson	$2a$08$KF0K//C460U.oX1tcw3FH..MBxAf5q/o6509nRGDnXJA0PFWbBE0q
5	4	tzimmerman	$2a$08$yFuRfljXEz5gK9T.aoFcyuQVrnVAZseyqxQu5l1JRpFwhGcY/htSK
6	5	lmann	$2a$08$AQcRJOVHdIKw4UHJQDs/t.5r2gnk.K7y5wk.m0nXPxd9PWGg15KCK
7	6	bcarmel	$2a$08$EF1G4w42G6RkaYwUbHrdPudd.Mmt9fWtlAN/I7k0jrDoz8CgLf1w6
8	7	mlewis	$2a$08$Wwlq7L/vL5yPAI/XcLFPueGBheNGGAq9/NpgDonL78VPslQoD77C2
9	8	ttanner	$2a$08$cSMLFSdHFA3Zya8PlhOTX.BViAu.AHwQIVZ1M8GNfOn8BE.qAwp.K
10	9	jpatterson	$2a$08$oD//4949bUJa25vAm/Ha2.2It00DmTzxYwPCMPo83Cxo705uhRBQu
11	10	mbrown	$2a$08$4tgo67NGnCnFHN0U3VD8B.vfd.amxIw/mIJLnn3I5vlCoORoMmzLK
12	11	jsmith	$2a$08$SzrRddhBpjm.hjP2HKMoL.1jlb.cwFPSxV5ngXup2IDFZxl6BgSDq
13	12	jpeters	$2a$08$0gLLAwP9njd0.5.zery3IuNr9O0eAh0OVza61N0x.TLIf76wcEdLW
14	13	fmasters	$2a$08$JfeRqeQEOVOGKbDW6JUU/eVaPtjdR.5nXAJ.YeRIu5lfUPC4ITeYC
15	14	tmoon	$2a$08$orXNQ08u504Z.02mIviiNuVmsWkwcKm8NEJGJgeHIRG8OHyo.bhg.
16	15	lnguyen	$2a$08$mrBWmAj/nn1ZuAgr0dUCdOHjM4LXpyTbeyDRIC5dN4edLdIVjvNj.
17	16	mchau	$2a$08$WmyPSOKohRvHcUtWZrFyA.fbLG1xfbAPDZBdvJ7C9oxq.B1mjG.Va
18	17	akerry	$2a$08$eYl7A90dEpNL/7D8ASjYT.87QI13jAlBIRBByyFvi5v5dBu.dWfea
19	18	mrobinson	$2a$08$FwwWtXJ/Dn9Zrr1SK/qmx.krDL/zjbthoVjk8BoT.cpwFk57Uvhzq
20	19	mtaylor	$2a$08$SMpLsYRrr3FXvQ9MWOeq8.SQxwq4zyK82AWRXlK9f6qHtHFGeIPA2
21	20	amcgraw	$2a$08$2OmtcvCBYqLcHpj9NJM7zuZ3EW6jUQnyGr8mkj25q28sPgP4Q2VDW
22	21	cmorgan	$2a$08$fg.1Slou/as0zyW6kPN0RuBFmB7RsqhAcztA1L6sY7.se1iDqAkCy
23	22	ltan	$2a$08$OrnzVXziT353iYEwaDUQ6eN1sf4Iaml5q2IKOi7v6vUYAclMo6psa
24	23	rjameson	$2a$08$PDvmqU3h7gvD3RWpp3wPMOvlsFBiMLtiyKbq7KfPKUebszmwnPB4W
25	24	jbanner	$2a$08$bZF8CMooY5f4ocgGIYoP9ehkdE1VcoAemrXupCCVaKtKkTWMEBATO
26	25	tlee	$2a$08$e8k.TneYS5aSwlhNPf/xWu6xz7RpJWp6c5/ntmmbrLpf6ek2ig5Iu
27	26	jfabre	$2a$08$0gLEcxMPNak.xG5QrOLe3eZg4j6ykgQML4G69GBgZx40Sui8GgsBq
28	27	tgardner	$2a$08$ZWELqeMDHaiYykpeepxNJOmAggrY9L92sDy1CJmu9Nalwv.tXKy5K
29	28	byesler	$2a$08$2P3Lz6LRXBlC2mn/nzgdUONkvSTMn7O.M6wVRmw0dFeeBItM1LI3y
30	29	lcaroll	$2a$08$P3d6CLjUrKivEnFB6Ql9d.M897rLLMNP5XrhpPRG3k4KgJnk0QeN6
31	30	tlamont	$2a$08$xSwsi.NW/KjGn/jAyqZ0eeLVUhqxHmYmcrpCtRmNcnDYrff1bCD..
32	31	sjohnston	$2a$08$I1wiJdFSsyreRlDOtfF5DOnwrZmf3kfaAvsj33sVzAgafESvOpCzC
33	32	jeliot	$2a$08$O5bkbJW75qjkn6kv1RljuulCGYlVAN6mgcUMQd9LTA8QSCQqivKYS
34	33	jnguyen	$2a$08$75ugpw3f7rvboU2GoQUuW.jwQLFLLDdru2NDSFfi7WBtd.sT5jnBe
35	34	lperry	$2a$08$UYhwdhRKRCipFKSf0vnujemP1GZqJJHE32xnr0nFoobjttU3Q5iz6
36	35	cnortan	$2a$08$DaLzvrYt7MMw0uNQMbUJael2RCr0Qdm6DPR32R8bPnETp/1coHpym
37	36	mfarris	$2a$08$zN/OSJYnfpZsLmG2TIKTnek2Upj2SyDBX5AHfkNPMGfS8AUUGV77y
38	37	tfarmer	$2a$08$8y1G8PPx5mi4Ofdft3Q4HuP8.lteMXI5su5UNrpXdAV39O4iSAVje
39	38	lsanders	$2a$08$m4z14fo4giHCsQ3P9IREoe2MEnSEHiRcx1hhr7pYjBphEC6In2X3e
40	39	jsmith	$2a$08$KiNMCOpem3U.QBVk8PmR1ep3BoZdBtCTWCZtOczr0pOl90JjBD25m
41	40	pzukof	$2a$08$hNbNE/7ti1o8zrrZqaQXYeG1wcm.SyLM0EjrwQcnAoEZ2pNREr2Oi
42	41	kkim	$2a$08$BwDBi8xXL21P1X0Q6fKxmue5ffBkegYJUZUCdFpmT6ENmOdmHC6gG
43	42	tnorman	$2a$08$Y796r6KeTy3pwrBbXMiMcusZuEW75kkBpNnZEm8eabqksjc6kOFnK
44	43	cmanning	$2a$08$zz1mrXOxHhSjtQvVd.z8ge018DXzYspW1uyt2cUH1FKnhwM9r/CoK
45	44	lpatton	$2a$08$mrmkME2qqY4D2yOnEj0eauOcS9P6qGOAx9HkE1AUM5LvdQH8wy81G
46	45	ajorgenson	$2a$08$2o5roAruPbmuGrjZnZZ7quCyExfsABuM9DsqbqhSxvmmb7mY0skRS
47	46	fscheider	$2a$08$ELJynyP0xeGeEBrc4KaSCOLylSkxgKf/7Hzb1CS/A5FKc4UagUWzC
48	47	klee	$2a$08$y82IrVnw1xdeXr./jTaNzOr9qHbe59mGPTa1SOZmmd/5Lcswlucjm
49	48	pdenny	$2a$08$KdNcAPACGgi/HbpAcRlp1.isER9W7D0QFx5LGCUmxBG74iWYJl/Y.
50	49	jconner	$2a$08$eped0YaWC57o0RlWzLn4BOynR.mvy40DIPLmRJdpFkllGa7wHdA8.
51	50	akeanne	$2a$08$.GxTlVVEnwK005qjqaeYX.6XzwME7es1tEwYcpIfz6FlEx61IrwD2
52	51	jmeuller	$2a$08$ubDR/PYCcs0VEIlBz5aAguU/JBVYGQfGjRNOgJBvEJQwODIxcO01u
53	52	crogers	$2a$08$1/w6ZMuDEipwWYYIQih1fOrYfES8soCl8Jvjv2N0TjBjh1I5c6.vm
54	53	sponge	$2a$08$lEq8S6NAqdhM.tBkQnn.ouPf2MZlb3/vtwHAnio/6p5CG7avcl/u.
55	54	ctanner	$2a$08$amu5G4QY1GiiHzVFaPKkxeU7pCEDW4M6T1YfLP9x2.n4mMIIXUXYu
56	55	solson	$2a$08$.Cg8BrrSO4J54hMefl5dQ.91/LnXtwpCD8oeEn4OMeCeDjo8Rjp/i
57	56	jrobertson	$2a$08$p6CX2Ie0U1PY6Wuou5JhWewDLYMiqO6z5157FRT35OalJqVumiSwu
58	57	jjameson	$2a$08$iecvg8sM5Kd/34F59bqpUuvNRAqCvJvkvBOeAma9RqSVrGQBj2L12
59	58	cmaster	$2a$08$kImGC.siFvIvsxLRUmClPOhTAFZSqgcMiAzJLe8ds9AWn7g99lfqq
60	59	mnelson	$2a$08$66Sbu442eKisL66KS3HB2eqY8EBwjKJ8C8B8ZXd67sM9JEUQ//q3C
61	60	mpearson	$2a$08$PhXED4kROL/YdzTRCJfDNOC.JuJmklh1uJYB3HDUgrWbIVgH/PODC
62	61	jlynn	$2a$08$hwLcEABI73TFHpAqTo0R2O9A3PR5RNSATLJTqOMhBPGkWpNn2h83i
63	62	tjohnson	$2a$08$KET3uhKLdbKqH9YjA6yEgukKMdkNaXYc0G0PLcD39DOYYhLMhUanK
64	63	dthompson	$2a$08$LjwtZ/sZ3ymHdC8gXmB3ge7oLDvIOLmUSSecvJW/9D8btoSNdbv1K
65	64	lbrown	$2a$08$F4fm6V7nXwuebb3s1Z.znOR6FWYP2axsYydG4zvNPa0Mdc8f8uZnG
66	65	cnelson	$2a$08$IrffkZ8WXpKUy1aCmgNlw.NrqLk/J.Iro.lvZrO3ny6L2u8XHoL7q
67	66	mhandle	$2a$08$4Rnuqdv4DIrbE15VFYZWoeaz.hT8FlyUOiNqwvbW3FeboB0BhtAme
68	67	fcomstead	$2a$08$uHDcgujas6aPkGVxPVq0n.SuLgm34AomeOe0sKzyCuBMslmayrfEG
69	68	pmanson	$2a$08$CNufmdTKYei/nElwaaPa0ejz5QbEXv..0Undpm1cRRLxFoIMncM/K
70	69	sbaker	$2a$08$WsjYBtGK1BGRNl85gAocTuHFaHQaMQasH24s4aAH6toYWchLKJ2mC
71	70	ltmithin	$2a$08$phx64eKnP0ORcp5AE.W0dOOHCIQlXksRljPnCt0u/HyVADfzWHCBS
72	71	mpeterson	$2a$08$Vb0LADIfrLZzmOZiKkw/9uJfUGvd.HWnrw40iQYPVaKwl.SUj.vwm
73	72	bsalem	$2a$08$1MllmqydpDoA2DvbuRbeo.ivdyra0dBqK7ZjktLmrBP5BbKeXkNkG
74	73	kzorn	$2a$08$J4oauDRo8aIAvej/gUNxs.wtLfPtNnyp28NPtZdQShlexMf5t6HKy
75	74	hbaylor	$2a$08$yd3roPcA2MQtIJixWvrbEOmJVmaPz8F6658ejbkI66t5FuAxxTWg6
76	75	btaylor	$2a$08$DxDFlDJqFIXdIZYd23aeYutlnm2MAVCZHhZkK0BPknwbmCjGjUuKq
77	76	lmadison	$2a$08$rvsuBryXrEmaEoVWc88DQuvs23TbAVuujqr495xDf8I4GWtTlb/Vu
78	77	bgates	$2a$08$wjuOC2CeJjx5bSQ5p7NarONV87rvwsIS6tZC6ORoM1w/x7fL5A7ke
79	78	lgreen	$2a$08$pFmiwHn2Yo69DjN7uF06uez3NiRaU.ByFUzqaoETWhgPHy/aDTimG
80	79	pallen	$2a$08$8iNnCfGtCx50E23feCz4guCB/bgaSpRRNQRMOTlPyvRWK1gKbEfGC
81	80	kfortier	$2a$08$jRdAR/u2x0.kBcuRHcj8W.urlNDLastqFNn0H1U11P4AfaFmDpWsu
82	81	nlee	$2a$08$auhSceHLYPyBlaU2PxFW3.mK2PdgU6F0.0bVBEZ2OiSe9V35eqzzO
83	82	jchristensen	$2a$08$GKSSwzEVgZ73KsWvikMLvOpVKqdCxf/JirZDVih/IK.9uWZkbiWVu
84	83	neliot	$2a$08$f05SYonPqmf/f6HiSk.YR.9U2flld8FXlwi6HXxD7NTmdM1Q4pVRa
85	84	jweinberg	$2a$08$4QXKzYMTLj3tjkIWeCmrLeyG7A5Gip2q6.syVdN/c6mvNQH5Mj5.W
86	81	gbeneford	$2a$08$ukI.WevPk9ItmH2./go2VeMNxmcgxCy79lJF3eBZB9ilB/6gEDgli
87	86	lowens	$2a$08$AKQNGRtlldznFKTFaVJ4zuuy9ylPyWOLED4N7Sq8O0IWz.v8g7KMi
88	87	hsullivan	$2a$08$rCbXZ1Of6JoVKP67syi9Cu9vhwCMt1bPKI7ozp6yX0g7FUTYpEP0q
89	88	skingsley	$2a$08$H0cIl/xMtPv7k0bn8xDbcutGnRY734DN6kHg5qbIafJkXwL.8Dc76
90	89	wmiller	$2a$08$zqX3smpsNqHVUjpJHvUVXeSyvedb29WCYB8HRpqxIGJsHjDzhcG6G
91	90	lnelson	$2a$08$uNZ/4rYCmu25SKo/rfyRZePO6IOoyHivZ/9HGy.evC4QnqN5CZdwG
92	91	ntanner	$2a$08$BHMgTPWXx2Lf2bQSNH1BuOdmlRz8tb1vZ/knY.eavJtiNKxn3FYuq
93	92	ldenten	$2a$08$Rvk69VpBIvn22uRdh3.jmO.mdI311owyP623qI3nanGFul1d.YDpq
94	93	rclayborne	$2a$08$PXx5SXVkX5rhmEE9KuCP5OkVR6ha3r5xvW5QtwUdk4z9oEPLihQae
95	94	pmeyer	$2a$08$unskIwBrFJU.9SPMNDjisO2kYurMNAkmQU116ArrL7bWLWKqeTZAm
96	95	lmithen	$2a$08$WnBAKgnj9QLnkmjll5SHkuhGEM3QjxhLaQj4Xhqt82jKRY42Cq63G
97	96	ghawks	$2a$08$mXb.uCQCJlB0oVphghKoPOILR6nfYn5XLbQV76U5bFRQJt8m0qWSm
98	97	mbishop	$2a$08$pXMQZGl0EmqYv58qPNlUzuCFuw2Z0gsAAgj0/7olkwQ0s8wJtPtnq
99	98	edanielson	$2a$08$3ybwBe1gkyqi57XTWuFns.7VJNMd6aHUzYrVwkzXDOlw6QzlZxal2
100	99	jskeat	$2a$08$w2/EbrPPu9rG9pw6ljaNVuLaz5lkkUZryi9ewsUbEN.PDGSyQsq0O
101	100	mlovelace	$2a$08$BwLgkJBo6ATauVW/Tw6Lk.5/YYJb1fpMc3RtjU4jxWelitEVmjwdS
102	101	jmanners	$2a$08$bFuQgQiXFHAv8nES5HvYkOdInCPprrFGCyq3ud5trq0FampLW7i4W
103	102	n.st.marie	$2a$08$YCZTHxQE5PXC99N4nJLjKeh39T53ZnM0BudNpMpmf9JlCm7SacMPa
104	103	ekerry	$2a$08$ZWyRqshDbqhTP8aPiC1kN.KlgHF4qIyXBjf22hrTSBBd.VhxbKxw.
105	104	hkendel	$2a$08$RR8B3h1c./JEvyGrMsx/Su0OSipCjg8GFnyH5AfUahq4HU78qRcwW
106	105	rtaylor	$2a$08$.fncqQ9O47BrLbeaxusswOZ8BbhlS.BgrMIZFPzO6vkv8HBMGDuwG
107	106	hgrindle	$2a$08$naaj8pONvebsi0Cl6eIsn.Ly1IA3K/qnS9XyZS/TRUZz5OswCSDXK
108	107	lesperanzo	$2a$08$aviKrJf.xaae7.OfRlaUa.LOWNV6o0koiBBR/Edll/knds/WqPMD2
109	108	lsusuki	$2a$08$QQ4nEc0QEWmHt5BBHJDTKOJuNOGjhZUmprd1LYaOEkPvj9Z7fC/Xe
110	109	rvalencia	$2a$08$DO/mTr.m2e5bWIXl97XbOOPZF6dbDLBOZb5tacAZZ7OyzIn1mmqhi
111	110	rscanlon	$2a$08$r5hJWxWIXO4TgHXFO3UpHuWkSvZISw1P3lCe6UvMXn6qRJuC3fT4S
112	111	lpham	$2a$08$0ZQQxfvm0jW5z0MecDZgsuq82qKFgEETvNDfFxaRUoT.mUimF0ezq
135	136	jrodgers	$2a$08$SX2rezIYbWuWuBqQVxDQSOhUXJoYjz74LIV1f2F6KnIiXPvOrQXr.
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (personkey, personlastname, personfirstname, personemail, personprimaryphone, persondateadded) FROM stdin;
4	Zimmerman	Toby	TZimmerman@gmail.com	2065551212   	2017-02-03
5	Mann	Louis	LMann@gmail.com	2065550012   	2017-03-01
6	Carmel	Bob	BCarmel@gmail.com	2065551202   	2017-05-12
7	Lewis	Mary	MLewis@gmail.com	3605551000   	2017-05-21
8	Tanner	Thomas	TTanner@gmail.com	2065553423   	2017-06-01
10	Brown	Matt	MBrown@gmail.com	2065551113   	2017-06-15
11	Smith	Jerry	JSmith@gmail.com	36055553323  	2017-06-17
12	Peters	Jay	JPeters@gmail.com	2065559821   	2017-06-17
14	Moon	Tina	TMoon@gmail.com	2855553157   	2017-07-03
15	Nguyen	Lu	LNguyen@gmail.com	2065551223   	2017-06-05
16	Chau	Mary	MChau@gmail.com	2855550023   	2017-07-06
17	Kerry	Anne	AKerry@gmail.com	2065556712   	2017-07-06
18	Robinson	Mike	MRobinson@gmail.com	2065552321   	2017-07-13
19	Martin	Taylor	TMartin@gmail.com	2065557101   	2017-07-15
20	McGraw	Alysson	AMcGraw@gmail.com	2065551313   	2017-07-15
21	Morgan	Cheryl	CMorgan@gmail.com	3605553423   	2017-08-10
22	Tan	Lee	LTan@gmail.com	2065554534   	2017-08-22
23	Jameson	Roberto	RJameson@gmail.com	2065553423   	2017-08-23
24	Banner	June	JBanner@gmail.com	2065554441   	2017-08-25
25	Lee	Tracy	TLee@gmail.com	2065552212   	2017-08-25
26	Fabre	Jill	JFabre@gmail.com	2065550191   	2017-08-26
1	Lynn	Kendle	lynn.kendle@gmail.com	2065551312   	2017-02-02
27	Gardner	Tom	TGardner@gmail.com	3605553219   	2017-09-03
28	Yesler	Bill	BYesler@gmail.com	2065551128   	2017-09-05
29	Caroll	Lisa	LCaroll@gmail.com	2065559913   	2017-09-10
30	Lamont	Tess	TLamont@gmail.com	2065552323   	2017-09-10
31	Johnston	Sara	SJohnston@gmail.com	2065558601   	2017-09-15
32	Eliot	James	JEliot@gmail.com	2585550013   	2017-09-17
33	Nguyen	Jane	JNguyen@gmail.com	2065551230   	2017-09-18
34	Perry	Lee	LPerry@gmail.com	2065551029   	2017-09-20
35	Norton	Carrie	CNorton@gmail.com	2065551113   	2017-09-21
36	Farris	Mark	MFarris@gmail.com	2065553363   	2017-10-03
37	Farmer	Tim	TFarmer@gmail.com	2065552127   	2017-10-10
38	Sanders	Lea	LSanders@gmail.com	2065553487   	2017-10-10
39	Smith	Jim	JohnSmith@msn.com	2065550032   	2017-10-15
40	Zukof	Petra	PZukof@gmail.com	2065552134   	2017-10-17
41	Kim	Karen	KKim@gmail.com	2065553421   	2017-10-18
42	Norman	Tina	TNorman@gmail.com	3505552321   	2017-10-18
43	Manning	Carol	CManning@gmail.com	2065558753   	2017-10-22
44	Patton	Laura	LPatton@gmail.com	2065554765   	2017-10-28
45	Jorgenson	Amy	AJorgenson@gmail.com	2585553929   	2017-11-01
46	Schneider	Franz	FSchneider@gmail.com	2065559156   	2017-11-03
47	Kim	Lee	LKim@gmail.com	2065558176   	2017-11-10
48	Denny	Phil	PDenny@gmail.com	2065557612   	2017-11-15
49	Conner	Jessie	JConner@gmail.com	2065553342   	2017-11-17
50	Keanne	Ann	AKeanne@gmail.com	2065556798   	2017-11-20
51	Meuller	John	JMeuller@gmail.com	2065553009   	2017-11-20
52	Rogers	Cherise	CRogers@gmail.com	3605556118   	2017-11-25
53	Ponge	Sue	SPonge@gmail.com	2065550010   	2017-11-26
54	Tanner	Chelsea	ctanner@gmail.com	2065559010   	2017-11-27
55	Olson	Sonya	solson@gmail.com	25855561222  	2017-12-02
56	Robertson	Jeff	JeffRobertson@msn.com	2065556798   	2017-12-03
57	Jameson	Jessica	jj@yahoo.com	2585556338   	2017-12-05
58	Master	Carley	cmasters@msn.com	2065553332   	2017-12-05
59	Nelson	Martha	marthan@yahoo.com	2065554548   	2017-12-15
60	Pearson	Monica	pearson@gmail.com	3605556454   	2017-12-16
61	Lynn	Jennifer	jl@aol.com	2065557331   	2017-12-20
62	Johnson	Tina	tj@msn.com	2065552121   	2017-12-20
63	Thompson	Danielle	dthompson@msn.com	2065559939   	2017-12-21
64	Brown	Leah	leahbrown@comcast.com	2555551353   	2018-01-04
65	Nelson	Caitlin	caitlinnelson@msn.com	2065559310   	2018-01-06
66	Handle	Martin	handlethis@google.com	2065554856   	2018-01-08
67	Comstad	Fred	comstad@gmail.com	2065551211   	2018-01-12
68	Manson	Patrick	pm@gmail.com	2065554433   	2018-01-14
69	Baker	Sally	sallyb@gmail.com	3605559010   	2018-01-18
70	Mithin	Tammy	tammy@mithon.org	2065552232   	2018-01-25
71	Peterson	Monica	mpet@msn.com	2065552225   	2018-01-27
72	Blake	Salem	salemblake@yahoo.com	2065552001   	2018-02-03
73	Zorn	Ken	kz@yahoo.com	2065559923   	2018-02-05
74	Baylor	Henry	hbaylor@uwashington.edu	2065555535   	2018-02-12
75	Taylor	Beth	btaylor@yahoo.com	2065552231   	2018-02-21
76	Madison	Lawrence	lmadison@msn.com	3605552123   	2018-03-12
77	Gates	Bill	ggates@microsoft.com	2065551111   	2018-03-18
78	Green	Lewis	lg@outlook.com	2965557735   	2018-03-20
79	Allen	Paul	pa@outlook.com	2535550023   	2018-03-20
80	Fortier	Karen	KFortier@outlook.com	2605559090   	2018-03-26
81	Nguyen	Lee	nguyen200@msn.com	2065553312   	2018-04-01
82	Christensen	Judy	jChristensen@seattleu.edu	2535552177   	2018-04-05
83	Eliot	Neil	neliot@yahoo.com	2065557809   	2018-04-11
84	Weinberg	Jeffery	jWeinberg@speakeasy.org	3605552112   	2018-04-18
85	Beneford	Gail	beneford@gmail.com	2065552223   	2018-04-24
86	Owens	Leslie	leslieOwen@outlook.com	2535551002   	2018-05-05
87	Sullivan	Heather	heatherSullivan@gmail.com	2065551772   	2018-05-12
88	Kingsley	Sally	sk@kingsley.com	2065553344   	2018-05-15
89	Miller	Walter	waltermiller@yahoo.com	2535554343   	2018-05-18
90	Nelson	Leah	leah@starwars.org	2065559922   	2018-05-23
91	Tanner	Nathan	natherntanner@gmail.com	\N	2018-06-08
92	Denten	Laura	ldenten@aol.com	2065551255   	2018-06-19
93	Clayborne	Robert	rclayborne@outlook.com	2535550092   	2018-06-08
94	Meyer	Paul	pmeyer@hotmail.com	2065554340   	2018-07-07
95	Mithen	Leslie	leslie24@hotmail.com	\N	2018-07-12
96	Hawks	Gina	hawks@northwest.org	2065553332   	2018-07-13
9	Patterson	Jody	JPatterson@gmail.com	2065554231   	2017-06-10
3	Anderson	Jason	JAnderson@gmail.com	2065551100   	2017-02-02
13	Masters	Fae	FMasters@gmail.com	2065554231   	2017-06-21
97	Bishop	Martin	mBishop@enterprise.com	2535555550   	2018-07-18
98	Danielson	Erin	EDanielson@hotmail.com	2065556672   	2018-07-21
99	Skeat	Jonathen	skeat@newage.com	2065551212   	2018-07-23
100	Lovelace	Monica	mlove@hotmail.com	2065557678   	2018-07-28
101	Manners	Jill	jillmanners@outlook.com	3605552341   	2018-08-12
102	St. Marie	Nelson	nelson@seattleworks.org	2535552551   	2018-08-12
103	Kerry	Elizabeth	ekerry@gmail.com	2065558841   	2018-08-12
104	Kendel	Harriet	hkendel@outlook.com	\N	2018-09-03
105	Taylor	Rachel	rtaylor@gmail.com	2065553379   	2018-09-07
106	Grindle	Harris	hgrindle@outlook.com	3605551122   	2018-09-13
107	Esperanzo	Letty	esperabzo@aol.com	2535555533   	2018-09-21
108	Susuki	Lee	leesusuki@emeraldcity.org	\N	2018-09-23
109	Valencia	Roger	rvalencia@gmail.com	2065553436   	2018-09-23
110	Scanlon	Renee	scanlon@outlook.com	2065551212   	2018-09-27
111	Pham	Lee	leepham@outlook.com	3605556768   	2018-09-30
112	Mandela	Terry	tmandela@community.org	5355552309   	2018-10-13
113	Snow	Lester	lestersnow@hotmail.com	2065552119   	2018-10-13
114	Miller	Aldus	aldusmiller@gmail.com	3605551919   	2018-10-13
115	Rogers	Jill	jillRogers@msn.com	2065558868   	2018-10-20
116	Sung	Mary	marysung@outlook.com	2065551470   	2018-11-03
117	Jones	Lester	lj@speakeasy.org	2065553323   	2018-11-07
118	Xui	Nick	Xui@yahoo.com	\N	2018-11-12
119	Yun	Luong	Yun@outlook.com	2535551770   	2018-11-16
120	Kendrick	Peter	pk403@yahoo.com	2065554434   	2018-11-19
121	Baker	Tom	tombaker@bbc.org	2065556654   	2018-11-21
122	Liddell	Scott	scottLiddel@oxford.uk.edu	3605550001   	2018-11-23
123	Nguyen	Lee	leeNguyen@outlook.com	2065559976   	2018-11-25
124	Browning	Sally	SallyBrowning@aol.com	\N	2018-11-28
125	Stevens	Carla	carlaStevens@msn.com	2065554343   	2018-12-02
126	Steeler	Beth	bsteeler@hotmail.com	2065555543   	2018-12-07
127	Davidson	Pat	patDavidson@speakeasy.org	3605552222   	2018-12-13
128	Dexter	Johanne	johanne.Dexter@msn.com	2065557747   	2018-12-15
129	Norman	Jennifer	Jennifer@msn.com	2065554333   	2018-12-18
130	Nelson	Mark	MarkNelson@gmail.com	\N	2018-12-20
131	Mason	Thomas	thomas.mason@msn.com	2065557892   	2018-12-20
132	Johnson	Felicia	Felicia@gmail.com	3605551143   	2018-12-22
2	Hamilton	Linda	lindahamilton@gmail.com	2065551234   	2018-03-25
135	Henderson	Katy	khenderson01@gmail.com	2065559787   	2019-02-14
136	Rodgers	Joseph	joseph.rodgers@hotmail.com	2065552010   	2019-03-01
\.


--
-- Data for Name: personaddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personaddress (personaddresskey, personkey, personaddressstreet, personaddresscity, personaddressstate, personaddresszipcode, personaddressapt) FROM stdin;
1	1	1001 South Benton Street	Seattle	WA	98001      	\N
2	1	1012 Harvard Ave	Seattle	WA	98001      	\N
3	2	1232 East Meridian	Seattle	WA	98001      	\N
4	1	201 South Benson st	Seattle	WA	98100      	\N
5	2	1200 Division st	Seattle	WA	98100      	101
6	3	34 Broadway	Seattle	WA	98100      	\N
7	4	232 Pine	Seattle	WA	98100      	suite 203
8	5	1400 12th Ave	Seattle	WA	98100      	Rm 192
9	6	990 Lakeside Drive	Seattle	WA	98101      	\N
10	7	111 34th Avenue	Bellevue	WA	98132      	Suite 405
11	7	101 4th Avenue	Seattle	WA	98100      	Suite 625
12	8	345 24th	Seattle	WA	98100      	\N
13	9	222 Westlake	Seattle	WA	98100      	201
14	10	212 Ballard Ave	Seattle	WA	98101      	\N
15	11	5021 Pike	Seattle	WA	98100      	\N
16	12	Meridian	Seattle	WA	98100      	3A
17	13	15th Ave	Seattle	WA	98100      	201
18	14	213 Central	Seattle	WA	98100      	\N
19	14	100 Main	Bellevue	WA	98100      	764B
20	15	234 Harvard	Seattle	WA	98100      	\N
21	16	1900 8th	Seattle	WA	98100      	232
22	17	1450 Elm	Seattle	WA	98100      	34D
23	18	1343 Rainier	Kent	WA	98133      	O543
24	18	1023 Fisherman Drive	Seattle	WA	98100      	\N
25	19	235 4th Avenue	Seattle	WA	98100      	\N
26	20	212 Bell	Seattle	WA	98100      	230
27	21	214 12th	Bellevue	WA	98133      	44F
28	22	33 Michigan 	Seattle	WA	98100      	\N
29	23	176 Brown Street	Seattle	WA	98100      	\N
30	24	1827 Ballard	Seattle	WA	98100      	\N
31	25	3939 45th	Seattle	WA	98100      	301
32	26	3434 50th	Seattle	WA	98100      	\N
33	27	1000 West Baker	Bellevue	WA	98200      	120
34	28	200 North Elm	Seattle	WA	98100      	\N
35	29	North 220 Lakeside	Seattle	WA	98100      	\N
36	30	2432 21st street	Seattle	WA	98100      	21A
37	31	932 24th Avenue	Seattle	WA	98100      	\N
38	32	45467 Mason	Renton	WA	98500      	345
39	33	223 North Lake Drive	Seattle	WA	98100      	\N
40	34	234 Denny	Seattle	WA	98100      	532
41	35	899 Bell	Seattle	WA	98100      	222
42	36	1900 Madison	Seattle	WA	98100      	\N
43	37	821 15th Avenue	Seattle	WA	98100      	201
44	38	334 MLKing Way	Seattle	WA	98100      	\N
45	39	121 Weston	Seattle	WA	98000      	234
46	39	1000 Pike	Seattle	WA	98000      	100B
47	40	West 15th	Seattle	WA	98000      	333
48	41	235 34th	Seattle	WA	98000      	\N
49	42	321 North ave	Kent	WA	98022      	222
50	43	834 8th ave	Seattle	WA	98000      	\N
51	44	324 Maple Ave	Seattle	WA	98000      	\N
52	45	121 Trainside	Renton	WA	98000      	214
53	46	1200 Alder Street	Seattle	WA	98000      	102
54	47	2020 Martin Luther King Way	Seattle	WA	98100      	\N
55	48	983 8th Ave East	Seattle	WA	98000      	\N
56	49	Meridian Way	Seattle	WA	98000      	431
57	50	290 Aurora Ave	Seattle	WA	98100      	101
58	51	3900 West 35th	Seattle	WA	98100      	\N
59	52	1150 3rd Ave	Bellevue	WA	98210      	890
60	53	333 East Meridian	Seattle	WA	98100      	430
61	54	345 28th Street	Seattle	WA	98100      	\N
62	55	95 West Hannford	Tuckwilla	WA	98010      	Suite 545
63	56	850 Pike	Seattle	WA	98100      	100
64	57	1000 Tukwilla Drive	Tuckwilla	WA	98010      	Suite 99
65	57	100 Market Lane	Bellevue	WA	98002      	\N
66	58	765 Fremont Way	Seattle	WA	98100      	211
67	59	334 Crown Hill Drive	Seattle	WA	98100      	\N
68	60	343 Western	Seattle	WA	98100      	121
69	61	1504 Ballard Ave	Seattle	WA	98100      	453
70	62	1701 15th Ave	Seattle	WA	98100      	444
71	63	121 25th Ave West	Seattle	WA	98100      	\N
73	64	127 South Jackson Street	Seattle	WA	98100      	\N
74	65	2500 Maple Drive	Seattle	WA	98100      	203
75	66	919 Jefferson Lane	Bellevue	WA	98102      	apt 113
76	67	700 South Eastern Ave	Seattle	WA	98100      	\N
77	68	304 12th Street	Seattle	WA	98100      	110
78	69	1800 Pine	Seattle	WA	98100      	Apt 304
79	70	919 Waterview Crest	Bellevue	WA	98101      	\N
80	70	1200 8th Ave	Bellevue	WA	98101      	Suite 607
81	71	333 Jasmine	Seattle	WA	98100      	\N
118	72	24th Street E	Seattle	WA	98123      	\N
119	73	211 Pacific Ave	Seattle	WA	98102      	321
120	74	1405 Pine	Seattle	WA	98100      	343
121	75	201 North Elliot	Seattle	WA	98011      	\N
122	76	303 Eastlake Way	Seattle 	WA	98100      	\N
123	77	234 Ballard Way	Seattle	WA	98100      	121
124	78	1234 North Elm Street	Seattle	WA	98100      	232
125	79	204 34th Street	Seattle	WA	98012      	\N
126	80	212 Union Street	Seattle	WA	98001      	\N
127	81	123 14th	Seattle	WA	98123      	203
128	82	323 North Broad Street	Seattle	WA	98124      	\N
129	83	291 harvard	Seattle	WA	98100      	321
130	84	2323 WestLake	Seattle	WA	98110      	201
131	85	2345 Eastlake	Seattle	WA	98100      	\N
132	86	1423 North Pike	Seattle	WA	98123      	322
133	87	203 South Denny	Seattle	WA	98200      	\N
134	88	346 2nd Ave	Seattle	WA	98100      	435
135	89	2021 Bell	Seattle	WA	98100      	765
136	90	1201 Magnolia blvd	Seattle	WA	98100      	\N
137	91	Bell	Seattle	WA	98100      	451
138	92	324 82nd Ave	Seattle	WA	98001      	\N
139	93	234 Ballard Way	Seattle	WA	98100      	212
140	94	2121 65th Street	Seattle	WA	98001      	\N
141	95	292 Greenwood	Seattle	WA	98100      	\N
142	96	1201 East 8th	Bellevue	WA	98302      	756
143	97	306 Westlake	Seattle	WA	98100      	\N
144	98	121 Harvard	Seattle	WA	98122      	344
145	99	325 24th Street	Seattle	WA	98001      	101
146	100	2003 North 34th	Seattle	WA	98100      	\N
147	101	501 Nineth	Seattle	WA	98100      	343
148	102	213 NorthGate Blvd	\N	WA	98100      	\N
149	103	North 8th Street	Seattle	WA	98100      	345
150	104	203 East Ballard	Seattle	WA	98001      	\N
151	105	102 34thStreet	Seattle	WA	98100      	303
152	106	404 Lester aver	Seattle	WA	98001      	\N
153	107	102 Jackson Street	Seattle	WA	98002      	342
154	108	2003 Northwest Blvd	Seattle	WA	98100      	231b
155	109	1231 15th	Seattle	WA	98100      	\N
156	110	1101 Pine	Seattle	WA	98100      	121
157	111	908 24th Streer	Seattle	WA	98001      	\N
179	111	908 24th Streer	Seattle	WA	98001      	\N
180	112	131 North 36th Ave	Seattle	WA	98001      	\N
181	113	201 Queen Anne	Seattle	WA	98100      	213
182	114	204 56th Street	Redmond	WA	98102      	\N
183	115	324 WestLake Drive	Seattle	WA	98001      	\N
184	116	1536 Madison	Seattle	WA	98200      	109
185	117	2031 15th East	Seattle	WA	98100      	453
186	118	1245 James 	Seattle	WA	98001      	\N
187	119	432 24th Ave	Seattle	WA	98101      	\N
188	120	203 Tardis Way	Seattle	WA	98100      	\N
189	121	900 West Fifth	New York	NY	12000      	\N
190	122	324 8th Street	Seattle	WA	98001      	419
191	123	153 North Denny	Seattle	WA	98002      	\N
192	124	456 Eastlake	Seattle	WA	98100      	\N
193	125	334 Ballard Ave	Seattle	WA	98002      	2
194	126	333 South Eliot Way	Seattle	WA	98002      	\N
195	127	1232 Main	Seattle	WA	98100      	101 N
196	128	1291 Broadway	Seattle	WA	98122      	\N
197	129	123 NorthEast Broad	Seattle	WA	98122      	\N
198	130	217 Sount Meridian	Puyallup	WA	98022      	101
199	131	201 9th Avenue	Seattle	WA	98001      	203
200	132	809 12th	Seattle	WA	98001      	405
202	12	24th NW	Bellevue	WA	98001      	721B
204	12	24th NW	Seattle	WA	98001      	721B
205	136	WA	Seattle	WA	98001      	212
\.


--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status (statuskey, statusname) FROM stdin;
1	pending
2	granted
3	reduced
4	denied
\.


--
-- Name: businessrule_businessrulekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.businessrule_businessrulekey_seq', 1, false);


--
-- Name: donation_donationkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donation_donationkey_seq', 68, true);


--
-- Name: employee_employeekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_employeekey_seq', 7, true);


--
-- Name: employeeposition_employeepositionkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employeeposition_employeepositionkey_seq', 17, true);


--
-- Name: grantapplication_grantapplicationkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grantapplication_grantapplicationkey_seq', 55, true);


--
-- Name: grantreview_grantreviewkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grantreview_grantreviewkey_seq', 67, true);


--
-- Name: grantstatus_grantstatuskey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grantstatus_grantstatuskey_seq', 54, true);


--
-- Name: granttype_granttypekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.granttype_granttypekey_seq', 9, true);


--
-- Name: jobposition_positionkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jobposition_positionkey_seq', 17, true);


--
-- Name: loginhistory_loginhistorykey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.loginhistory_loginhistorykey_seq', 1, true);


--
-- Name: logintable_loginkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logintable_loginkey_seq', 135, true);


--
-- Name: person_personkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_personkey_seq', 136, true);


--
-- Name: personaddress_personaddresskey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personaddress_personaddresskey_seq', 205, true);


--
-- Name: pk_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_seq', 1, false);


--
-- Name: status_statuskey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_statuskey_seq', 4, true);


--
-- Name: businessrule businessrule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.businessrule
    ADD CONSTRAINT businessrule_pkey PRIMARY KEY (businessrulekey);


--
-- Name: donation donation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donation
    ADD CONSTRAINT donation_pkey PRIMARY KEY (donationkey);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employeekey);


--
-- Name: employeeposition employeeposition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employeeposition
    ADD CONSTRAINT employeeposition_pkey PRIMARY KEY (employeepositionkey);


--
-- Name: grantapplication grantapplication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantapplication
    ADD CONSTRAINT grantapplication_pkey PRIMARY KEY (grantapplicationkey);


--
-- Name: grantreview grantreview_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantreview
    ADD CONSTRAINT grantreview_pkey PRIMARY KEY (grantreviewkey);


--
-- Name: grantstatus grantstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantstatus
    ADD CONSTRAINT grantstatus_pkey PRIMARY KEY (grantstatuskey);


--
-- Name: granttype granttype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.granttype
    ADD CONSTRAINT granttype_pkey PRIMARY KEY (granttypekey);


--
-- Name: jobposition jobposition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobposition
    ADD CONSTRAINT jobposition_pkey PRIMARY KEY (positionkey);


--
-- Name: loginhistory loginhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loginhistory
    ADD CONSTRAINT loginhistory_pkey PRIMARY KEY (loginhistorykey);


--
-- Name: logintable logintable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logintable
    ADD CONSTRAINT logintable_pkey PRIMARY KEY (loginkey);


--
-- Name: person person_personemail_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_personemail_key UNIQUE (personemail);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (personkey);


--
-- Name: personaddress personaddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personaddress
    ADD CONSTRAINT personaddress_pkey PRIMARY KEY (personaddresskey);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (statuskey);


--
-- Name: idx_lastname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lastname ON public.person USING btree (personlastname);


--
-- Name: donation donation_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donation
    ADD CONSTRAINT donation_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: employee employee_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: employeeposition employeeposition_employeekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employeeposition
    ADD CONSTRAINT employeeposition_employeekey_fkey FOREIGN KEY (employeekey) REFERENCES public.employee(employeekey);


--
-- Name: employeeposition employeeposition_positionkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employeeposition
    ADD CONSTRAINT employeeposition_positionkey_fkey FOREIGN KEY (positionkey) REFERENCES public.jobposition(positionkey);


--
-- Name: grantapplication grantapplication_granttypekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantapplication
    ADD CONSTRAINT grantapplication_granttypekey_fkey FOREIGN KEY (granttypekey) REFERENCES public.granttype(granttypekey);


--
-- Name: grantapplication grantapplication_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantapplication
    ADD CONSTRAINT grantapplication_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: grantreview grantreview_employeekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantreview
    ADD CONSTRAINT grantreview_employeekey_fkey FOREIGN KEY (employeekey) REFERENCES public.employee(employeekey);


--
-- Name: grantreview grantreview_grantapplicationkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantreview
    ADD CONSTRAINT grantreview_grantapplicationkey_fkey FOREIGN KEY (grantapplicationkey) REFERENCES public.grantapplication(grantapplicationkey);


--
-- Name: grantstatus grantstatus_grantapplicationkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantstatus
    ADD CONSTRAINT grantstatus_grantapplicationkey_fkey FOREIGN KEY (grantapplicationkey) REFERENCES public.grantapplication(grantapplicationkey);


--
-- Name: grantstatus grantstatus_statuskey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grantstatus
    ADD CONSTRAINT grantstatus_statuskey_fkey FOREIGN KEY (statuskey) REFERENCES public.status(statuskey);


--
-- Name: loginhistory loginhistory_loginkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loginhistory
    ADD CONSTRAINT loginhistory_loginkey_fkey FOREIGN KEY (loginkey) REFERENCES public.logintable(loginkey);


--
-- Name: logintable logintable_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logintable
    ADD CONSTRAINT logintable_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: logintable logintable_personkey_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logintable
    ADD CONSTRAINT logintable_personkey_fkey1 FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: personaddress personaddress_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personaddress
    ADD CONSTRAINT personaddress_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: topdonors; Type: MATERIALIZED VIEW DATA; Schema: donorschema; Owner: postgres
--

REFRESH MATERIALIZED VIEW donorschema.topdonors;


--
-- Name: grantreview; Type: MATERIALIZED VIEW DATA; Schema: employeeschema; Owner: postgres
--

REFRESH MATERIALIZED VIEW employeeschema.grantreview;


--
-- PostgreSQL database dump complete
--

\connect "MilzOdaz"

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 10.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games (
    gamekey integer NOT NULL,
    title character varying(30) NOT NULL,
    console character varying(10) NOT NULL,
    ratingkey integer NOT NULL,
    categorytype text,
    publisherkey integer
);


ALTER TABLE public.games OWNER TO postgres;

--
-- Name: games_gamekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.games_gamekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.games_gamekey_seq OWNER TO postgres;

--
-- Name: games_gamekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.games_gamekey_seq OWNED BY public.games.gamekey;


--
-- Name: movies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movies (
    moviekey integer NOT NULL,
    title text NOT NULL,
    platform character(10),
    ratingkey integer NOT NULL,
    genre text,
    publisherkey integer NOT NULL
);


ALTER TABLE public.movies OWNER TO postgres;

--
-- Name: movies_moviekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.movies_moviekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movies_moviekey_seq OWNER TO postgres;

--
-- Name: movies_moviekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.movies_moviekey_seq OWNED BY public.movies.moviekey;


--
-- Name: publisher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publisher (
    publisherkey integer NOT NULL,
    publishername text NOT NULL,
    publishercity text,
    publisherstate character(2),
    publishercountry text
);


ALTER TABLE public.publisher OWNER TO postgres;

--
-- Name: publisher_publisherkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.publisher_publisherkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.publisher_publisherkey_seq OWNER TO postgres;

--
-- Name: publisher_publisherkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.publisher_publisherkey_seq OWNED BY public.publisher.publisherkey;


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ratings (
    ratingkey integer NOT NULL,
    rating character(4) NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.ratings OWNER TO postgres;

--
-- Name: ratings_ratingkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ratings_ratingkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ratings_ratingkey_seq OWNER TO postgres;

--
-- Name: ratings_ratingkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ratings_ratingkey_seq OWNED BY public.ratings.ratingkey;


--
-- Name: games gamekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games ALTER COLUMN gamekey SET DEFAULT nextval('public.games_gamekey_seq'::regclass);


--
-- Name: movies moviekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies ALTER COLUMN moviekey SET DEFAULT nextval('public.movies_moviekey_seq'::regclass);


--
-- Name: publisher publisherkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher ALTER COLUMN publisherkey SET DEFAULT nextval('public.publisher_publisherkey_seq'::regclass);


--
-- Name: ratings ratingkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings ALTER COLUMN ratingkey SET DEFAULT nextval('public.ratings_ratingkey_seq'::regclass);


--
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.games (gamekey, title, console, ratingkey, categorytype, publisherkey) FROM stdin;
1	Resident Evil 2 (remake)	PS4	4	Survival Horror	1
2	Horizon Zero Dawn	PS4	3	Action Adventure	8
3	Metal Gear Solid 4	PS4	4	Tactical Stealth	7
4	Lego Marvel Super Heros 2	PS4	2	Action	6
7	Mortal Kombat X	PS4	4	Fighting	6
8	Madden NFL 16	PS4	1	Sports/Football	5
9	The Evil Within	PS4	4	Survival Horror	4
10	The Last of Us Remastered	PS4	4	Survival Horror	9
11	The Last of Us	PS3	4	Survival Horror	9
\.


--
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movies (moviekey, title, platform, ratingkey, genre, publisherkey) FROM stdin;
1	Harold and Maude	DVD       	8	Comedy/Cult Classic	2
3	Seven	DVD       	10	Horror/Thriller	3
\.


--
-- Data for Name: publisher; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publisher (publisherkey, publishername, publishercity, publisherstate, publishercountry) FROM stdin;
1	Capcom USA	San Francisco	CA	United States of America
2	Paramount Pictures	Hollywood	CA	United States of America
3	New Line Cinema	New York City	NY	United States of America
4	Bethesda	Rockville	MD	United States of America
5	Electronic Arts Inc.	Redwood City	CA	United States of America
6	Warner Brothers Games	Burbank	CA	United States of America
7	Konami Digital Entertainment	El Segundo	CA	United States of America
8	Sony Interactive Entertainment	San Mateo	CA	United States of America
9	Naughty Dog	Santa Monica	CA	United States of America
\.


--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ratings (ratingkey, rating, description) FROM stdin;
1	E   	Everyone
2	E10 	Everyone 10 and up
3	T   	Teen
4	M   	Mature 17 and up
5	AO  	Adults Only
6	RP  	Rating Pending
7	G   	General Audiences
8	PG  	Parental Guidance Suggested
9	PG13	Parents Strongly Cautioned
10	R   	Restricted
11	NC17	Adults Only
12	NR  	Not Yet Rated
13	X   	Pornographic
\.


--
-- Name: games_gamekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.games_gamekey_seq', 11, true);


--
-- Name: movies_moviekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movies_moviekey_seq', 3, true);


--
-- Name: publisher_publisherkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publisher_publisherkey_seq', 9, true);


--
-- Name: ratings_ratingkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ratings_ratingkey_seq', 13, true);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (gamekey);


--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (moviekey);


--
-- Name: publisher publisher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (publisherkey);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (ratingkey);


--
-- Name: games publisher_publisherkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT publisher_publisherkey_fk FOREIGN KEY (publisherkey) REFERENCES public.publisher(publisherkey);


--
-- Name: movies publisher_publisherkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT publisher_publisherkey_fk FOREIGN KEY (publisherkey) REFERENCES public.publisher(publisherkey) ON UPDATE CASCADE;


--
-- Name: games ratings_ratingkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT ratings_ratingkey_fk FOREIGN KEY (ratingkey) REFERENCES public.ratings(ratingkey);


--
-- Name: movies ratings_ratingkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT ratings_ratingkey_fk FOREIGN KEY (ratingkey) REFERENCES public.ratings(ratingkey) ON UPDATE CASCADE;


--
-- PostgreSQL database dump complete
--

\connect "TechCert2"

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 10.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: instructorschema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA instructorschema;


ALTER SCHEMA instructorschema OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: addstudent(text, text, text, text, text, character, text, character, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addstudent("First Name" text, "Last Name" text, email text, address text, city text, "State" character, zip text, phone character, newsletter boolean, status integer, pass text) RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO person (firstname, lastname, email, address, city, state, postalcode, phone, dateadded, newsletter)
VALUES ("First Name", "Last Name", Email, Address, City, "State", Zip, Phone, current_timestamp, Newsletter);
INSERT INTO student (personkey, studentstartdate, statuskey)
VALUES (currval('person_personkey_seq'), current_timestamp, Status);
INSERT INTO logintable(username, personkey, userpassword, datelastchanged)
VALUES (makeusername("First Name", "Last Name"), currval('person_personkey_seq'), crypt(Pass, gen_salt('bf', 8)), current_timestamp);
$$;


ALTER FUNCTION public.addstudent("First Name" text, "Last Name" text, email text, address text, city text, "State" character, zip text, phone character, newsletter boolean, status integer, pass text) OWNER TO postgres;

--
-- Name: assign_grade(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.assign_grade(skey integer) RETURNS numeric
    LANGUAGE sql
    AS $$

Update Roster
set finalgrade=Random()*(5-1)+1
where studentkey=skey
returning finalgrade

$$;


ALTER FUNCTION public.assign_grade(skey integer) OWNER TO postgres;

--
-- Name: certcredits(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.certcredits(certkey integer) RETURNS integer
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.certcredits(certkey integer) OWNER TO postgres;

--
-- Name: costofsection3(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.costofsection3(sectionkey1 integer) RETURNS TABLE(sektionkey11 integer, costofsection numeric, costofsectiondiscounted numeric)
    LANGUAGE plpgsql
    AS $$
begin
return query
select coursesection.sectionkey,
(sum(course.credits)*pricehistory.pricepercredit) as "Total Cost without discount",
(sum(course.credits)*pricehistory.pricepercredit*(1-pricehistory.pricediscount)) as "Total Cost with discount"
from course
inner join coursesection on course.coursekey = coursesection.coursekey
inner join pricehistory on pricehistory.pricehistorykey = coursesection.pricehistorykey
where coursesection.sectionkey = sectionkey1
group by coursesection.sectionkey, pricehistory.pricepercredit, (1-pricehistory.pricediscount);
end;
$$;


ALTER FUNCTION public.costofsection3(sectionkey1 integer) OWNER TO postgres;

--
-- Name: coursecreds(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.coursecreds(sk integer) RETURNS TABLE("Credits Taken" bigint)
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.coursecreds(sk integer) OWNER TO postgres;

--
-- Name: courseprice(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.courseprice(sk integer) RETURNS TABLE("Base Cost" numeric, "Discounted" numeric)
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.courseprice(sk integer) OWNER TO postgres;

--
-- Name: coursestaken(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.coursestaken(sk integer) RETURNS TABLE("Courses Taken" text, "Course Credits" integer, "Final Grade" numeric)
    LANGUAGE plpgsql
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
$$;


ALTER FUNCTION public.coursestaken(sk integer) OWNER TO postgres;

--
-- Name: createpassword(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.createpassword(pass character varying) RETURNS text
    LANGUAGE sql
    AS $$
Select crypt(pass, gen_salt('bf', 8))
$$;


ALTER FUNCTION public.createpassword(pass character varying) OWNER TO postgres;

--
-- Name: makeusername(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.makeusername(firstname text, lastname text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN SUBSTRING(firstname, 1,1) || lastname;
END;
$$;


ALTER FUNCTION public.makeusername(firstname text, lastname text) OWNER TO postgres;

--
-- Name: setflag(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.setflag() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.finalgrade < 2.0
THEN
UPDATE roster r
SET lowgradeflag = TRUE
WHERE r.rosterkey = NEW.rosterkey;
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.setflag() OWNER TO postgres;

--
-- Name: setflag2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.setflag2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if NEW.finalgrade < 2.0
then
update roster
set lowgradeflag = TRUE
where roster.rosterkey = NEW.rosterkey;
else
set lowgradeflag = false;
END IF;
return NEW;
end;
$$;


ALTER FUNCTION public.setflag2() OWNER TO postgres;

--
-- Name: totalofcredits4(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.totalofcredits4(studentkey1 integer) RETURNS TABLE(tbstudentkey integer, tbstcredits bigint)
    LANGUAGE plpgsql
    AS $$
begin
return query
select student.studentkey, sum(course.credits) as "Total credit"
from student
inner join roster on student.studentkey = roster.studentkey
inner join coursesection on roster.sectionkey = coursesection.sectionkey
inner join course on coursesection.coursekey = course.coursekey
where student.studentkey = studentkey1
group by student.studentkey;
end;
$$;


ALTER FUNCTION public.totalofcredits4(studentkey1 integer) OWNER TO postgres;

--
-- Name: updatestudent(integer, text, text, text, character, text, text, character, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatestudent(sk integer, "First Name" text, "Last Name" text, email text, phone character, address text, city text, "State" character, zip text) RETURNS void
    LANGUAGE sql
    AS $$
UPDATE person p
SET firstname="First Name", lastname="Last Name", email=Email, phone=Phone, address=Address, city=City, 
state="State", postalcode=Zip
WHERE p.personkey=(SELECT s.personkey FROM student s WHERE s.studentkey=SK);
$$;


ALTER FUNCTION public.updatestudent(sk integer, "First Name" text, "Last Name" text, email text, phone character, address text, city text, "State" character, zip text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    personkey integer NOT NULL,
    lastname text NOT NULL,
    firstname text,
    email text NOT NULL,
    address text,
    city text,
    state character(2),
    postalcode text,
    phone character(14),
    dateadded date,
    newsletter boolean DEFAULT true
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: people; Type: VIEW; Schema: instructorschema; Owner: postgres
--

CREATE VIEW instructorschema.people AS
 SELECT person.personkey AS "PK",
    person.lastname AS "Last",
    person.firstname AS "First",
    person.email AS "Email",
    person.address AS "Address",
    person.city AS "City",
    person.state AS "State",
    person.postalcode AS "Zip",
    person.phone AS "Phone",
    person.dateadded AS "Date Added"
   FROM public.person
  WHERE (person.state = 'WA'::bpchar)
  ORDER BY person.dateadded
  WITH CASCADED CHECK OPTION;


ALTER TABLE instructorschema.people OWNER TO postgres;

--
-- Name: roster; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roster (
    rosterkey integer NOT NULL,
    sectionkey integer,
    studentkey integer,
    finalgrade numeric,
    lowgradeflag boolean DEFAULT false,
    CONSTRAINT chk_grade CHECK (((finalgrade >= (0)::numeric) AND (finalgrade <= (4)::numeric)))
);


ALTER TABLE public.roster OWNER TO postgres;

--
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    studentkey integer NOT NULL,
    personkey integer,
    studentstartdate date NOT NULL,
    statuskey integer
);


ALTER TABLE public.student OWNER TO postgres;

--
-- Name: roster71; Type: VIEW; Schema: instructorschema; Owner: postgres
--

CREATE VIEW instructorschema.roster71 AS
 SELECT r.studentkey AS "ID",
    ((p.lastname || ', '::text) || p.firstname) AS "Name",
    p.email AS "Email"
   FROM ((public.person p
     JOIN public.student s ON ((p.personkey = s.personkey)))
     JOIN public.roster r ON ((s.studentkey = r.studentkey)))
  WHERE (r.sectionkey = 71)
  ORDER BY r.studentkey;


ALTER TABLE instructorschema.roster71 OWNER TO postgres;

--
-- Name: status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status (
    statuskey integer NOT NULL,
    statusname text NOT NULL
);


ALTER TABLE public.status OWNER TO postgres;

--
-- Name: studentstatus; Type: MATERIALIZED VIEW; Schema: instructorschema; Owner: postgres
--

CREATE MATERIALIZED VIEW instructorschema.studentstatus AS
 SELECT DISTINCT ON (s.studentkey) s.studentkey AS "ID Key",
    ((p.lastname || ', '::text) || p.firstname) AS "Name",
    s.studentstartdate AS "Start Date",
    st.statusname AS "Status"
   FROM (((public.student s
     JOIN public.person p ON ((p.personkey = s.personkey)))
     JOIN public.roster r ON ((r.studentkey = s.studentkey)))
     JOIN public.status st ON ((st.statuskey = s.statuskey)))
  ORDER BY s.studentkey
  WITH NO DATA;


ALTER TABLE instructorschema.studentstatus OWNER TO postgres;

--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    attendancekey integer NOT NULL,
    seminardetailkey integer NOT NULL,
    personkey integer NOT NULL
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: attendance_attendancekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_attendancekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attendance_attendancekey_seq OWNER TO postgres;

--
-- Name: attendance_attendancekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_attendancekey_seq OWNED BY public.attendance.attendancekey;


--
-- Name: businessrule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.businessrule (
    businessrulekey integer NOT NULL,
    businessruletext text
);


ALTER TABLE public.businessrule OWNER TO postgres;

--
-- Name: businessrule_businessrulekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.businessrule_businessrulekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.businessrule_businessrulekey_seq OWNER TO postgres;

--
-- Name: businessrule_businessrulekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.businessrule_businessrulekey_seq OWNED BY public.businessrule.businessrulekey;


--
-- Name: certadmin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.certadmin (
    certadminkey integer NOT NULL,
    personkey integer,
    statuskey integer
);


ALTER TABLE public.certadmin OWNER TO postgres;

--
-- Name: certadmin_certadminkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.certadmin_certadminkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.certadmin_certadminkey_seq OWNER TO postgres;

--
-- Name: certadmin_certadminkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.certadmin_certadminkey_seq OWNED BY public.certadmin.certadminkey;


--
-- Name: certificate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.certificate (
    certificatekey integer NOT NULL,
    certificatename text NOT NULL,
    certificatedescription text
);


ALTER TABLE public.certificate OWNER TO postgres;

--
-- Name: certificate_certificatekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.certificate_certificatekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.certificate_certificatekey_seq OWNER TO postgres;

--
-- Name: certificate_certificatekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.certificate_certificatekey_seq OWNED BY public.certificate.certificatekey;


--
-- Name: certificatecourse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.certificatecourse (
    certificatekey integer NOT NULL,
    coursekey integer NOT NULL,
    minimumgrade numeric NOT NULL
);


ALTER TABLE public.certificatecourse OWNER TO postgres;

--
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    coursekey integer NOT NULL,
    coursename text NOT NULL,
    credits integer NOT NULL,
    coursedescription text
);


ALTER TABLE public.course OWNER TO postgres;

--
-- Name: course_coursekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_coursekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.course_coursekey_seq OWNER TO postgres;

--
-- Name: course_coursekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_coursekey_seq OWNED BY public.course.coursekey;


--
-- Name: coursesection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coursesection (
    sectionkey integer NOT NULL,
    coursekey integer,
    instructorkey integer,
    sectionyear integer NOT NULL,
    pricehistorykey integer,
    quarterkey integer
);


ALTER TABLE public.coursesection OWNER TO postgres;

--
-- Name: coursesection_sectionkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.coursesection_sectionkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.coursesection_sectionkey_seq OWNER TO postgres;

--
-- Name: coursesection_sectionkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.coursesection_sectionkey_seq OWNED BY public.coursesection.sectionkey;


--
-- Name: instructionalarea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instructionalarea (
    instructionalareakey integer NOT NULL,
    areaname text NOT NULL,
    description text
);


ALTER TABLE public.instructionalarea OWNER TO postgres;

--
-- Name: instructionalarea_instructionalareakey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.instructionalarea_instructionalareakey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.instructionalarea_instructionalareakey_seq OWNER TO postgres;

--
-- Name: instructionalarea_instructionalareakey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.instructionalarea_instructionalareakey_seq OWNED BY public.instructionalarea.instructionalareakey;


--
-- Name: instructor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instructor (
    instructorkey integer NOT NULL,
    personkey integer,
    hiredate date NOT NULL,
    statuskey integer
);


ALTER TABLE public.instructor OWNER TO postgres;

--
-- Name: instructor_instructorkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.instructor_instructorkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.instructor_instructorkey_seq OWNER TO postgres;

--
-- Name: instructor_instructorkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.instructor_instructorkey_seq OWNED BY public.instructor.instructorkey;


--
-- Name: instructorarea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instructorarea (
    instructionalareakey integer NOT NULL,
    instructorkey integer NOT NULL
);


ALTER TABLE public.instructorarea OWNER TO postgres;

--
-- Name: location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location (
    locationkey integer NOT NULL,
    locationname text NOT NULL,
    locationaddress text NOT NULL,
    locationcity text NOT NULL,
    locationstate character(2) NOT NULL,
    postalcode character varying(12) NOT NULL,
    phone character varying(13) NOT NULL,
    email text NOT NULL
);


ALTER TABLE public.location OWNER TO postgres;

--
-- Name: location_locationkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.location_locationkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.location_locationkey_seq OWNER TO postgres;

--
-- Name: location_locationkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.location_locationkey_seq OWNED BY public.location.locationkey;


--
-- Name: loginhistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loginhistory (
    loginhistorykey integer NOT NULL,
    logintablekey integer,
    logindate date DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.loginhistory OWNER TO postgres;

--
-- Name: loginhistory_loginhistorykey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.loginhistory_loginhistorykey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loginhistory_loginhistorykey_seq OWNER TO postgres;

--
-- Name: loginhistory_loginhistorykey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.loginhistory_loginhistorykey_seq OWNED BY public.loginhistory.loginhistorykey;


--
-- Name: logintable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logintable (
    logintablekey integer NOT NULL,
    username text,
    personkey integer,
    userpassword text,
    datelastchanged date
);


ALTER TABLE public.logintable OWNER TO postgres;

--
-- Name: logintable_logintablekey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logintable_logintablekey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logintable_logintablekey_seq OWNER TO postgres;

--
-- Name: logintable_logintablekey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logintable_logintablekey_seq OWNED BY public.logintable.logintablekey;


--
-- Name: person_personkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_personkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_personkey_seq OWNER TO postgres;

--
-- Name: person_personkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_personkey_seq OWNED BY public.person.personkey;


--
-- Name: pricehistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pricehistory (
    pricehistorykey integer NOT NULL,
    pricebegindate date NOT NULL,
    pricepercredit numeric(10,2) NOT NULL,
    pricediscount numeric(3,2)
);


ALTER TABLE public.pricehistory OWNER TO postgres;

--
-- Name: pricehistory_pricehistorykey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pricehistory_pricehistorykey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pricehistory_pricehistorykey_seq OWNER TO postgres;

--
-- Name: pricehistory_pricehistorykey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pricehistory_pricehistorykey_seq OWNED BY public.pricehistory.pricehistorykey;


--
-- Name: quarter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quarter (
    quarterkey integer NOT NULL,
    quartername text
);


ALTER TABLE public.quarter OWNER TO postgres;

--
-- Name: quarter_quarterkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quarter_quarterkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quarter_quarterkey_seq OWNER TO postgres;

--
-- Name: quarter_quarterkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quarter_quarterkey_seq OWNED BY public.quarter.quarterkey;


--
-- Name: roster_rosterkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roster_rosterkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roster_rosterkey_seq OWNER TO postgres;

--
-- Name: roster_rosterkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roster_rosterkey_seq OWNED BY public.roster.rosterkey;


--
-- Name: seminar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seminar (
    seminarkey integer NOT NULL,
    locationkey integer NOT NULL,
    theme text NOT NULL,
    seminardate date NOT NULL,
    description text
);


ALTER TABLE public.seminar OWNER TO postgres;

--
-- Name: seminar_seminarkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seminar_seminarkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seminar_seminarkey_seq OWNER TO postgres;

--
-- Name: seminar_seminarkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seminar_seminarkey_seq OWNED BY public.seminar.seminarkey;


--
-- Name: seminardetails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seminardetails (
    seminardetailkey integer NOT NULL,
    seminarkey integer NOT NULL,
    topic text NOT NULL,
    presenttime time without time zone,
    room character(5),
    instructorkey integer,
    description text
);


ALTER TABLE public.seminardetails OWNER TO postgres;

--
-- Name: seminardetails_seminardetailkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seminardetails_seminardetailkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seminardetails_seminardetailkey_seq OWNER TO postgres;

--
-- Name: seminardetails_seminardetailkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seminardetails_seminardetailkey_seq OWNED BY public.seminardetails.seminardetailkey;


--
-- Name: status_statuskey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_statuskey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_statuskey_seq OWNER TO postgres;

--
-- Name: status_statuskey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_statuskey_seq OWNED BY public.status.statuskey;


--
-- Name: student_studentkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_studentkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_studentkey_seq OWNER TO postgres;

--
-- Name: student_studentkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_studentkey_seq OWNED BY public.student.studentkey;


--
-- Name: substitution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.substitution (
    substitutionkey integer NOT NULL,
    certificatekey integer,
    coursekey integer,
    substitutekey integer,
    studentkey integer,
    certadminkey integer
);


ALTER TABLE public.substitution OWNER TO postgres;

--
-- Name: substitution_substitutionkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.substitution_substitutionkey_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.substitution_substitutionkey_seq OWNER TO postgres;

--
-- Name: substitution_substitutionkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.substitution_substitutionkey_seq OWNED BY public.substitution.substitutionkey;


--
-- Name: attendance attendancekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance ALTER COLUMN attendancekey SET DEFAULT nextval('public.attendance_attendancekey_seq'::regclass);


--
-- Name: businessrule businessrulekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.businessrule ALTER COLUMN businessrulekey SET DEFAULT nextval('public.businessrule_businessrulekey_seq'::regclass);


--
-- Name: certadmin certadminkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certadmin ALTER COLUMN certadminkey SET DEFAULT nextval('public.certadmin_certadminkey_seq'::regclass);


--
-- Name: certificate certificatekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificate ALTER COLUMN certificatekey SET DEFAULT nextval('public.certificate_certificatekey_seq'::regclass);


--
-- Name: course coursekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course ALTER COLUMN coursekey SET DEFAULT nextval('public.course_coursekey_seq'::regclass);


--
-- Name: coursesection sectionkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coursesection ALTER COLUMN sectionkey SET DEFAULT nextval('public.coursesection_sectionkey_seq'::regclass);


--
-- Name: instructionalarea instructionalareakey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructionalarea ALTER COLUMN instructionalareakey SET DEFAULT nextval('public.instructionalarea_instructionalareakey_seq'::regclass);


--
-- Name: instructor instructorkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor ALTER COLUMN instructorkey SET DEFAULT nextval('public.instructor_instructorkey_seq'::regclass);


--
-- Name: location locationkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location ALTER COLUMN locationkey SET DEFAULT nextval('public.location_locationkey_seq'::regclass);


--
-- Name: loginhistory loginhistorykey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loginhistory ALTER COLUMN loginhistorykey SET DEFAULT nextval('public.loginhistory_loginhistorykey_seq'::regclass);


--
-- Name: logintable logintablekey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logintable ALTER COLUMN logintablekey SET DEFAULT nextval('public.logintable_logintablekey_seq'::regclass);


--
-- Name: person personkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person ALTER COLUMN personkey SET DEFAULT nextval('public.person_personkey_seq'::regclass);


--
-- Name: pricehistory pricehistorykey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pricehistory ALTER COLUMN pricehistorykey SET DEFAULT nextval('public.pricehistory_pricehistorykey_seq'::regclass);


--
-- Name: quarter quarterkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quarter ALTER COLUMN quarterkey SET DEFAULT nextval('public.quarter_quarterkey_seq'::regclass);


--
-- Name: roster rosterkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster ALTER COLUMN rosterkey SET DEFAULT nextval('public.roster_rosterkey_seq'::regclass);


--
-- Name: seminar seminarkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seminar ALTER COLUMN seminarkey SET DEFAULT nextval('public.seminar_seminarkey_seq'::regclass);


--
-- Name: seminardetails seminardetailkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seminardetails ALTER COLUMN seminardetailkey SET DEFAULT nextval('public.seminardetails_seminardetailkey_seq'::regclass);


--
-- Name: status statuskey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status ALTER COLUMN statuskey SET DEFAULT nextval('public.status_statuskey_seq'::regclass);


--
-- Name: student studentkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN studentkey SET DEFAULT nextval('public.student_studentkey_seq'::regclass);


--
-- Name: substitution substitutionkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.substitution ALTER COLUMN substitutionkey SET DEFAULT nextval('public.substitution_substitutionkey_seq'::regclass);


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (attendancekey, seminardetailkey, personkey) FROM stdin;
\.


--
-- Data for Name: businessrule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.businessrule (businessrulekey, businessruletext) FROM stdin;
12	Students must take the core courses before they can work on other certificates
13	Students must maintain a 2.0 or better average to recieve a certificate
14	Students pay per credit, but if they take 15 or more the discount applies
15	Any course substitutions must be approved by a certadmin
16	Instructors recieve 60% of the money taken in for a course
\.


--
-- Data for Name: certadmin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.certadmin (certadminkey, personkey, statuskey) FROM stdin;
1	1	1
2	2	1
3	3	2
4	4	1
\.


--
-- Data for Name: certificate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.certificate (certificatekey, certificatename, certificatedescription) FROM stdin;
1	Java Programming	From the basics to mastery
2	Python Programming	Power python including data and science libraries
3	Web Design	HTML5, CSS and design principles
4	Javascript	Complete Client and server side Javascript
5	Database Development	Relational and NoSQL design and development
6	App Development	Phone app development in Android and IOS
7	IT Core	Basics to build on
\.


--
-- Data for Name: certificatecourse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.certificatecourse (certificatekey, coursekey, minimumgrade) FROM stdin;
7	1	2.0
7	2	2.0
7	3	2.0
7	4	2.0
1	5	2.0
1	6	2.0
1	7	2.0
1	8	2.0
2	9	2.0
2	10	2.0
2	11	2.0
2	12	2.0
3	13	2.0
3	14	2.0
3	15	2.0
4	16	2.0
4	17	2.0
4	18	2.0
5	19	3.0
5	20	2.0
5	21	2.0
5	22	2.0
6	23	3.0
6	24	2.0
6	25	3.0
6	26	2.0
6	27	3.0
\.


--
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course (coursekey, coursename, credits, coursedescription) FROM stdin;
1	Beginning Programming	5	Introduction to basic programming logic and sructures
2	First Relational Database	5	Introduction Relational database structure and design
3	Web Pages 101	3	Introduction to HTML and CSS
4	Operating Systems and Basic Connectivity	5	Introduction to Operating Sytems and basic Network concepts
5	Introduction to Java	5	Basics of Java programming logic and sructures
6	Object Oriented Programming with Java	5	Object oriented programming concepts and practice
7	Data Structures with Java	5	Data sructures
8	Java Services	5	Service oriented architechture with Java
9	Introduction to Python	5	Basics of Python programming logic and sructures
10	Python Projects	5	Programming projects with Python, emphasis on using libraries
11	Django	5	Python web development
12	Python Data Analytics	5	Using Python Data Analysis libraries and connectivity to databases
13	Web Design Principles	3	HTML, advanced CSS and basic User design
14	Graphics for Web Design	3	Creating, manipulating and displaying graphics on web pages
15	Web Projects	5	Designing web pages for real clients
16	Introduction to Javascipt	3	Basics of JavaScript client programming logic and sructures
17	Advanced JavaScript	3	JSON, Selected JavaScript frameworks
18	Server Side JavaScript	5	Server side JavaScript using frameworks such as NodeJS
19	SQL	5	SQL for creating and manipulating database data and objects
20	NoSQL	5	Basics developing and querying NoSQL Databases
21	ETL and Reporing	5	Exporting, Transforming and Loading data for analysis. Reporting and visualization of data
22	Database Administration	5	Adminstrating both Relational and NoSQL database locally and on cloud
23	App Development in Android	5	Basics of Android programming logic and sructures
24	Advanced Android	5	Advanced Android programming including sqlLite
25	Introduction to IOS App Develpment	5	Basics of IOS programming logic and sructures
26	Advanced IOS App Development	5	Advanced IOS logic and sructures
27	App Development Capstone	5	Design and create and App
28	Statistics for Data Analysis	5	Statistics with a focus on data science and analyrics
\.


--
-- Data for Name: coursesection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coursesection (sectionkey, coursekey, instructorkey, sectionyear, pricehistorykey, quarterkey) FROM stdin;
1	1	1	2017	1	1
2	2	4	2017	1	1
3	3	3	2017	1	1
4	4	8	2017	1	1
5	1	1	2018	2	2
6	2	4	2018	2	2
7	3	3	2018	2	2
8	4	8	2018	2	2
9	5	1	2018	2	2
10	9	8	2018	2	2
11	13	3	2018	2	2
12	16	5	2018	2	2
13	19	4	2018	2	2
14	1	1	2018	2	3
15	2	4	2018	2	3
16	3	3	2018	2	3
17	4	8	2018	2	3
18	5	1	2018	2	3
19	6	8	2018	2	3
20	13	3	2018	2	3
21	16	4	2018	2	3
24	10	9	2018	2	3
25	14	7	2018	2	3
26	17	8	2018	2	3
27	20	10	2018	2	3
28	19	1	2018	2	3
29	1	1	2018	2	4
30	2	4	2018	2	4
31	3	5	2018	2	4
32	4	9	2018	2	4
33	5	1	2018	2	4
34	9	9	2018	2	4
35	13	3	2018	2	4
36	18	8	2018	2	4
37	21	4	2018	2	4
38	22	4	2018	2	4
39	1	1	2018	2	1
40	2	4	2018	2	1
41	3	3	2018	2	1
42	4	8	2018	2	1
43	5	1	2018	2	1
44	9	8	2018	2	1
45	13	3	2018	2	1
46	19	4	2018	2	1
47	6	8	2018	2	1
48	14	7	2018	2	1
49	18	10	2018	2	1
50	19	4	2018	2	1
51	23	2	2018	2	1
52	25	5	2018	2	1
71	1	1	2019	3	2
72	2	4	2019	3	2
73	3	3	2019	3	2
74	4	8	2019	3	2
75	5	1	2019	3	2
76	6	8	2019	3	2
77	9	8	2019	3	2
78	13	3	2019	3	2
79	14	7	2019	3	2
80	18	10	2019	3	2
81	19	4	2019	3	2
82	23	2	2019	3	2
83	25	5	2019	3	2
84	10	1	2019	3	2
85	16	3	2019	3	2
86	20	4	2019	3	2
87	24	2	2019	3	2
88	26	2	2019	3	2
89	1	1	2019	3	3
90	2	4	2019	3	3
91	3	3	2019	3	3
92	4	1	2019	3	3
93	5	8	2019	3	3
94	6	8	2019	3	3
95	7	9	2019	3	3
96	8	9	2019	3	3
97	9	1	2019	3	3
98	10	1	2019	3	3
99	11	9	2019	3	3
100	12	9	2019	3	3
101	13	3	2019	3	3
102	14	5	2019	3	3
103	15	5	2019	3	3
104	16	8	2019	3	3
105	17	8	2019	3	3
106	18	8	2019	3	3
107	19	4	2019	3	3
108	20	4	2019	3	3
109	21	4	2019	3	3
110	22	4	2019	3	3
111	23	6	2019	3	3
112	24	6	2019	3	3
113	25	8	2019	3	3
114	26	6	2019	3	3
115	27	6	2019	3	3
\.


--
-- Data for Name: instructionalarea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instructionalarea (instructionalareakey, areaname, description) FROM stdin;
1	Programming	\N
3	Mobile apps	\N
4	Javascript developer	\N
5	Web Devloper	backend programing, database connections, etc.
6	Database Developer	\N
2	Web Design	JTML CSS graphics and user design
\.


--
-- Data for Name: instructor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instructor (instructorkey, personkey, hiredate, statuskey) FROM stdin;
1	5	2017-01-20	1
2	6	2017-01-20	1
3	7	2017-01-25	1
4	8	2017-02-05	1
5	9	2017-02-08	1
6	10	2017-02-15	2
7	11	2017-02-17	1
8	12	2017-02-21	1
9	401	2018-02-20	1
10	402	2018-02-20	1
11	403	2019-01-22	1
\.


--
-- Data for Name: instructorarea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instructorarea (instructionalareakey, instructorkey) FROM stdin;
1	1
3	1
2	2
2	3
4	3
5	3
1	4
6	4
4	5
3	6
2	7
1	8
3	8
4	8
1	9
6	10
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location (locationkey, locationname, locationaddress, locationcity, locationstate, postalcode, phone, email) FROM stdin;
\.


--
-- Data for Name: loginhistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.loginhistory (loginhistorykey, logintablekey, logindate) FROM stdin;
\.


--
-- Data for Name: logintable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logintable (logintablekey, username, personkey, userpassword, datelastchanged) FROM stdin;
1	TCurry	201	$2a$08$tJGFY7hPd228eTE8OGQnveIvthBPDMnkeIfx3e4yGw224HwdfVXJG	2017-09-14
2	DLivingston	202	$2a$08$brZo.Jh.neAH3W8/GYFXRemRrN85d1Touf4qO0YynOTyu3v5GqS5C	2017-08-19
3	HTyler	203	$2a$08$ZZQ6.pbI1wdPfDNSlAfPieA6Auzir.V9jBf4McqJNdT0XeTJXkewK	2018-04-17
4	VPayne	204	$2a$08$kd46Iz.xjEODfnbkfvXS7.UolSu8OmC3EjPcPhZm45gzAqItTkgeG	2017-07-10
5	VJustice	205	$2a$08$HU65oVt7PjoESXApyZC7k.7tJCr9Gih5J.xzXs7/dwQ9FEhqE9D.e	2017-08-15
6	JSullivan	206	$2a$08$lfV0Z5NLeT7x1MjJ.Jv5webuWnPRN8tbpYFeAktZTIGtWg89qXaom	2018-08-10
7	FRiddle	207	$2a$08$883koegtbocBWRLcQHlyQ.wVS32h3joYuD5oin7d1NMdGVmjM25Ma	2018-11-24
8	HBeck	208	$2a$08$L9YBoATsnWuZZi4sdz7o6Od0MwiaSNDyR20YjxmeJ8IaU8Ei3Aj.q	2017-12-08
9	LHenry	209	$2a$08$tw.9BY8fQ9aUx4VN5YZjXOTxHorFjqRMYJeTgasT0D7jbovmw/ZWC	2018-11-10
10	KRoberson	210	$2a$08$R4pDIvJn05QOZn8CSPUf.uwnuAU4RHAKXazSUT3Po24D9X2o3YpWO	2018-11-06
11	GClark	211	$2a$08$7lePVjYYQhTqLXsLbQuRGeclD2nkT3wU1usPrNqSDrIzYeRiXN3yS	2018-09-27
12	ABryant	212	$2a$08$saDVWXfD6pOCWvWQLt8/1eYNG9ReuugrZDQQ0w02rZRpj4fUVj0pe	2018-07-01
13	SStafford	213	$2a$08$E/j8fC/bVrVlI.JAblgneOOC6DaH48kEZabpnjB44kHCgyKMriIDO	2018-10-30
14	BPratt	214	$2a$08$23HWWdmY8M6O5pa.5vdGR.AxNX2UaWdv9LpiJiaArf51nUZF80d/2	2017-06-25
15	KHuff	215	$2a$08$dnKKp0ZmkL3V9laf7W7wO.JztCDqZTaTVdgTdVdVUvo906X076F9.	2018-06-18
16	MMorgan	216	$2a$08$5zGuzW5RhMr3aynICIZSIea1OdOjM3nOQ8yIQoPiB/ao9vDZj4xvu	2018-12-22
17	HMcclain	217	$2a$08$QLX59.fNbWrDxMf8Sr5lau7qFr1zkpze2pxswGtSWmnteb4g6a/rO	2018-01-08
18	VBlackburn	218	$2a$08$8HKcLx.OsGkBdPQ.y0LS5e4OPwXTJNA4ud4CYSqfYdaP.3GUVZzOO	2019-04-20
19	LSmith	219	$2a$08$4myAgb/kL9iOlnBYwkE1U.lW0Hq3NdeLWLFe9l4Ul2fDCQszgENQe	2018-11-04
20	HCross	220	$2a$08$RX4tEpElHrTdZL1YKNh2COycDRpgCMGrv5cVQBgn2FIdO8q61oD76	2018-02-07
21	JIrwin	221	$2a$08$7uSjs.4TzfDWf6jQLEtQ6OpSKHQKgEGDzdHhMta5W41XTvxcnKVhq	2017-07-22
22	MKnapp	222	$2a$08$s1t0Zff5liGFyxhi9BHVEexq2ZZQB4HWXLEFW5B09PMjPfqaugsei	2019-01-19
23	BBanks	223	$2a$08$G7rY/fmTKAB2Y.QBJONY1.POLOQpe3H7lgkp5hqPMhWIGxQNsJ0RG	2017-11-25
24	XLove	224	$2a$08$1kEZm6Xte4Fd8sX1Go8jt.g7Fi7R4k7sDdFzmxDH7GRtLd977LfYC	2018-10-25
25	PBullock	225	$2a$08$B1nrZAxAImHqu2huiBxmCuXfOkdf1hakKsvLHgIoLitDjCwzBKOla	2019-05-27
26	SBright	226	$2a$08$j0mKewolmluqNc2T/vV3yOliPwF3sxwC8rjJLp8DJX2WXRGPcdqwu	2019-01-24
27	DCrane	227	$2a$08$XmXujKFl03qvoScezNCp6.sqKQgdTJrkcxhxDO665Tl9fGhEWJIYi	2018-02-07
28	DLevine	228	$2a$08$KZdhb38L0A5edXWiwIGSpe82sUplvpr37GuXcjHqzIwR8UWQRmb2C	2017-10-11
29	VWatts	229	$2a$08$uzI9.mEjBXhKpUJd8NTVPueY/MUnoY54iu1YBnCMfQXv3Vdx0N52.	2018-11-18
30	MChristian	230	$2a$08$pAON8hYAdtPRnyGftlH2RuSbhHfMfovxtblhrfzd5GMeqh2l7fTfK	2017-10-21
31	CCurtis	231	$2a$08$Qb8KtWiBmd08K/RMUi3IouXbHoAtZS.x7DpftppJhvrBCMN3XY3di	2019-01-29
32	VAlvarado	232	$2a$08$upqgGHV1kWrC/dIn7.YkF.Br8mH3RQ/B1/y4WCkxnlLpe7Ab4ZGAi	2017-11-03
33	SCollier	233	$2a$08$wCr010PVtq.4tmSIu4JUcu8N0UcUoJUF5DewVHaUWFG955l4mvc1.	2017-09-14
34	SCraft	234	$2a$08$49a74ZSyvNDGMe2oYAtTb..ZyrHb297cSAnEoZLplT48ONomC3.0a	2018-02-03
35	UFranco	235	$2a$08$4GVzf/iGgEIW53w4HViAeOdQfpb/d/UK6zzt0WL3GCC9Wk/66m.KW	2017-07-11
36	ESloan	236	$2a$08$cNVG936EsicLgQpxp7VHOuONAVnKYUG2gisH16JjmY/GaXyHC7hqW	2018-01-03
37	CCook	237	$2a$08$asbZNds2obGtqBgC3jG.7.4f2Q9EUwnvQK2w2fLCq8MkApXZPlfxi	2018-10-27
38	JConrad	238	$2a$08$BkprBnbLrW2WHMiPtT1fkebhx2.0tkDsqtQQwW66ZJVWjg2rS40Dm	2017-09-03
39	XWatts	239	$2a$08$Dhae0VbaNkRJhAJ/9OM3z.iDDV8D2To5XS7JpVfF.Og0LYElHDjHa	2018-06-01
40	TBrock	240	$2a$08$hGlic00pP5Qd3rH6Ghsm7.M9.ES59Y0FMa80E26EhDLB.eBPF6Txy	2018-03-14
41	KMayer	241	$2a$08$QcHB7CeQwl/YQJqtFKfHq.cvV3QgY2HU3ih3/WIpDs5vTKPTm0m3G	2018-09-29
42	DBecker	242	$2a$08$X/1t08M6WWByXpKkhBLVHOIK1Km4Zy73bFYxI.fTzVQAGyfnx8H1y	2018-08-29
43	PRichards	243	$2a$08$RTuyLtVVIgbuFDfSFNqil.tSTP6BqoynY6oAtNB9SADgrBKufGN9i	2019-01-02
44	SOlsen	244	$2a$08$us5AZA7BV.8nHdN5QoQnyOkV96bbrnFzZcho4aS6nZbp2P.wRV1CC	2019-02-15
45	HMason	245	$2a$08$0GscBRx2VaQfPDzB9FzKqOXxA3VAWX3jv0klkj6kZK0V.QcmDMQXO	2018-08-19
46	MSolomon	246	$2a$08$7MfGjJDA9xWDocAwhyOb3.7q01PKRgC7ltVcxpXyaQCqxDsC4ATDG	2018-12-03
47	EWhite	247	$2a$08$llWAG6D8ISDnjRRTdJwD8ueSxM7aoqRr9LyhZRB3UE7RPjdy3ViOu	2018-11-20
48	BCash	248	$2a$08$AfMltPzGrnjwI38p3jaH0uQq6Jje07JnIDfVxJi8q0XpdHlbddiaG	2018-06-17
49	JJustice	249	$2a$08$cMQ4CY0cSvc7NQf57XxK2OyKTArUwjBNoqFblie76TOQLlGFr4xyK	2017-11-01
50	ECarney	250	$2a$08$r8wHlBKhUOKsvK1QyVOEZezRMu6gE3CpqnEcEjdcmnz1H..v0bKR6	2019-03-17
51	IHeath	251	$2a$08$pFOm3wdG8iyr5AaTTQRfXObV.FsxjdKqjjqJsPMMCIw23O3xbcOG.	2018-05-22
52	QBest	252	$2a$08$DTtgpQ/RA3zPREEnPz6Dvemaodcy7QcQN.f/H4uY9T0u35Eoz0sQG	2019-06-08
53	XHouston	253	$2a$08$rF4OkKUyok6vCyJGrI9U3uMNJb434fx3w82G3ftXFBYCDzRhs0lEC	2018-12-31
54	GAlvarez	254	$2a$08$TB/xhA5ZfkPNdchKwVDKsOZMYHH5zsKjlehs77O2pe9zdwWNaB7Aq	2017-08-27
55	LGuerrero	255	$2a$08$s40W13osR8xXcE4IAMaYuO/pvfmYOM53.RkRXgNBG8m0pJzkzAshi	2018-02-10
56	ZAllison	256	$2a$08$bYe6gNPF9i3uoq7WUo2zcuaCz41rJuuDkj6qlVaxPqGrg98zhV4yi	2018-06-04
57	BMason	257	$2a$08$uqu87sAx4lUicAHEW1DAeujdEc9WDw8n5Be/CE4FHAemAw/DDIJAK	2018-06-22
58	GGlenn	258	$2a$08$niuDkkqhUD3hB8IUXHbF2e1VXwqwidZ/xDASSCgCDZPYgvqR4g7ea	2019-01-03
59	LCarrillo	259	$2a$08$pHSXRgqtRNBImuM7/E/YFOyGTS2H6XszZXJrtWLVNURNBHOG7cV.i	2018-02-11
60	LLee	260	$2a$08$QTqBLEWU1c8ru4SLijAhKeLQwh5rqCHJuVb.8/jw.1SgCcxfLIBRK	2017-08-04
61	CAnderson	261	$2a$08$aUddQxf.GtnQ2VJaBrVkiem5pX6iEzONQDp206brp7kzMPY98UtB.	2018-07-16
62	MRoberson	262	$2a$08$9chardZG7040r8HSA3JfPu2BVzWhCyO8gRvbZnOpOYVp4vyNqfRWe	2018-03-09
63	SSantana	263	$2a$08$ENv/c/lmtyKql0g995ivvukQ.7k4Je8lfsdgPyTIRCHml4DeqgpTS	2019-02-10
64	EKoch	264	$2a$08$FF2JCc9kOGVDC5rWoaLzGO9qVsCmUs/6h9zyD0xDtFIiGHD9Hjxj.	2018-11-25
65	ABruce	265	$2a$08$J3ZU88yPXKq0fQCnCEmAqegNBajAc/aL0EixurG2sP/QpfY7RQrMe	2018-09-15
66	ISimmons	266	$2a$08$IyTrRsPZVylykmNqcTA4Qe6YIPxx.awyqu05YwAGJuhW4hg3WPeWO	2019-03-22
67	LVelazquez	267	$2a$08$Zv3q30hHwXaeqY3OpIX4TuE/i1ZqTlrQ1F0BgkzMjoGgcQkJGo9t.	2018-09-27
68	PFrank	268	$2a$08$PkxYrgcAoxqNIKkxXRnP2ePhEnMxRuBqQghi/ATe8m3/bIj0clM7W	2018-10-12
69	BMacias	269	$2a$08$8GuGyqV7Pqs6R6bAgX2t.OdzEOQcgXfZM7bp.tbsCBErX5lYCVFF2	2017-10-15
70	HPorter	270	$2a$08$r72fwlYbjtcbHtOi4aCZYuCmR9us7O1BojgfwebNdhspm/JPxYVnm	2018-01-14
71	JCastro	271	$2a$08$hxkkfVb5FfOJuEtFBlkSl.MT0S8z9eRVsxWIxLHTzxkeBrKiJunbW	2018-11-11
72	NWilliam	272	$2a$08$.NCsVdLupm6cLlTvhhHi/.LH2bpFS7guuGkR.FxDBYlspHTPObb1m	2017-06-25
73	GWilliamson	273	$2a$08$JZwy3SFdf8M5G48YFJsPLO0/bxhg4dJTIzxDq.8rZwr6b0lUb/Er2	2018-03-30
74	NHolland	274	$2a$08$esiWZnXKBbl.rQSeA/uYSu9IGb/YkQuM.vIxOCUf27Gqt60OL349a	2017-06-18
75	APierce	275	$2a$08$x/1NZTQDF6/PHyjE36rBtuI/A2UGA4PpqOqVY0dIMpNuNqQ.oYOyq	2018-03-02
76	CMcdaniel	276	$2a$08$XESQfHva63Fqselea6oblOH42KBsKC2CqxKuS1Kx5zlVM5kt7TU8a	2018-05-31
77	AZamora	277	$2a$08$stYf321fdXZ0OpVTK470NurcYF7yj0KkfE6iAfcqXIQqr4vQHCRBG	2018-10-30
78	CBritt	278	$2a$08$lAyS4WrrGNYcOjldLDKWQevb6RoREccQmLC3rSIeJ6ai7aQARMYBS	2018-10-11
79	OChaney	279	$2a$08$iUF8wpzlIP/PIjDTvYv2Kufv7bp8JTLM8H558qjhm0DD4TyMMvSly	2017-12-19
80	WPeck	280	$2a$08$SxBklKdyMgmCYqbn.BTNZOXMWZz/F3ZTZ8P0p0P.2F/EWqEJulIIG	2019-05-06
81	LKaufman	281	$2a$08$h4Mt0HiST/qYS36.GutOm.Cn.aM1MrbHzBGTollmSjZqB9sK1Ekea	2017-09-30
82	DNguyen	282	$2a$08$R0go1ifHwDWBHKrExyvvFOI6hVLtOvljbPm6R/Sva/Kd5jUBMZQcW	2018-10-07
83	SDonaldson	283	$2a$08$DruSOoz1wIxA7cZ8uW3RLO/M22CqC0bORctd8VfX460UElENN7wYa	2017-10-02
84	OGreer	284	$2a$08$lCGM8bKynHTIbEkcnYtYNOeo8Ips1SlPVIl.bO5axDhTNopd111s6	2019-02-27
85	CRowe	285	$2a$08$no9WzUz.gHkxDZlKC3ZCUOrbPkak18tPiXjM9.4Bce3rk/5BG5O5K	2017-11-23
86	YWhite	286	$2a$08$6mFaCdCmI2CSP5OkuuDMne0XoSxS/WwxTe8yyFWCUz4/G3i0wEzi6	2018-03-20
87	RNavarro	287	$2a$08$lwUYzy0NoUv6u1xdNgCPpOIPCOLjM85hpSexT1Z3qjH0.WN4Tx82W	2019-02-09
88	DMcconnell	288	$2a$08$NKQzUOimMYJkoBjoJvIbZe4yCOCZttnI29yERzYBx2DPUMYNGp5d.	2018-07-25
89	LAnderson	289	$2a$08$fX7E5W8VmQ3onb//PHtI4uWWT36mUFsRiQcxt1FHLpz.8feLlbtYe	2018-03-29
90	SHowell	290	$2a$08$GZJlIhLRBcnxiaCzpRM90e5GpS8LPAxYoN/1JRMcHJ7YyzwBsdWPq	2019-01-11
91	JDixon	291	$2a$08$ya43stKjXEBITXW/XHdWR.U9OzRIcbo8zOf6dInqs31AhMtwW4ANC	2017-10-02
92	ZTyler	292	$2a$08$y/ow67L4qwQ60ApD9CIib.r1hoapEwmxVZ1ziZwo.HzLHtrwTLAIu	2018-03-20
93	AKnowles	293	$2a$08$EhqJ5Uq2yAcvvOCKBh5hWOQgUhFteiagrUcOu3iAaSUrV1R96k8PW	2018-05-24
94	EFranklin	294	$2a$08$V0b6xdvLHa8kWjhuf7c2meq3ZCPu/fBY7MTByPQggyDBhFYoYfy2C	2019-03-30
95	WTanner	295	$2a$08$w0e996.Jxuyiuf8O2S08sOOWSMZuBChC1UIXqHJZ4Yt02eGEK7Ewy	2018-07-15
96	AMartin	296	$2a$08$DUNmQcd7Km53cUUpvGedM.STJzSuTHnTgBZOQLETPIpchcyMXPvga	2018-09-29
97	MMclean	297	$2a$08$pL.S1sQ5Ph6liwBHFGUgx.3v3InK8fVAxIk.f78g2v6xcgFONn5Aa	2017-08-11
98	FAllen	298	$2a$08$zM5llR3ZtazKoP5waz4mZOfaeypUxIcBEVqq6G/oD9Qz72K.04nAi	2018-07-28
99	AMurphy	299	$2a$08$mMFnWIz813JSwwgIcALIFuxNVB59DL6/UyZBZS5JuOoojaYbYVadu	2017-12-08
100	DDiaz	300	$2a$08$Fqlc.fHQLg78H/opEi4Spu5ub1ywBuzaG9OnavvKRRQb//SOpf.vO	2017-11-06
101	SFields	301	$2a$08$YcN9cDrfDJHwfX03vtIKF..uDJlWHiWMld0WCFUItYXITyIAmie5i	2019-04-21
102	LHolt	302	$2a$08$A2WFjHVV0Pp3n2VxLLBtd.Fu1rkqSlvsn.RiDVjlU19UPlf48jtyq	2019-03-13
103	BTyson	303	$2a$08$o1.kiCLcePYqI2oW9C9Yt.zxv1Sg9OqgNqXFzIjcHaEzJOY9LJS3K	2018-08-14
104	XManning	304	$2a$08$MgN7.GvtWFQ46CDjfyUU1OAZnk5qfE1Iks5NZOAmeRxav9BP6KWea	2017-10-13
105	YMorton	305	$2a$08$OFmu9hPCjxih2SWbp1JNRuBU3ivVnKEnggbCEVeHP1LbWjwpSv29i	2018-05-25
106	HCarey	306	$2a$08$Tnlcbxu4eXAfBF3z4SRC4OxxUlCygjpOwEZREIahxQJI3/lZyiYO.	2019-03-26
107	MHendricks	307	$2a$08$9yVMWTIDRZi6aBKKxHJ8GuBQ6.NbkngXfotVGKXN.5qRYWa/YMmHm	2018-03-10
108	ACalderon	308	$2a$08$Kf/QmguCjKZL/c6pCxuR6O/eTq1uuJDDvE/XFnneWArE7l17VPZ22	2017-06-17
109	YKnox	309	$2a$08$7UbqrkDXJbwKfrrig7d17.efcJso5faNN/mK4AvQ0wBAn7OXVKhK2	2018-11-20
110	JKennedy	310	$2a$08$kNh/bUBwg/tV648lkOXAT.ygLcQUNc.NEnV4X7B24VqGd1SO2eJ/2	2018-04-26
111	EHebert	311	$2a$08$SUAEZcSZkiPjW4ryx.I63.493NIk009LATKHPvnL/yjBux3OM1BMS	2019-06-08
112	AKnox	312	$2a$08$d3aTGAfdoMgafRYjFXD20e7TnSJetG9Hykh5Tv92/dM74ReIVPM1G	2018-04-08
113	KTaylor	313	$2a$08$QeK3.9tYQ3I34S8LZR9Rh.BUBGU2hAQDOJrx2wuOyHWZbxEwaiY0i	2019-04-04
114	PRatliff	314	$2a$08$LJfOOQS7RFpIiSjWFGsFfulJtGp5ovRaXEQUd/HD9Ke/Pq5u8Hj9e	2018-03-25
115	UOneill	315	$2a$08$UHadzI6KdFJ1b5.SF/3Q9OGKoYHISG7sSQuOR5bEBgXQCXh.9N5U.	2017-10-26
116	LSummers	316	$2a$08$oM.xKzrGj3bTSr34/zv6mezKwL6bcXreNhp0o.Zmh6.5gKY4WTlTa	2019-05-30
117	IBolton	317	$2a$08$qrA4a2S17K9fHmO7Mb2eTuKrrwCWN.z047wYHv9P.KqSyAArr.cCe	2017-11-16
118	XStanton	318	$2a$08$27IF3zylEf0fRw1fHGTxPuylVZq8nUYvPxIXI2wTDUxozx8N7k/8K	2018-02-12
119	LClemons	319	$2a$08$3CZVJ4cj/TUKWnsAxnFJ3OAI.FGGpcFMKN/iltUbOUJF1FHb2xA7e	2018-03-07
120	CRose	320	$2a$08$K0XgGFdQ4iAzDye2.3AB2eXkjRJ3850gmlZ.Egj7jCzxndv9b00Li	2018-01-29
121	NBlack	321	$2a$08$xYNLsNHXMbkRiuZ1bOdxt.xxzN2e/UAg7rGdqbpJCGtLsmGklK8Za	2019-06-08
122	MMullen	322	$2a$08$XR/3V9LTI8s8pHPepf3f.epZdcwk.1mD6TR47EGK/88WCrO7Wpp8q	2017-09-11
123	LHaynes	323	$2a$08$mYuRNbQ57B2C0Q/s84/OGO2Jbq/agXbyafKppvMly2X5KZZnsQte.	2018-07-28
124	DStrickland	324	$2a$08$NVeHgg2J7UyUMM.ZJ.q3cOU1O.u6l/iAej9vu6Vp2OkPnUV/Jf9qe	2018-04-01
125	DWarren	325	$2a$08$hCo7u/r.NPvH4Q/SA7UOK.n1PM31WG3Wma0kBp.ZT08RaYYgxFM/q	2019-03-13
126	EKnowles	326	$2a$08$k.dWNcm2YCwfC3HUpkdK/.7f70VNVKGNi4Y0UJqOgCZSBv9iU..wG	2017-11-03
127	BCain	327	$2a$08$nqBh5yUimRZ4V6ZUv51pK.eEj5q/n3AT6zo21ed6qJtb6aKWKk5l2	2019-04-12
128	NCobb	328	$2a$08$NBkIAQMQIdCns2FdEZEuL.jrRh48O8rdYJB8AJnH/ec3OkXABVkZG	2018-04-07
129	ARichardson	329	$2a$08$rEiBxTcjFXz/IbbpjGAgXOAye/VdU7N/tebPMMjnLngIAHxLS343O	2018-12-21
130	KNash	330	$2a$08$KzjzYr7k42WBR8d3sa0r0uC9O1UH1lVHho94TltjyFPcY1Lp2tW6u	2018-03-16
131	PWyatt	331	$2a$08$r1FqnXns6GKW.cMKlyKIb.MrZuO2gVJ3KPrPejBVHFDlDanxpPJIK	2017-10-06
132	EHudson	332	$2a$08$TMUp/9lZtvrlL3trgjmAIejPqqPM3F/x7J2CuLPbq93/nIE7se3FS	2017-12-26
133	TWaters	333	$2a$08$ZMiZYSbkQ7bBnZs6TZQoVeOvOFUp5M1OZmNy0FVpdEmc3xcmyDvdy	2019-02-06
134	GChandler	334	$2a$08$y/7jTxrhAHDtPOB/fIILB.PzOvq/8v6go.RXHXXeVr1h1dY6dex72	2018-12-30
135	TRosales	335	$2a$08$QW6a8uw.7RkK7rKI3.CQn.OLOnq2myr2KWXz7Vqw9eXHdyo2ae47W	2018-01-12
136	CPetty	336	$2a$08$Gg6CRJ9fk/gdnqgVs2/3zuL1M78dR9Ift0JKO8MME15oCpqRSTrwq	2017-08-08
137	UCraft	337	$2a$08$krsPHdpBvD3hu6q7nBE.POR1aqCc2ZcChtOp1YwrJCax.3OxcDj2y	2018-11-23
138	JFlowers	338	$2a$08$U.U87sn/Ikm/hLiyeA/MouGUD4zRQy0QqZyBFA8bQAYhTM0snTmE6	2019-03-12
139	JMcconnell	339	$2a$08$5SqY.D0/128foeJbXlbGPuEdyIGmYdgiXjzoj17SeRAv7PjCMIEP6	2018-10-19
140	ASlater	340	$2a$08$e23ZPcUAY5j.KBvcj1DvhOk.cGC8IiIurF9lzV2xYDesuPFqjQZH.	2018-02-15
141	AWatts	341	$2a$08$U3HX3xY7l7tyNaj0l7.Ik.iuHVOeqoQcX2HpkwqyvJOyd6hLhtZzm	2018-07-25
142	ABaldwin	342	$2a$08$rWm/s7uFfzQdaT.ukl0fw.e3uS9o47ULurFZ0F5nxlW1SV9.eswJy	2017-10-08
143	AReid	343	$2a$08$2Xvp/liyxSDQ0Zkh.EQ7w.jOrdTmBby7dTMxgjNXMZRm82I.wEi9y	2019-03-07
144	HFry	344	$2a$08$MNLbKAM.lAJAjXdB1/1ag.YNX8cCLorhK53bwlWSPIraEh43VNSei	2017-07-12
145	KGarza	345	$2a$08$TVcq8JaOci.UGciTamLJkeWRGsW2ety5xQlv70dn5siDYM5SFP//S	2017-08-10
146	MNielsen	346	$2a$08$HZ4DV3Hpvy5N/UdeDhwuuu9nLjMXACe70oj/Bt7rFeC/S/LzXJ572	2017-09-04
147	MBryan	347	$2a$08$zzDy2tGIwuZj7lmHHwqB3Ol39Qf/ulT1oabLAObKCG.xgMAQXfxpC	2018-07-04
148	FLarsen	348	$2a$08$6WrRLYxBcct9grQOD2l29u3RY8jJ2TA.P63o5NcLARlh5giGHKoH2	2018-09-18
149	HMoore	349	$2a$08$SnGVknUz/C8L91CrgdgaPuPBaTMRbij0w4RKdh1cO5XmRFupfAZ8G	2018-08-04
150	HAndrews	350	$2a$08$XD8J0Zo4CtGaAwF3FDuj9.3Yo.Zw6rhT05RKE5h8k/kAB2vsoiS0y	2018-08-13
151	VMckee	351	$2a$08$V8swvjplivsgKN9C29Telucpl6x5t2zCiPGXPST3LvG8tgtg0keaG	2017-08-04
152	OLeblanc	352	$2a$08$GB6Gnj5GGvob7w6bsP4MROpTTcrttRhf.7kHCIYGxLOc80Sd.KMJ6	2017-07-22
153	PGolden	353	$2a$08$R/Hx2OqwE3yAyUjepQ9EneRO03KS.fcYJmaO4yq04Lj25LF8qML9y	2018-12-14
154	HLyons	354	$2a$08$DhgC2GJ87rNPr8twuIkLmefZETvvS04jyN92obo6wDSIOd4EG.39i	2017-07-01
155	MSolomon	355	$2a$08$dgJTHkm5EsB/Qk1PiDhS5OpW8dix0T9K.suBfskl57JAi6yVzmqrq	2018-01-05
156	CPuckett	356	$2a$08$msAlpIWMPV8IdSilDHDdXewJOClinYOFLSkcyCgjkRPMkcALct4lC	2018-02-15
157	OBullock	357	$2a$08$8dGefaHz6PgOJI3Ma9dgIO0nYTlrTfTRcUvPN0oE00wHLRQd93Ehu	2019-05-15
158	VDejesus	358	$2a$08$1OuVKBtMZSohXsWSzaQRVuX9CoU46qNeOz9LoYLpx0aHVeouJeiUC	2018-10-22
159	IDaugherty	359	$2a$08$Y2aGS2OjsTN8q3Efsdqt9eDy/dWK9RQ850y0lNp/t9n1/vAKyz5QC	2018-04-08
160	HHowell	360	$2a$08$c3Om98lNGlk2Gl3LxZBe3u9UGU6grpbZeEAkH7kb3KybXUwJ1BUd6	2019-05-21
161	ULester	361	$2a$08$H7o6f/Gx/FMXf1d0ZubtxutEFzULL70rd24lQqsWFxIIIPtAQw4zi	2017-12-11
162	ABrennan	362	$2a$08$d72bfJTEK4YBo9R7Y/Ye3em72PJhswJD5/L/K5UHwvYIF9wAIQxx.	2018-10-25
163	ZBeasley	363	$2a$08$PwtJuD5FeD7gpaGhc/FW.uGhihAB/ZLIwnh8fvE4yIDgwDZdtrVuC	2018-01-17
164	CDrake	364	$2a$08$Inh6LWnR7FMycDu2dXsXpe2EOSXBtS7uD7G7kS4O7YLCLdDRn4fFK	2018-10-09
165	WStafford	365	$2a$08$eyQlYYFOqRbXR1hzNW5jDezxdqAEDP.nz8Hd7PUzF0dzch70oLoNK	2019-05-12
166	LRyan	366	$2a$08$zF2aEKu45gq2QVCNxR.u5.U9vDRtWlo4GVm5dY6FZk5BNiSkZM2WC	2019-03-05
167	SDickson	367	$2a$08$ZGdVvi5eSI9y60eMPpl1pOKkeoQ3nHRJALPb6B//tPFzDUe98Ci/K	2017-09-04
168	KGoodman	368	$2a$08$Lc9FmCXOwJkfki8A8lswRuRXE9Aw939piHushuMToqrKoKdf/.vEi	2018-11-19
169	KBall	369	$2a$08$BrMCJUxKKjEY.MAWtMbSReHsyw3OGfcKvv/TW8xhx/m4PI6Xz2Iw.	2018-05-05
170	NTucker	370	$2a$08$SFviOHiHm4ektKKhPx92vuswLOscGOBMKXxvsaKLA2uMFRin0cqgi	2017-10-06
171	AVega	371	$2a$08$bzEr3Pj0uslS6EWw0mCphOnUTFGS6FzT75HUZcYe7ng65P62Uo35m	2017-07-27
172	ERowland	372	$2a$08$HFlxGAKZ32ZWSZOPiQn.a.0dMWgFw2U3G42LpJ8n8kRT7KlI/W5lW	2019-04-21
173	MKemp	373	$2a$08$.hyDXfPH4Ep9F.5JT5.W0uuitcOV3Swkwt9uH1HVTNlQ0yqM5FwhO	2018-09-18
174	ALindsey	374	$2a$08$u.51UwIAVK8BuhdaxqsUW.mulQCqAOwNO0T4eYvzW3a2Nd9sxFGu2	2018-12-02
175	HVazquez	375	$2a$08$rs/RMbP/x1fKrQme.Nmvne6hdzHt7NkXVIzxJPS8/e.D7ysqSpEWG	2018-08-28
176	KPetersen	376	$2a$08$shCeCCWm5OANuRqCUvgCxuW9krulm1OEDMIZsO2nIOKHJ8d6bzEQ2	2018-05-10
177	TPaul	377	$2a$08$QK5bhHNd9YpAyoHz49PodefphvlzcChmzt0qYfv5dkMRwTed/vVeG	2018-12-06
178	HHeath	378	$2a$08$jNACpgN8OagaEzDdCeEy2.CQajUlgCcuiDkSkpU1YoZlve4CRLhr6	2018-11-27
179	AHull	379	$2a$08$A57rztkTWPae2X.dkkPvXO9RcvVT8RUa4FUfIUciMKYKs79ZTyHpe	2018-07-24
180	SWallace	380	$2a$08$K7uFVht9utsvTgl.TBRZjOjqk/ZCgA.fe6EzXnXdJ24L7U5h5Hq.G	2017-10-26
181	MWatson	381	$2a$08$0EILIt0C65eyAvoOhTeIsuZsmxmR3d4fzypj5JEbwhrR75o9u/8YW	2018-09-16
182	BKeith	382	$2a$08$j1UvPuiPuxY/JLPgf0FQJuIR101Qn90CwCOGMrIGtHRjRcrlIcdh2	2018-10-01
183	CPowers	383	$2a$08$iy/1RgZLuPfkvj1xoGeXi.8WLn0VP7dbqrP1gtF1VfK17DtzOHmka	2017-08-22
184	TWiggins	384	$2a$08$ac/qrAa1fkd1DMW0/tMrNe4Po.QCswJWDIvgMVKfqYy//Cvgx6JBe	2019-02-27
185	CStevenson	385	$2a$08$h6D9/Rc3j2N7IgfEQzPVJ.zLLvciuJe2Mhe.ahxAPcO97ATC0YRHi	2018-12-31
186	CWilliamson	386	$2a$08$2pt5Or6DGHcyPFtm.WI00uyC30WK/g7Lss6/da6kFgasINwxHX3M6	2017-07-02
187	CMorton	387	$2a$08$JKr3vincNrv3P6zWy1czHeKbyl6CfWiNib7LosjXpXY2BxF8jnega	2017-09-12
188	ARay	388	$2a$08$QSempvPWEwG5jmtD9NIxx.4QGFcWt7RBq4TtFLTP7wGpPQfk28/Du	2017-09-11
189	WCasey	389	$2a$08$u9m94pmHuRvy8ucmIjS4w.QLS4ucSNviz2XjF9JCh4l6K1rvwMTm.	2018-06-29
190	LWhite	390	$2a$08$IBVXsQq4jlcKJK7Jqje.4OCGF4Dq4mEBnYL24V.fCv3dt7i6WZkCO	2018-04-08
191	RObrien	391	$2a$08$w4MGUvb0/Y1peSUkw7fvL.k13Dk6NhM7PeeiTli2tFS41MeqjsfeO	2018-02-21
192	REspinoza	392	$2a$08$iYl/ZMoDAI80Fbt9zr7HGOoyH0Rh9Qu9ABluUtt3K6r4oU8mPEBOq	2018-12-31
193	CNoble	393	$2a$08$F4tKO4jmzpQJMq3KufU7lulEswbSmVccyZ1GHqWQkY.z6yhqRygm2	2017-12-01
194	TBanks	394	$2a$08$Pp0tGqUKR2MDRsBTFyiw5ul1ye5vKzx2B85kzdPE4VymlI3deWoJi	2018-10-20
195	MGonzalez	395	$2a$08$R64azMZ5WnokoSOIQXoFGerU/gDbjwWPDKmkSVbOL6uqjyAM0.Esa	2018-02-02
196	WPadilla	396	$2a$08$7zoXuKvmCI87I/ji6KfTKOEARpc33YFzGXqmzsWJJV1ovWUe.HcOG	2017-07-07
197	UBender	397	$2a$08$/xqFkLPb3EH7VvLcT0HVz.goM6T4cStBPXAl8hFEjR3rIHzklENby	2018-10-20
198	CDunlap	398	$2a$08$gAGDvz.sFaO7S6db.8F9AedIq9wMN7tF7zbjOhOcdNT4tEe7LX/TG	2017-08-16
199	BHowe	399	$2a$08$4X/.76ZR0o2ssDtJXrGzPOZE6JeNE5pYdmbyL1Kz50kEk0zXYKOYW	2017-06-30
200	FSkinner	400	$2a$08$9c/4FfBiVUiXwqCtZoCsZuUp7gyIWQOvi5V848pmGzA8inDImD8n.	2017-07-07
201	SJefferson	1	$2a$08$ICLCJx.H9V34M4nXBOrXiOlHe2bFZFsQx6YyTd94Obd6PqB7T5UDO	2017-01-15
202	MLarson	2	$2a$08$PgpmPxu4zopIHhG/7J0PoOIRWefYA0iqX.3UI1XqDdLyuyW5oxjDy	2017-01-15
203	LCarney	3	$2a$08$jD0stngSC99YIRR26GntXOQQS0gd.MLOAVvgvfbezCPVbehAfxj4e	2017-01-15
204	LMasters	4	$2a$08$UBrkj/7PZGbPFJaYqT5Yc.AVFPQFxQ996mG7IiuFyG8HJdTikii8y	2017-01-15
205	MBrown	5	$2a$08$dyx/J.MUvJ9dSdlfM6cKiejaa4765XHNB6PmngpTbC/O7ITZkEtwK	2017-01-20
206	DCernoff	6	$2a$08$8jFPGOBo477UlMkkEdlnvOh7OYqofDuwV.i.PvPTcQ7L7EoIekySW	2017-01-20
207	AMoon	7	$2a$08$diA.QDNnxjihtN.VkRijPO485UFU73FkIKN.EGSJ7U92DKiBW3dn6	2017-01-25
208	TSmith	8	$2a$08$4uE1wVFNzqMwD48cNrrTd.Um0O0q8/woJXEMuwpmUVo5n6TbTGzMy	2017-02-05
209	BKell	9	$2a$08$h.Chy8QzmcIGYFfaaA6l0uoWj7HF2ZRHTDUrokMu.1FnC1JjzNN1u	2017-02-08
210	CRoberts	10	$2a$08$yRPFMmQe7UGed9WZwOSZAeVPfM5WHdty92J.5GRUWT60/p3zDxF0.	2017-02-15
211	MNelson	11	$2a$08$.Tk0FWkt0reMYDiT9Wd6reVo35ulPMr9fymd83iAZLLKTcy1TP0PC	2017-02-17
212	SHon	12	$2a$08$LHHKuNC.1IFf8D6KO6SD7ONLyu/GpYtyzzyuPAZGRKMy9QEs.9Jm.	2017-02-21
213	MJones	401	$2a$08$RO5LqJd1/csADGDzIqnzXupUKbbdtERCrsMQ4PsJ1IPiEZi.L2fVO	2018-01-20
214	CSanders	402	$2a$08$EtTsNW54l4/F/Sc3QuMGDulLRmyr3IQcOJoz2yUMs4J1AUH73BkAy	2018-01-20
218	SJames	413	$2a$08$Sb.DoNjhSapKQEoYiLuAvOhT9rxeEYJ8j5gpUNvJUgnadYs5XvTru	2019-03-07
219	SSpring	414	$2a$08$kE2ZnC9xR/lyAd2ZQZx.reit55DY3aFWgyL0kHGk55.i8XOSjVALS	2019-03-07
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (personkey, lastname, firstname, email, address, city, state, postalcode, phone, dateadded, newsletter) FROM stdin;
201	Curry	Thaddeus	nec.luctus.felis@lobortisquama.co.uk	7186 Aliquet Street	Columbia	MO	87750	(482) 461-4908	2017-09-14	t
202	Livingston	Debra	mauris@augueeutellus.edu	469-2541 Semper, Rd.	Joliet	IL	79613	(235) 499-5733	2017-08-19	t
203	Tyler	Heidi	gravida.Aliquam@loremacrisus.net	Ap #200-3584 Amet Street	Overland Park	KS	41926	(778) 851-8853	2018-04-17	t
204	Payne	Veronica	nisl.sem.consequat@Aliquamtincidunt.co.uk	P.O. Box 728, 7878 Cum Avenue	Stamford	CT	85676	(335) 280-1472	2017-07-10	t
205	Justice	Vivien	erat.volutpat@odioAliquam.org	P.O. Box 279, 5442 Mauris St.	Owensboro	KY	98838	(308) 644-3540	2017-08-15	t
206	Sullivan	Jennifer	eu.enim.Etiam@auctorvitae.edu	420-2067 Urna. Rd.	Auburn	ME	12116	(353) 448-8971	2018-08-10	t
207	Riddle	Fuller	Aenean@famesacturpis.co.uk	4972 Vestibulum, Av.	Green Bay	WI	39813	(275) 135-5620	2018-11-24	t
208	Beck	Harper	hendrerit@sapien.com	P.O. Box 749, 4797 Interdum. Av.	Sioux City	IA	89411	(651) 563-2145	2017-12-08	t
209	Henry	Laith	elementum@felis.com	838-6731 Proin Rd.	New Haven	CT	55575	(380) 826-1434	2018-11-10	t
210	Roberson	Kane	tristique.senectus.et@Integer.com	P.O. Box 980, 4507 Lobortis Rd.	Tallahassee	FL	19676	(894) 713-4106	2018-11-06	t
211	Clark	Geraldine	tempor@molestie.com	4359 Malesuada Av.	Newark	DE	18343	(237) 184-0486	2018-09-27	t
212	Bryant	Anthony	facilisis@nisidictumaugue.co.uk	P.O. Box 165, 6185 Proin Rd.	Kaneohe	HI	50705	(581) 620-9594	2018-07-01	t
213	Stafford	Samson	conubia.nostra@Nullamvitae.net	6771 Purus, Av.	Billings	MT	26095	(430) 793-5124	2018-10-30	t
214	Pratt	Brenna	orci.luctus.et@sedconsequatauctor.co.uk	P.O. Box 340, 2345 Orci, Street	Bridgeport	CT	14720	(379) 839-4430	2017-06-25	t
215	Huff	Kirestin	id.ante.dictum@netusetmalesuada.co.uk	P.O. Box 918, 2070 Maecenas Av.	Butte	MT	89463	(564) 345-5631	2018-06-18	t
216	Morgan	Maite	magna.a@loremut.com	Ap #922-4188 Ut Rd.	Lincoln	NE	67070	(656) 240-6504	2018-12-22	t
217	Mcclain	Hadley	Quisque@nisiaodio.net	Ap #812-4012 Sed Road	Clarksville	TN	93234	(941) 336-0869	2018-01-08	t
218	Blackburn	Vera	diam.Duis.mi@nullavulputate.ca	4253 Eget Rd.	Lincoln	NE	12442	(280) 476-9824	2019-04-20	t
219	Smith	Luke	aliquet.odio.Etiam@sapienCrasdolor.com	1693 Tincidunt. Road	Olathe	KS	96892	(226) 286-2606	2018-11-04	t
220	Cross	Hollee	nec.mauris@ornare.ca	Ap #137-2013 Molestie Av.	Mesa	AZ	86442	(972) 134-0583	2018-02-07	t
221	Irwin	Jane	erat.eget.ipsum@Suspendisseseddolor.org	743-4122 Eu St.	Tampa	FL	94931	(438) 635-0071	2017-07-22	t
222	Knapp	Margaret	hymenaeos@egestas.ca	Ap #881-5482 Condimentum Road	Kansas City	KS	81681	(774) 157-2935	2019-01-19	t
223	Banks	Brynne	nonummy.Fusce@nisi.com	2312 Felis Street	Saint Paul	MN	77970	(372) 294-6964	2017-11-25	t
224	Love	Xantha	condimentum@rhoncusidmollis.co.uk	5393 Cursus, Ave	Jonesboro	AR	71472	(199) 585-5153	2018-10-25	t
225	Bullock	Porter	mollis.Duis@mauris.co.uk	190-1915 Dapibus Avenue	Wilmington	DE	77356	(376) 327-5210	2019-05-27	t
226	Bright	Shelly	dui.Cum@disparturient.com	Ap #201-1520 Non Street	Jonesboro	AR	71000	(615) 113-9490	2019-01-24	t
227	Crane	Donna	egestas.a.dui@mollisneccursus.org	231-4018 Sed Avenue	Shreveport	LA	14344	(445) 965-0172	2018-02-07	t
228	Levine	Dante	ac.libero.nec@libero.net	844 Scelerisque St.	South Bend	IN	72105	(253) 188-2571	2017-10-11	t
229	Watts	Valentine	et@lorem.net	P.O. Box 454, 8604 Velit Rd.	Henderson	NV	41898	(914) 710-2890	2018-11-18	t
230	Christian	Mari	morbi.tristique@duiquis.net	Ap #746-6499 Morbi Road	Little Rock	AR	71520	(361) 990-3102	2017-10-21	t
231	Curtis	Charde	Nulla.interdum@Morbi.org	8816 Lorem Rd.	Independence	MO	50463	(618) 170-9458	2019-01-29	t
232	Alvarado	Vielka	lectus.rutrum.urna@interdum.com	168-5707 Dolor. Ave	West Valley City	UT	99379	(646) 385-6730	2017-11-03	t
233	Collier	Steven	Sed.nulla@Donecfeugiat.org	866 Aliquet. St.	Lincoln	NE	98289	(178) 575-2951	2017-09-14	t
234	Craft	Scott	facilisis@eget.org	814 Nunc Street	Las Vegas	NV	25025	(703) 275-1784	2018-02-03	t
235	Franco	Unity	ligula.Nullam@vel.com	569-7792 Quam Rd.	Rochester	MN	11558	(406) 283-7429	2017-07-11	t
236	Sloan	Erasmus	eu.ligula.Aenean@vel.ca	Ap #209-258 Ipsum. Rd.	Huntsville	AL	35682	(462) 992-4201	2018-01-03	t
237	Cook	Constance	libero@dignissim.co.uk	114-543 Vulputate, Avenue	Owensboro	KY	28531	(463) 858-1858	2018-10-27	t
238	Conrad	Julian	libero@vehiculaet.co.uk	P.O. Box 462, 1738 Ultricies Rd.	Lafayette	LA	91491	(648) 262-5058	2017-09-03	t
239	Watts	Xyla	convallis.convallis@diam.com	Ap #804-7317 Enim, St.	Baton Rouge	LA	96790	(294) 122-4073	2018-06-01	t
240	Brock	TaShya	nisl@cursusInteger.org	424-9661 Magna St.	Norman	OK	80964	(667) 698-2815	2018-03-14	t
241	Mayer	Keely	mauris.sit@Integersemelit.edu	474 Integer Street	Eugene	OR	65107	(498) 912-0754	2018-09-29	t
242	Becker	David	magna.sed@Aliquam.edu	9647 Donec Avenue	Lansing	MI	12738	(191) 881-8186	2018-08-29	t
243	Richards	Preston	luctus@Duis.co.uk	6735 In Av.	Pittsburgh	PA	18783	(199) 239-1018	2019-01-02	t
244	Olsen	Sylvia	Integer.in.magna@Sedid.co.uk	P.O. Box 785, 8456 Nam Rd.	Columbia	MO	62262	(714) 800-3552	2019-02-15	t
245	Mason	Hyatt	ultrices.mauris@justonec.net	693-8469 Metus Rd.	Augusta	GA	30615	(441) 305-9404	2018-08-19	t
246	Solomon	Macy	varius.et@pedemalesuada.net	1476 Nam Road	Springfield	MO	40414	(589) 598-0781	2018-12-03	t
247	White	Elvis	eget.metus@purusgravidasagittis.edu	7368 Vel St.	Portland	ME	87020	(519) 905-6180	2018-11-20	t
248	Cash	Berk	amet@aodio.ca	6160 Vitae St.	Columbus	OH	92775	(638) 356-6238	2018-06-17	t
249	Justice	Jessica	magnis.dis@dictumeleifend.ca	Ap #639-6646 Semper Ave	North Las Vegas	NV	51803	(322) 516-3779	2017-11-01	t
250	Carney	Ebony	commodo@accumsaninterdumlibero.net	957-3277 Vel Street	Cleveland	OH	46120	(919) 484-3195	2019-03-17	t
251	Heath	Isabelle	senectus.et.netus@enimMaurisquis.net	Ap #793-6314 Leo, St.	South Burlington	VT	75512	(997) 436-7051	2018-05-22	t
252	Best	Quintessa	tortor@sit.ca	Ap #792-495 Metus Ave	Norman	OK	18666	(664) 934-5686	2019-06-08	t
253	Houston	Xenos	commodo.hendrerit@Sedmalesuada.net	P.O. Box 975, 406 Varius. Ave	Portland	OR	24169	(738) 824-0174	2018-12-31	t
254	Alvarez	Gray	eu.sem.Pellentesque@diamluctus.org	Ap #417-2732 Nonummy. Avenue	Evansville	IN	16051	(602) 723-0616	2017-08-27	t
255	Guerrero	Lucius	gravida.sagittis.Duis@odio.edu	739 Habitant Ave	Missoula	MT	63429	(506) 920-0032	2018-02-10	t
256	Allison	Zephr	Sed.molestie@fringillapurus.co.uk	167-2291 Tellus Ave	Pocatello	ID	66457	(863) 224-5794	2018-06-04	t
257	Mason	Beverly	nec.ante@neceleifendnon.net	P.O. Box 363, 685 Purus Road	Hartford	CT	55515	(675) 692-9799	2018-06-22	t
258	Glenn	Germaine	in.dolor@euplacerateget.ca	Ap #637-2969 Nisi St.	Memphis	TN	58157	(704) 541-8161	2019-01-03	t
259	Carrillo	Lenore	Aliquam.rutrum@nuncrisus.com	631-2164 Nullam Av.	Bellevue	NE	20187	(579) 944-8770	2018-02-11	t
260	Lee	Lee	rutrum@egestas.ca	6365 Dolor. Road	Broken Arrow	OK	54086	(475) 974-6007	2017-08-04	t
261	Anderson	Cedric	Curabitur.vel@Cras.co.uk	Ap #297-8990 Aliquam Rd.	Sioux City	IA	92980	(984) 429-4477	2018-07-16	t
262	Roberson	Marcia	et@tellus.org	181-9502 Enim St.	Huntsville	AL	36174	(828) 548-1650	2018-03-09	t
263	Santana	Steel	urna@mattis.net	698-6438 Aliquam Rd.	San Antonio	TX	67804	(198) 275-3254	2019-02-10	t
264	Koch	Emerson	sit.amet@consectetuermauris.co.uk	5537 Auctor St.	Montgomery	AL	36134	(660) 431-4614	2018-11-25	t
265	Bruce	Alexander	nunc.Quisque@Nam.net	Ap #520-3813 Lectus St.	Tulsa	OK	22769	(949) 449-8061	2018-09-15	t
266	Simmons	Ila	leo.elementum@Mauris.org	633-9020 Nec St.	Honolulu	HI	99773	(844) 328-9569	2019-03-22	t
267	Velazquez	Lance	Nullam.vitae.diam@In.edu	P.O. Box 766, 6502 Posuere Rd.	Richmond	VA	23795	(737) 280-4702	2018-09-27	t
268	Frank	Plato	sagittis@doloregestas.ca	P.O. Box 698, 1819 Aliquet Street	Chattanooga	TN	61725	(951) 716-5600	2018-10-12	t
269	Macias	Brynn	magna@eleifend.edu	P.O. Box 614, 3155 Nunc Road	New Orleans	LA	20593	(495) 743-2696	2017-10-15	t
270	Porter	Herman	risus@lacuspede.ca	9005 Blandit Road	Metairie	LA	50434	(937) 183-6126	2018-01-14	t
271	Castro	Jenette	auctor.velit.Aliquam@idenimCurabitur.org	2811 Iaculis Street	Minneapolis	MN	89709	(745) 830-6706	2018-11-11	t
272	William	Nicholas	nisl@risusquisdiam.co.uk	4458 Tempor St.	Salem	OR	98464	(793) 287-3892	2017-06-25	t
273	Williamson	Grace	Curabitur.massa.Vestibulum@parturientmontes.org	9741 Hendrerit Avenue	Fort Wayne	IN	91109	(224) 757-3551	2018-03-30	t
274	Holland	Nash	egestas.nunc@pede.com	P.O. Box 285, 2128 Ullamcorper, Road	Reno	NV	38061	(466) 560-4803	2017-06-18	t
275	Pierce	Arsenio	ligula.elit@purusaccumsan.com	903 Magna Street	Bangor	ME	32186	(319) 560-0221	2018-03-02	t
276	Mcdaniel	Connor	tempor@tempor.com	Ap #212-5254 Nostra, Avenue	Anchorage	AK	99771	(527) 886-1529	2018-05-31	t
277	Zamora	Aline	quis.arcu@lectusconvallisest.ca	P.O. Box 816, 2943 Non Ave	Toledo	OH	93965	(606) 913-0098	2018-10-30	t
278	Britt	Clark	arcu.et.pede@porttitorinterdum.ca	7974 Penatibus Rd.	Baton Rouge	LA	43551	(108) 512-3491	2018-10-11	t
279	Chaney	Odette	Pellentesque.tincidunt@Mauriseuturpis.ca	811-9498 Arcu. Ave	Gulfport	MS	83625	(165) 243-6217	2017-12-19	t
280	Peck	Wesley	malesuada.Integer.id@Nullam.edu	P.O. Box 744, 1113 Rutrum, Street	Casper	WY	82786	(985) 281-6071	2019-05-06	t
281	Kaufman	Lester	est.mauris@egestas.ca	7193 A, Avenue	Springdale	AR	72310	(950) 528-8343	2017-09-30	t
282	Nguyen	Donovan	ipsum@quis.edu	Ap #968-9376 Nibh. Avenue	Butte	MT	52279	(120) 268-8190	2018-10-07	t
283	Donaldson	Sade	Donec.at.arcu@tortornibh.org	Ap #728-7189 Lorem, Road	Little Rock	AR	71936	(247) 759-4923	2017-10-02	t
284	Greer	Oleg	auctor.velit@pedeac.net	Ap #963-1486 A Ave	Salt Lake City	UT	58847	(578) 772-4358	2019-02-27	t
285	Rowe	Chancellor	adipiscing@velitAliquamnisl.com	6279 Lorem Road	Lincoln	NE	65684	(883) 315-9038	2017-11-23	t
286	White	Yuri	at.augue.id@cursus.net	P.O. Box 807, 8452 Tortor. Avenue	Lakewood	CO	37624	(534) 942-7976	2018-03-20	t
287	Navarro	Risa	nec.eleifend.non@eu.ca	416-4257 Malesuada Street	Madison	WI	88305	(147) 741-9611	2019-02-09	t
288	Mcconnell	Declan	nascetur.ridiculus@atnisiCum.edu	P.O. Box 155, 3562 Laoreet Av.	Bear	DE	65094	(234) 222-4512	2018-07-25	t
289	Anderson	Lev	quam.vel.sapien@purus.co.uk	Ap #533-4466 Proin Av.	Gaithersburg	MD	69074	(549) 940-7378	2018-03-29	t
290	Howell	Sylvester	ante.lectus.convallis@eratSed.org	Ap #825-7237 Nullam St.	Portland	OR	84017	(807) 137-2513	2019-01-11	t
291	Dixon	Jackson	odio.Etiam@sollicitudinadipiscing.co.uk	5956 In Av.	Springfield	MO	12988	(842) 728-1537	2017-10-02	t
292	Tyler	Zelenia	consequat.dolor@augue.co.uk	796-4222 Est. St.	Cheyenne	WY	78164	(111) 678-1837	2018-03-20	t
293	Knowles	Akeem	magna.Sed.eu@Nullamfeugiat.edu	Ap #782-7248 Vivamus Av.	Kenosha	WI	33875	(960) 724-5265	2018-05-24	t
294	Franklin	Evangeline	eget@eratSed.ca	5352 Velit. Av.	Grand Island	NE	21958	(412) 983-7414	2019-03-30	t
295	Tanner	Whitney	purus@Aliquamfringillacursus.net	8039 Id, Avenue	Bloomington	MN	38558	(403) 585-7467	2018-07-15	t
296	Martin	Adrian	elementum@nascetur.net	P.O. Box 803, 9557 Vestibulum, Avenue	Biloxi	MS	21609	(811) 836-7895	2018-09-29	t
297	Mclean	Madaline	Phasellus@egestas.edu	P.O. Box 349, 6402 Malesuada St.	Minneapolis	MN	80985	(639) 798-7210	2017-08-11	t
298	Allen	Fleur	cubilia.Curae@necquamCurabitur.ca	3574 A, St.	Columbia	MD	66604	(124) 446-5885	2018-07-28	t
299	Murphy	Abraham	turpis.Nulla.aliquet@Aenean.edu	Ap #390-3386 Auctor, Rd.	Juneau	AK	99585	(364) 464-9127	2017-12-08	t
300	Diaz	Drake	parturient@euaugueporttitor.ca	Ap #857-532 Dolor St.	Norfolk	VA	84983	(666) 484-3843	2017-11-06	t
301	Fields	Sage	Sed@elementumsem.edu	489-5358 Parturient St.	Houston	TX	70577	(988) 420-5814	2019-04-21	t
302	Holt	Lane	in.molestie.tortor@euturpisNulla.org	Ap #861-9412 Fermentum Road	Montgomery	AL	35857	(434) 124-3143	2019-03-13	t
303	Tyson	Bell	dolor.sit@ametnulla.ca	Ap #326-384 Morbi Ave	Jefferson City	MO	12661	(869) 892-0115	2018-08-14	t
304	Manning	Xandra	molestie.dapibus@aliquameuaccumsan.com	6568 Euismod Rd.	Idaho Falls	ID	13401	(624) 812-2853	2017-10-13	t
305	Morton	Yasir	eros.Proin@venenatis.ca	539-7135 Aliquam Av.	Jonesboro	AR	72062	(116) 711-2052	2018-05-25	t
306	Carey	Harper	accumsan.laoreet.ipsum@nulla.com	493-9850 Eu, Av.	Oklahoma City	OK	92670	(454) 552-2316	2019-03-26	t
307	Hendricks	Morgan	Nunc.sollicitudin.commodo@ipsumnonarcu.ca	9278 Eget Rd.	West Jordan	UT	72646	(865) 599-9585	2018-03-10	t
308	Calderon	Austin	ipsum@Namligulaelit.co.uk	272-8018 Magna Ave	Phoenix	AZ	86395	(592) 805-0577	2017-06-17	t
309	Knox	Yen	Suspendisse.sagittis.Nullam@nulla.co.uk	P.O. Box 845, 9073 Nisi. Street	Kailua	HI	34601	(193) 571-6071	2018-11-20	t
310	Kennedy	Jade	posuere@dignissimtempor.org	Ap #643-8118 Curabitur Av.	Bangor	ME	43528	(120) 152-6248	2018-04-26	t
311	Hebert	Erica	libero@orci.ca	884-7799 Accumsan Rd.	Kaneohe	HI	48125	(869) 918-7727	2019-06-08	t
312	Knox	Akeem	nibh.Aliquam.ornare@massaQuisque.ca	299-4104 Interdum Rd.	Juneau	AK	99763	(848) 553-1759	2018-04-08	t
313	Taylor	Kimberley	sed.leo.Cras@Nunclaoreet.edu	543-3559 Pharetra Rd.	Tuscaloosa	AL	36363	(292) 380-1064	2019-04-04	t
314	Ratliff	Philip	tincidunt@velconvallisin.net	500-937 Velit Street	Aurora	CO	61938	(220) 509-6373	2018-03-25	t
315	Oneill	Ursula	eu.dui.Cum@aliquetnecimperdiet.org	722-6118 Dolor Street	Springdale	AR	71376	(864) 145-8157	2017-10-26	t
316	Summers	Lester	Phasellus.at.augue@vulputate.edu	279-7616 Ultrices. Avenue	Grand Island	NE	87436	(837) 667-2623	2019-05-30	t
317	Bolton	Isaiah	orci.luctus@liberonecligula.net	8826 Maecenas St.	Erie	PA	54576	(630) 259-5121	2017-11-16	t
318	Stanton	Xantha	purus.in@etrisus.co.uk	P.O. Box 223, 1495 Aliquam Rd.	Madison	WI	95022	(167) 605-2643	2018-02-12	t
319	Clemons	Larissa	interdum.Curabitur@lobortistellusjusto.ca	918-1014 Nunc Av.	Naperville	IL	76619	(448) 791-8257	2018-03-07	t
320	Rose	Camille	justo.sit.amet@Nuncmauriselit.co.uk	837-9297 Tempor, St.	Duluth	MN	19738	(328) 577-4302	2018-01-29	t
321	Black	Nevada	lacus.pede.sagittis@blanditNam.ca	9768 Neque Avenue	Newport News	VA	16187	(323) 321-4696	2019-06-08	t
322	Mullen	Madeline	ornare@atnisiCum.co.uk	5115 Urna Road	Portland	OR	46308	(566) 958-4669	2017-09-11	t
323	Haynes	Lucius	ipsum.dolor.sit@dignissimmagna.edu	P.O. Box 931, 5516 Felis Avenue	Gulfport	MS	88191	(934) 272-1866	2018-07-28	t
324	Strickland	Darius	nibh@malesuadamalesuada.edu	9677 Dictum St.	Madison	WI	93628	(298) 527-8767	2018-04-01	t
325	Warren	Dorian	Morbi@inmagna.net	3250 Rhoncus. Rd.	Detroit	MI	24385	(377) 771-8410	2019-03-13	t
326	Knowles	Elvis	at@elitsed.com	Ap #464-2199 Molestie Road	Chattanooga	TN	43975	(979) 407-5309	2017-11-03	t
327	Cain	Byron	et.ultrices.posuere@eudui.edu	115-3628 Id, Av.	Tucson	AZ	86027	(449) 792-6778	2019-04-12	t
328	Cobb	Nita	nisi@portaelita.com	519-1466 Vestibulum. Street	San Francisco	CA	91830	(800) 973-2712	2018-04-07	t
329	Richardson	Aristotle	posuere@interdumNunc.net	153-1884 Ipsum. Avenue	Evansville	IN	20510	(519) 931-2225	2018-12-21	t
331	Wyatt	Pearl	In.mi@ornare.org	2784 Cursus St.	Anchorage	AK	99715	(386) 175-3132	2017-10-06	t
332	Hudson	Edward	facilisis.facilisis.magna@semper.edu	Ap #875-4509 Vulputate, Rd.	San Jose	CA	96597	(641) 388-8563	2017-12-26	t
333	Waters	Thane	egestas.lacinia.Sed@purusDuis.com	808-1689 Sodales Road	Kapolei	HI	24500	(402) 247-1645	2019-02-06	t
334	Chandler	Gloria	vestibulum@elit.edu	201-5439 Erat, Rd.	Salem	OR	71849	(223) 553-0616	2018-12-30	t
335	Rosales	Thomas	dolor@porttitor.edu	636-7875 Sed Rd.	Gulfport	MS	31984	(468) 103-2547	2018-01-12	t
336	Petty	Clarke	dapibus@milorem.co.uk	Ap #329-5624 Mollis. St.	Augusta	ME	41991	(751) 626-1239	2017-08-08	t
337	Craft	Uma	posuere.enim@semperNamtempor.co.uk	781-4912 Sit St.	Annapolis	MD	21285	(975) 609-9737	2018-11-23	t
338	Flowers	Jada	penatibus.et@rhoncus.org	927-840 Luctus Rd.	Lincoln	NE	69693	(295) 722-3281	2019-03-12	t
339	Mcconnell	Joel	Nullam.scelerisque@faucibusorciluctus.com	P.O. Box 683, 8970 Ridiculus Rd.	Columbia	MD	34772	(611) 227-5424	2018-10-19	t
340	Slater	Alfreda	condimentum@morbi.ca	P.O. Box 412, 5178 Luctus Street	Boise	ID	54730	(863) 355-5243	2018-02-15	t
341	Watts	Athena	euismod.enim@duiin.org	6737 Nisi St.	Biloxi	MS	25049	(908) 268-2650	2018-07-25	t
342	Baldwin	Akeem	faucibus@nonsollicitudin.edu	P.O. Box 287, 4650 Arcu Rd.	Naperville	IL	25861	(779) 317-6638	2017-10-08	t
343	Reid	Asher	bibendum.Donec.felis@dui.ca	988-8427 Ac Road	Gresham	OR	29861	(822) 318-2382	2019-03-07	t
344	Fry	Howard	Sed.molestie@luctusCurabituregestas.com	P.O. Box 144, 6576 Nullam St.	Miami	FL	53219	(762) 742-7989	2017-07-12	t
345	Garza	Kerry	mattis@Inornare.ca	Ap #418-1334 Sit Rd.	Columbia	MO	98154	(284) 163-6296	2017-08-10	t
346	Nielsen	Merrill	Aliquam.vulputate@nibhenim.ca	8455 Nunc Street	Wilmington	DE	81314	(734) 942-3926	2017-09-04	t
347	Bryan	Mechelle	semper.rutrum.Fusce@Phasellusfermentum.co.uk	P.O. Box 870, 4470 Tellus. Ave	Huntsville	AL	36061	(638) 392-2840	2018-07-04	t
348	Larsen	Faith	elementum@acnullaIn.edu	8692 Lacinia Rd.	Sioux City	IA	79692	(167) 819-0969	2018-09-18	t
349	Moore	Hoyt	Ut.sagittis@Fusce.edu	P.O. Box 411, 7570 Ante Ave	Chandler	AZ	85728	(927) 834-8343	2018-08-04	t
350	Andrews	Hunter	Phasellus@justo.com	9220 Est, Rd.	Frankfort	KY	28429	(100) 285-1519	2018-08-13	t
351	Mckee	Vivien	egestas.blandit@Donecporttitor.co.uk	8769 Id Rd.	Kapolei	HI	98581	(530) 199-6713	2017-08-04	t
352	Leblanc	Odessa	a.aliquet@Morbi.com	972-6860 Nam Rd.	Minneapolis	MN	73088	(550) 860-6052	2017-07-22	t
353	Golden	Prescott	penatibus@mattisornarelectus.com	743-7737 Malesuada St.	Aurora	IL	24109	(616) 640-0168	2018-12-14	t
354	Lyons	Hedda	tristique@magnaa.edu	P.O. Box 797, 6192 Natoque St.	Lincoln	NE	14036	(954) 543-3310	2017-07-01	t
355	Solomon	Mufutau	congue.a.aliquet@nonhendrerit.net	123 Dis Ave	Jonesboro	AR	71253	(651) 218-7234	2018-01-05	t
356	Puckett	Callie	at.augue.id@metusAeneansed.edu	2462 Fermentum Avenue	Casper	WY	20396	(236) 137-4116	2018-02-15	t
357	Bullock	Oscar	nunc@pharetrafelis.co.uk	8974 Orci Av.	Olathe	KS	91301	(717) 429-4665	2019-05-15	t
358	Dejesus	Vincent	sodales.elit@Phasellus.ca	P.O. Box 838, 9522 Pretium Avenue	Cincinnati	OH	78995	(441) 814-9330	2018-10-22	t
359	Daugherty	Ima	aliquet@posuerecubiliaCurae.ca	P.O. Box 276, 2851 Conubia St.	Hilo	HI	21654	(165) 761-6974	2018-04-08	t
360	Howell	Herman	nibh@velitdui.edu	3848 Non, Av.	College	AK	99863	(905) 189-8251	2019-05-21	t
361	Lester	Uma	vitae.odio.sagittis@turpis.ca	8997 Sit St.	Topeka	KS	85253	(843) 885-6485	2017-12-11	t
362	Brennan	Aimee	tellus.Phasellus.elit@cursus.org	Ap #634-8207 Morbi Road	Rutland	VT	60571	(634) 966-2419	2018-10-25	t
363	Beasley	Zahir	neque.sed.dictum@tinciduntduiaugue.com	1249 Parturient Avenue	Athens	GA	33242	(156) 245-5394	2018-01-17	t
364	Drake	Chaney	cursus.a.enim@sedorcilobortis.com	2563 Et, Av.	Vancouver	WA	95572	(765) 692-1008	2018-10-09	t
365	Stafford	Wanda	nulla@arcueu.net	8797 Luctus Rd.	Biloxi	MS	22993	(323) 656-1001	2019-05-12	t
366	Ryan	Libby	ante.bibendum@tinciduntorci.edu	P.O. Box 504, 4894 Fermentum Road	Las Vegas	NV	22564	(477) 456-4333	2019-03-05	t
367	Dickson	Samantha	netus@Morbi.edu	Ap #179-5842 Enim Av.	South Burlington	VT	28900	(136) 337-3262	2017-09-04	t
368	Goodman	Keefe	in.tempus@urnaUt.org	Ap #960-5231 Fermentum Ave	Clarksville	TN	40880	(274) 808-0763	2018-11-19	t
369	Ball	Keefe	scelerisque.lorem@pede.net	P.O. Box 893, 5024 Maecenas Ave	Chesapeake	VA	20148	(452) 268-7203	2018-05-05	t
370	Tucker	Naomi	Cras.eget@utodio.org	852 Quisque Street	Tallahassee	FL	58558	(323) 389-9814	2017-10-06	t
371	Vega	Aphrodite	sodales.at@Praesenteudui.ca	Ap #239-1677 Urna. Avenue	Grand Island	NE	35508	(326) 614-0746	2017-07-27	t
372	Rowland	Ella	Donec.egestas.Aliquam@sociisnatoquepenatibus.net	P.O. Box 194, 6002 Vivamus St.	Duluth	MN	30562	(346) 658-7165	2019-04-21	t
373	Kemp	Margaret	dictum.eleifend@euodioPhasellus.co.uk	1050 Consectetuer Rd.	Hillsboro	OR	54017	(910) 107-1053	2018-09-18	t
374	Lindsey	Alden	dui.quis.accumsan@Vestibulumante.edu	5561 Ut Avenue	Joliet	IL	72289	(318) 100-4627	2018-12-02	t
375	Vazquez	Hadassah	ultricies.dignissim@quam.edu	5606 Quisque St.	Ketchikan	AK	99702	(677) 131-2733	2018-08-28	t
376	Petersen	Kirk	sem.eget@Nullafacilisis.org	P.O. Box 181, 5742 Feugiat Street	Tacoma	WA	35596	(689) 245-4284	2018-05-10	t
377	Paul	Tyrone	ante.blandit.viverra@risus.org	Ap #434-3040 Lacinia. Street	Des Moines	IA	33244	(651) 871-1097	2018-12-06	t
378	Heath	Herrod	fames.ac.turpis@risusaultricies.net	1255 In St.	South Burlington	VT	38048	(974) 930-5561	2018-11-27	t
379	Hull	Aristotle	eros@eleifendnon.net	747-7683 Donec Rd.	Shreveport	LA	21696	(390) 504-4973	2018-07-24	t
380	Wallace	Shelley	nunc@malesuada.edu	725-3108 Sed Av.	Lakewood	CO	26375	(389) 132-2730	2017-10-26	t
381	Watson	Martha	luctus.aliquet.odio@duiCraspellentesque.com	Ap #730-2274 Lobortis, St.	Broken Arrow	OK	51844	(453) 536-3586	2018-09-16	t
382	Keith	Basil	eu.placerat.eget@luctuslobortisClass.edu	Ap #276-3028 Primis Street	Pike Creek	DE	21018	(340) 899-7390	2018-10-01	t
383	Powers	Camille	nunc@Integer.org	P.O. Box 388, 2549 Malesuada Av.	Huntsville	AL	35783	(888) 553-3541	2017-08-22	t
384	Wiggins	Troy	congue.a@quama.ca	Ap #369-9324 Diam St.	San Francisco	CA	95350	(537) 535-3909	2019-02-27	t
385	Stevenson	Carly	In.scelerisque.scelerisque@musAeneaneget.org	665-9449 Facilisi. Rd.	Warren	MI	57110	(921) 395-8482	2018-12-31	t
386	Williamson	Clayton	velit@ultricesposuerecubilia.org	P.O. Box 861, 4729 Vel, Rd.	Louisville	KY	75413	(446) 995-7025	2017-07-02	t
387	Morton	Clio	nec.diam.Duis@Namnulla.com	P.O. Box 978, 7873 Nullam St.	Naperville	IL	72770	(204) 259-4821	2017-09-12	t
388	Ray	Axel	dolor.dapibus@tinciduntnuncac.edu	Ap #479-7996 Ac, Rd.	Metairie	LA	90430	(685) 112-6883	2017-09-11	t
389	Casey	Wilma	at.iaculis@eget.org	P.O. Box 641, 7554 Mauris. Street	Anchorage	AK	99904	(254) 399-4273	2018-06-29	t
390	White	Latifah	eget@sollicitudin.co.uk	407-7034 Donec Ave	Los Angeles	CA	92349	(634) 529-3896	2018-04-08	t
391	Obrien	Reuben	risus.Quisque.libero@a.net	360-9346 Lacus. Rd.	Davenport	IA	68003	(701) 761-1992	2018-02-21	t
392	Espinoza	Rebekah	Donec.fringilla@turpisegestas.com	7456 Non, Ave	Paradise	NV	76623	(146) 848-7904	2018-12-31	t
393	Noble	Cooper	dolor.dapibus@sedestNunc.org	P.O. Box 734, 6071 Mauris Av.	Kearney	NE	83955	(922) 505-8857	2017-12-01	t
394	Banks	Thane	rhoncus@musAenean.ca	447 In St.	Carson City	NV	99660	(628) 691-0897	2018-10-20	t
395	Gonzalez	Mia	ut.eros@Donecluctusaliquet.org	9903 Cras Street	Saint Louis	MO	72507	(717) 419-5540	2018-02-02	t
396	Padilla	Wendy	Etiam.laoreet.libero@semvitae.org	451-3658 Nulla Avenue	Naperville	IL	80177	(864) 638-4324	2017-07-07	t
397	Bender	Uta	vehicula.et.rutrum@Mauris.com	4878 Ac, Rd.	Cleveland	OH	98952	(121) 426-5976	2018-10-20	t
398	Dunlap	Calvin	quam.elementum@nibh.ca	P.O. Box 985, 7003 Nulla St.	Worcester	MA	32393	(574) 515-4181	2017-08-16	t
399	Howe	Bevis	in@nequeSedeget.com	230-7037 Quam Rd.	Springfield	MO	72550	(717) 248-9992	2017-06-30	t
400	Skinner	Freya	dolor.Donec.fringilla@sed.ca	8167 Nibh. Ave	Gary	IN	20800	(179) 155-6617	2017-07-07	t
1	Jefferson	Sandra	sandra.jefferson@getCerts.com	1802 Broadway Apt 204	Seattle	WA	98100	(206)555-1243 	2017-01-15	t
2	Larson	Michael	michael.larson@getCerts.com	121 12th 	Seattle	WA	98100	(206)555-1543 	2017-01-15	t
3	Carney	Lynn	lynn.carney@getCerts.com	2020 8th Ave	Seattle	WA	98100	(206)555-9012 	2017-01-15	t
4	Masters	Lisa	lisa.masters@getCerts.com	985 Michagen Street	Seattle	WA	98100	(206)555-6798 	2017-01-15	t
5	Brown	Marianna	marianna.brown@getCerts.com	923 Madison 	Seattle	WA	98100	(206)555-4321 	2017-01-20	t
6	Cernoff	David	david.cernoff@getCerts.com	apt 12 2018 North 24th	Seattle	WA	98100	(206)555-3232 	2017-01-20	t
7	Moon	Amy	amy.moon@getCerts.com	apt 321 South Jackson street	Seattle	WA	98100	(206)555-3123 	2017-01-25	t
8	Smith	Tanya	ltanya.smith@getCerts.com	802 Bell	Seattle	WA	98100	(206)555-9829 	2017-02-05	t
9	Kell	Bradly	bradley.kell@getCerts.com	101 South Main	Seattle	WA	98100	(206)555-2929 	2017-02-08	t
10	Roberts	Carol	carol.roberts@getCerts.com	Apt 454 1201 Ballard Ave	Seattle	WA	98100	(206)555-5012 	2017-02-15	t
11	Nelson	Mark	mark.nelson@getCerts.com	2101 34th Ave	Seattle	WA	98100	(206)555-3328 	2017-02-17	t
12	Hon	Sara	sara.hon@getCerts.com	2321 South Admiral Street	Seattle	WA	98100	(206)555-6073 	2017-02-21	t
401	Jones	Mandy	mandy.jones.brown@getCerts.com	1010 Elm 	Seattle	WA	98100	(206)555-1256 	2018-01-20	t
402	Sanders	Charles	charles.sanders.brown@getCerts.com	3321 Seaside 	Seattle	WA	98100	(206)555-9854 	2018-01-20	t
403	Jonson	Martha	mjohnson@hotmail.com	1230 Main Avenue	Seattle	WA	98001	2065554674    	2019-01-22	t
405	Jackson	Melanie	meljack@gmail.com	111 South Anderson Street	Seattle	WA	98002	2065552323    	2019-02-14	t
330	Nash	Kenneth	orci.Phasellus@eratvolutpat.net	Ap #321-6581 Ullamcorper Rd.	Bellevue	WA	55178	(374) 891-8916	2018-03-16	t
411	Marcus	Stifany	stifanimm@gmail.com	1342 56th st.	Seattle	WA	98004	2065687687    	2019-03-07	t
413	James	Sado	sado@example.com	123 Fake Street	Fauxville	OH	44512	3305557654    	2019-03-07	t
414	Spring	Sara	saraspring@example.com	2896 58th Ave SW.	Seattle	WA	98126	2065559665    	2019-03-07	t
\.


--
-- Data for Name: pricehistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pricehistory (pricehistorykey, pricebegindate, pricepercredit, pricediscount) FROM stdin;
1	2017-01-01	200.00	0.03
2	2018-01-01	235.00	0.05
3	2019-01-01	250.00	0.05
\.


--
-- Data for Name: quarter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quarter (quarterkey, quartername) FROM stdin;
1	Fall
2	Winter
3	Spring
4	Summer
\.


--
-- Data for Name: roster; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roster (rosterkey, sectionkey, studentkey, finalgrade, lowgradeflag) FROM stdin;
1097	71	9	1.44	f
1098	71	10	3.97	f
1100	71	16	3.77	f
1104	71	37	1.35	f
1105	71	43	1.41	f
1106	71	46	2.27	f
1114	71	78	3.66	f
1115	71	82	2.42	f
1116	71	90	1.16	f
1119	71	134	2.52	f
1124	71	162	2.50	f
1126	71	168	1.21	f
1128	71	177	1.08	f
1130	71	182	1.81	f
1132	71	192	2.33	f
1135	72	7	1.18	f
1136	72	9	3.65	f
1140	72	19	3.22	f
1141	72	24	2.65	f
1143	72	37	3.52	f
1151	72	71	2.37	f
1152	72	77	3.27	f
1153	72	78	3.01	f
1154	72	82	3.82	f
1155	72	90	1.84	f
1156	72	109	3.94	f
1157	72	129	1.34	f
1158	72	134	3.11	f
1159	72	137	3.55	f
1160	72	139	2.30	f
1162	72	158	2.38	f
1163	72	162	1.38	f
1167	72	177	1.16	f
1169	72	182	3.79	f
1171	72	192	3.22	f
1173	72	197	3.28	f
847	39	6	1.30	f
850	39	41	2.50	f
851	39	42	2.60	f
854	39	65	3.60	f
855	39	67	2.90	f
856	39	88	2.30	f
857	39	95	3.90	f
864	39	148	3.20	f
866	39	150	2.70	f
871	40	6	2.10	f
873	40	12	3.60	f
874	40	41	3.70	f
876	40	45	1.90	f
877	40	61	3.20	f
878	40	65	1.30	f
880	40	88	3.10	f
881	40	95	3.40	f
882	40	96	3.90	f
883	40	98	3.10	f
887	40	147	2.00	f
889	40	149	1.30	f
892	40	175	3.20	f
894	40	181	3.20	f
896	41	11	2.60	f
897	41	12	2.10	f
1628	97	162	\N	f
1629	97	192	\N	f
1630	97	7	\N	f
1631	97	13	\N	f
1632	97	19	\N	f
1633	97	24	\N	f
1634	97	29	\N	f
1635	97	47	\N	f
1636	97	53	\N	f
1637	97	58	\N	f
1638	97	64	\N	f
1639	97	68	\N	f
1640	97	71	\N	f
1641	97	77	\N	f
1642	97	109	\N	f
1643	97	129	\N	f
1644	97	137	\N	f
1645	97	139	\N	f
1646	97	153	\N	f
1647	97	158	\N	f
1648	97	164	\N	f
1649	97	174	\N	f
1650	97	178	\N	f
1651	97	185	\N	f
1652	97	194	\N	f
1653	97	197	\N	f
1654	98	41	\N	f
1655	98	42	\N	f
1656	98	12	\N	f
1657	98	103	\N	f
1658	98	149	\N	f
1659	98	175	\N	f
1660	98	179	\N	f
1661	98	65	\N	f
1662	98	67	\N	f
1663	98	88	\N	f
1664	98	148	\N	f
1665	98	150	\N	f
1666	98	61	\N	f
1667	98	96	\N	f
1668	98	123	\N	f
1669	98	141	\N	f
1670	98	147	\N	f
1671	98	181	\N	f
1672	99	41	\N	f
899	41	42	3.00	f
900	41	45	2.80	f
902	41	65	3.40	f
904	41	88	1.80	f
905	41	95	1.80	f
908	41	103	1.00	f
909	41	123	2.70	f
910	41	141	2.90	f
912	41	148	1.30	f
914	41	150	3.00	f
915	41	173	1.10	f
917	41	179	3.10	f
918	41	181	3.90	f
920	42	11	2.20	f
922	42	41	1.70	f
923	42	42	3.80	f
926	42	65	2.80	f
927	42	67	1.50	f
928	42	88	2.90	f
929	42	95	3.70	f
931	42	98	3.90	f
932	42	103	2.70	f
934	42	141	3.20	f
936	42	148	3.10	f
937	42	149	1.10	f
938	42	150	2.90	f
940	42	175	2.20	f
941	42	179	2.30	f
1175	73	9	3.92	f
1177	73	13	1.81	f
1178	73	16	1.34	f
1179	73	19	2.23	f
1180	73	24	1.83	f
1181	73	29	3.20	f
1182	73	37	1.15	f
1183	73	43	3.52	f
1185	73	47	2.84	f
1189	73	68	1.57	f
1191	73	77	3.22	f
1192	73	78	2.18	f
1194	73	90	3.37	f
1195	73	109	3.65	f
1196	73	129	2.93	f
1198	73	137	1.37	f
1200	73	153	1.55	f
1201	73	158	3.92	f
1203	73	164	3.02	f
1204	73	168	2.83	f
1206	73	177	3.94	f
1207	73	178	2.22	f
1208	73	182	1.96	f
1209	73	185	1.72	f
1210	73	192	1.14	f
1212	73	197	3.22	f
1213	74	7	2.36	f
1214	74	9	2.78	f
1216	74	13	2.54	f
957	44	39	1.70	f
958	44	48	2.30	f
1219	74	24	1.99	f
959	44	76	3.20	f
962	44	51	1.60	f
1221	74	37	3.20	f
1222	74	43	2.63	f
1223	74	46	3.79	f
1224	74	47	3.63	f
1227	74	64	1.45	f
963	44	56	2.20	f
964	44	57	3.90	f
965	44	93	2.90	f
966	44	176	2.00	f
967	45	48	2.30	f
968	45	57	3.00	f
969	45	76	1.20	f
970	45	93	1.50	f
971	45	169	2.80	f
973	45	3	2.60	f
975	45	51	2.40	f
977	45	110	1.20	f
979	46	3	2.60	f
981	46	176	3.50	f
984	46	51	3.10	f
985	46	93	3.10	f
987	46	169	2.20	f
988	46	189	1.90	f
724	33	17	3.30	f
725	33	20	1.60	f
726	33	40	3.90	f
729	33	73	2.50	f
732	33	92	3.90	f
735	33	124	1.70	f
736	33	130	2.90	f
1228	74	68	1.05	f
1229	74	71	1.44	f
1230	74	77	2.06	f
1231	74	78	3.42	f
1235	74	129	2.82	f
1236	74	134	2.19	f
1239	74	153	1.87	f
1240	74	158	3.66	f
1245	74	177	3.00	f
1246	74	178	2.67	f
1247	74	182	2.94	f
1248	74	185	2.86	f
1249	74	192	3.56	f
1184	73	46	4.00	f
1186	73	53	4.00	f
1187	73	58	4.00	f
1188	73	64	4.00	f
1190	73	71	4.00	f
1193	73	82	4.00	f
1197	73	134	4.00	f
1199	73	139	4.00	f
1202	73	162	4.00	f
1205	73	174	4.00	f
1211	73	194	4.00	f
1215	74	10	4.00	f
1217	74	16	4.00	f
1218	74	19	4.00	f
1220	74	29	4.00	f
1225	74	53	4.00	f
1226	74	58	4.00	f
960	44	105	4.00	f
737	33	155	2.30	f
738	33	159	3.10	f
739	33	36	1.30	f
740	33	59	1.00	f
742	33	86	3.70	f
743	33	89	2.60	f
746	33	140	1.40	f
747	34	17	2.60	f
748	34	20	1.40	f
749	34	40	2.30	f
1254	75	65	1.25	f
1255	75	67	1.80	f
1256	75	88	2.68	f
1257	75	95	1.13	f
1258	75	148	3.10	f
1259	75	150	1.39	f
1260	75	11	3.78	f
1262	75	45	2.45	f
1263	75	61	3.91	f
1264	75	96	3.75	f
1266	75	103	1.76	f
1267	75	123	2.45	f
1268	75	141	1.67	f
1269	75	147	2.30	f
1270	75	149	2.07	f
1271	75	173	1.01	f
1272	75	175	3.35	f
1273	75	179	2.55	f
1274	75	181	2.79	f
1275	77	41	3.96	f
1276	77	42	2.54	f
1280	77	95	1.90	f
1283	77	11	1.16	f
1284	77	12	2.58	f
1285	77	45	1.74	f
991	47	73	1.50	f
993	47	130	3.00	f
994	47	155	1.50	f
996	47	86	3.50	f
1288	77	98	1.95	f
1289	77	103	3.70	f
1293	77	149	3.93	f
1294	77	173	1.02	f
1295	77	175	2.22	f
1296	77	179	3.08	f
1298	78	11	3.46	f
1299	78	12	2.10	f
1301	78	45	2.60	f
1304	78	141	2.12	f
1305	78	150	3.83	f
1306	78	179	3.42	f
1307	78	181	2.67	f
1308	78	6	1.12	f
1310	78	61	2.98	f
1311	78	67	1.59	f
1312	78	96	2.32	f
1316	78	175	3.18	f
1317	79	11	2.62	f
1319	79	65	2.52	f
1321	79	95	2.70	f
1322	79	98	1.71	f
1325	79	148	1.89	f
1327	79	175	2.97	f
1331	79	45	1.61	f
1333	79	96	3.25	f
1335	79	147	3.29	f
1337	80	11	2.92	f
1338	80	42	3.97	f
1341	80	95	1.57	f
1342	80	98	1.23	f
1344	80	141	2.95	f
1345	80	148	3.28	f
1346	80	150	1.78	f
1347	80	175	1.73	f
1349	80	6	3.66	f
1352	80	61	2.57	f
1353	80	96	1.05	f
1881	107	168	\N	f
1354	80	123	3.21	f
1882	107	174	\N	f
1355	80	147	1.32	f
1883	107	178	\N	f
1884	107	185	\N	f
1885	107	194	\N	f
1886	108	9	\N	f
1887	108	19	\N	f
1888	108	24	\N	f
1889	108	37	\N	f
1890	108	71	\N	f
1891	108	77	\N	f
1892	108	78	\N	f
1893	108	82	\N	f
1894	108	109	\N	f
1895	108	134	\N	f
1896	108	137	\N	f
1897	108	139	\N	f
1898	108	158	\N	f
1899	108	182	\N	f
1900	108	192	\N	f
1901	108	197	\N	f
1902	108	10	\N	f
1903	108	13	\N	f
1904	108	16	\N	f
1905	108	29	\N	f
1906	108	43	\N	f
1907	108	46	\N	f
1908	108	47	\N	f
1909	108	53	\N	f
1910	108	58	\N	f
1911	108	64	\N	f
1912	108	68	\N	f
1913	108	153	\N	f
1914	108	164	\N	f
1915	108	168	\N	f
1916	108	174	\N	f
1917	108	178	\N	f
1918	108	185	\N	f
1919	108	194	\N	f
1356	80	173	3.07	f
1358	81	12	2.81	f
1359	81	41	3.66	f
1361	81	88	2.35	f
1543	91	125	\N	f
1544	91	127	\N	f
1545	91	133	\N	f
1546	91	138	\N	f
1547	91	143	\N	f
1548	91	166	\N	f
1549	91	172	\N	f
1550	91	184	\N	f
1551	92	18	\N	f
1552	92	22	\N	f
1553	92	26	\N	f
1554	92	31	\N	f
1555	92	44	\N	f
1556	92	50	\N	f
1557	92	63	\N	f
1558	92	66	\N	f
1559	92	84	\N	f
1560	92	87	\N	f
1561	92	94	\N	f
1562	92	101	\N	f
1563	92	102	\N	f
1564	92	106	\N	f
1565	92	113	\N	f
1566	92	125	\N	f
1567	92	127	\N	f
1568	92	133	\N	f
1569	92	138	\N	f
1570	92	143	\N	f
1571	92	166	\N	f
1572	92	172	\N	f
1573	92	184	\N	f
1574	93	10	\N	f
1575	93	16	\N	f
1576	93	46	\N	f
1577	93	78	\N	f
1578	93	82	\N	f
1579	93	134	\N	f
1580	93	162	\N	f
1581	93	192	\N	f
1582	93	7	\N	f
1583	93	13	\N	f
1584	93	19	\N	f
1585	93	24	\N	f
1586	93	29	\N	f
1587	93	47	\N	f
1588	93	53	\N	f
1589	93	58	\N	f
1590	93	64	\N	f
1591	93	68	\N	f
1592	93	71	\N	f
1593	93	77	\N	f
1594	93	109	\N	f
1595	93	129	\N	f
1596	93	137	\N	f
1597	93	139	\N	f
1598	93	153	\N	f
1599	93	158	\N	f
1600	93	164	\N	f
1601	93	174	\N	f
1602	93	178	\N	f
1603	93	185	\N	f
1604	93	194	\N	f
1605	93	197	\N	f
1606	94	88	\N	f
1607	94	148	\N	f
1608	94	11	\N	f
1609	94	45	\N	f
1610	94	61	\N	f
1252	75	41	4.00	f
1611	94	96	\N	f
1612	94	123	\N	f
1613	94	147	\N	f
1614	94	149	\N	f
1615	94	175	\N	f
1616	94	179	\N	f
1617	94	181	\N	f
1618	94	41	\N	f
1619	94	42	\N	f
1620	94	12	\N	f
1621	94	98	\N	f
1622	97	10	\N	f
1623	97	16	\N	f
1624	97	46	\N	f
1625	97	78	\N	f
1626	97	82	\N	f
1627	97	134	\N	f
1673	99	42	\N	f
1674	99	12	\N	f
1675	99	103	\N	f
1676	99	149	\N	f
1677	99	175	\N	f
1678	99	179	\N	f
1679	99	65	\N	f
1680	99	67	\N	f
1681	99	88	\N	f
1682	99	148	\N	f
1683	99	150	\N	f
1684	99	61	\N	f
1685	99	96	\N	f
1686	99	123	\N	f
1687	99	141	\N	f
1688	99	147	\N	f
1689	99	181	\N	f
1690	100	41	\N	f
1691	100	42	\N	f
1692	100	12	\N	f
1693	100	103	\N	f
1694	100	149	\N	f
1695	100	175	\N	f
1696	100	179	\N	f
1697	100	65	\N	f
1698	100	67	\N	f
1699	100	88	\N	f
1700	100	148	\N	f
1701	100	150	\N	f
1702	100	61	\N	f
1703	100	96	\N	f
1704	100	123	\N	f
1705	100	141	\N	f
1706	100	147	\N	f
1707	100	181	\N	f
1708	101	9	\N	f
1709	101	19	\N	f
1710	101	29	\N	f
1711	101	43	\N	f
1712	101	47	\N	f
1713	101	77	\N	f
1714	101	78	\N	f
1715	101	90	\N	f
1716	101	109	\N	f
1717	101	129	\N	f
1718	101	158	\N	f
1719	101	164	\N	f
1720	101	168	\N	f
1721	101	177	\N	f
1722	101	178	\N	f
1723	101	197	\N	f
1724	101	46	\N	f
1725	101	53	\N	f
1726	101	58	\N	f
1727	101	64	\N	f
1728	101	71	\N	f
1729	101	82	\N	f
1730	101	134	\N	f
1731	101	139	\N	f
1362	81	95	1.84	f
1363	81	96	1.88	f
997	47	89	2.20	f
998	47	62	3.70	f
999	47	70	1.10	f
1004	47	75	1.60	f
1005	47	128	2.20	f
1006	47	135	1.40	f
1007	48	6	2.30	f
1009	48	12	2.60	f
1013	48	61	2.80	f
1014	48	65	3.10	f
1015	48	67	3.30	f
1016	48	96	1.30	f
1018	48	123	3.10	f
1019	48	141	1.20	f
1022	48	150	2.10	f
1025	48	181	2.40	f
1026	49	6	1.20	f
1027	49	11	3.30	f
1364	81	98	2.31	f
1365	81	141	3.22	f
1366	81	147	2.78	f
1367	81	175	3.86	f
1368	81	181	1.04	f
1370	81	42	2.44	f
1732	101	162	\N	f
1733	101	174	\N	f
1734	101	194	\N	f
1735	101	7	\N	f
1736	101	10	\N	f
1737	102	9	\N	f
1738	102	19	\N	f
1739	102	29	\N	f
1740	102	43	\N	f
1741	102	47	\N	f
1742	102	77	\N	f
1743	102	78	\N	f
1744	102	90	\N	f
1745	102	109	\N	f
1746	102	129	\N	f
1747	102	158	\N	f
1748	102	164	\N	f
1749	102	168	\N	f
1750	102	177	\N	f
1751	102	178	\N	f
1752	102	197	\N	f
1753	102	46	\N	f
1754	102	53	\N	f
1373	81	123	3.90	f
1378	82	130	1.85	f
1380	82	89	2.04	f
1382	82	128	3.76	f
1383	82	17	1.73	f
1384	82	40	2.59	f
1385	82	92	2.40	f
1387	82	163	1.44	f
1388	82	195	3.99	f
1390	82	120	2.91	f
1393	83	89	2.17	f
1396	83	17	2.73	f
1397	83	40	3.42	f
1400	83	163	1.78	f
1402	83	114	2.80	f
1403	83	120	3.77	f
1404	84	41	3.40	f
1405	84	42	1.48	f
1407	84	67	2.50	f
1408	84	88	1.56	f
1409	84	95	2.09	f
1410	84	148	1.84	f
1411	84	150	1.45	f
1412	84	11	1.13	f
1417	84	98	3.87	f
1421	84	147	1.07	f
1422	84	149	2.97	f
1423	84	173	3.16	f
1426	84	181	1.19	f
1369	81	11	4.00	f
1371	81	67	4.00	f
1372	81	103	4.00	f
1374	81	148	4.00	f
1375	81	150	4.00	f
1376	81	173	4.00	f
1377	81	179	4.00	f
1379	82	86	4.00	f
1381	82	62	4.00	f
1386	82	159	4.00	f
1389	82	114	4.00	f
1391	83	130	4.00	f
1392	83	86	4.00	f
1394	83	62	4.00	f
1395	83	128	4.00	f
1398	83	92	4.00	f
1399	83	159	4.00	f
1755	102	58	\N	f
1401	83	195	4.00	f
1406	84	65	4.00	f
1756	102	64	\N	f
1757	102	71	\N	f
1758	102	82	\N	f
1759	102	134	\N	f
1760	102	139	\N	f
1413	84	12	4.00	f
1414	84	45	4.00	f
1415	84	61	4.00	f
1416	84	96	4.00	f
1418	84	103	4.00	f
1419	84	123	4.00	f
1420	84	141	4.00	f
1761	102	162	\N	f
1762	102	174	\N	f
1763	102	194	\N	f
1764	102	7	\N	f
1765	102	10	\N	f
1766	103	9	\N	f
1767	103	19	\N	f
1768	103	29	\N	f
1769	103	43	\N	f
1770	103	47	\N	f
1771	103	77	\N	f
1772	103	78	\N	f
1773	103	90	\N	f
1774	103	109	\N	f
1775	103	129	\N	f
1776	103	158	\N	f
1777	103	164	\N	f
1778	103	168	\N	f
1779	103	177	\N	f
1780	103	178	\N	f
1781	103	197	\N	f
1782	103	46	\N	f
1424	84	175	4.00	f
1425	84	179	4.00	f
766	34	89	4.00	f
769	34	140	4.00	f
1429	85	61	2.78	f
1783	103	53	\N	f
1431	85	67	3.07	f
1432	85	123	3.65	f
1433	85	150	2.31	f
1435	85	11	3.97	f
1436	85	41	1.43	f
1437	85	42	1.17	f
1438	85	45	3.55	f
1439	85	98	1.07	f
1442	85	175	3.93	f
1444	86	3	1.26	f
1445	86	39	1.79	f
1784	103	58	\N	f
1785	103	64	\N	f
1786	103	71	\N	f
1446	86	48	2.00	f
1447	86	189	2.70	f
1450	86	93	1.58	f
1451	86	105	3.40	f
1453	87	97	1.30	f
1455	87	40	2.26	f
1456	87	73	1.78	f
1459	87	195	2.35	f
1461	87	144	2.14	f
1462	87	186	2.88	f
1463	87	130	3.49	f
1464	87	155	3.91	f
1469	88	130	2.22	f
1471	88	89	2.97	f
1472	88	62	2.63	f
1474	88	17	1.20	f
1475	88	40	2.53	f
1787	103	82	\N	f
1788	103	134	\N	f
1789	103	139	\N	f
1790	103	162	\N	f
1791	103	174	\N	f
1792	103	194	\N	f
1793	103	7	\N	f
1794	103	10	\N	f
1795	104	9	\N	f
1796	104	19	\N	f
1797	104	29	\N	f
1798	104	43	\N	f
1799	104	47	\N	f
1800	104	77	\N	f
1801	104	78	\N	f
1802	104	90	\N	f
1803	104	109	\N	f
1804	104	129	\N	f
1805	104	158	\N	f
1806	104	164	\N	f
1807	104	168	\N	f
1808	104	177	\N	f
1809	104	178	\N	f
1810	104	197	\N	f
1811	104	46	\N	f
1812	104	53	\N	f
1813	104	58	\N	f
1814	104	64	\N	f
1815	104	71	\N	f
1816	104	82	\N	f
1817	104	134	\N	f
1818	104	139	\N	f
1819	104	162	\N	f
1820	104	174	\N	f
1821	104	194	\N	f
1822	104	7	\N	f
1823	104	10	\N	f
1824	105	61	\N	f
1825	105	67	\N	f
1826	105	123	\N	f
1827	105	150	\N	f
1828	105	11	\N	f
1478	88	163	1.92	f
1480	88	114	1.39	f
1096	71	7	4.00	f
1099	71	13	4.00	f
1101	71	19	4.00	f
1102	71	24	4.00	f
1103	71	29	4.00	f
1107	71	47	4.00	f
1108	71	53	4.00	f
1109	71	58	4.00	f
1110	71	64	4.00	f
1111	71	68	4.00	f
1112	71	71	4.00	f
1113	71	77	4.00	f
1117	71	109	4.00	f
1829	105	45	\N	f
1830	105	175	\N	f
1831	105	6	\N	f
1832	105	12	\N	f
1833	105	65	\N	f
1834	105	181	\N	f
1835	105	147	\N	f
1836	105	149	\N	f
1837	105	179	\N	f
1838	106	61	\N	f
1839	106	67	\N	f
1840	106	123	\N	f
1841	106	150	\N	f
1842	106	11	\N	f
1843	106	45	\N	f
1844	106	175	\N	f
1845	106	6	\N	f
1846	106	12	\N	f
1847	106	65	\N	f
1848	106	181	\N	f
1849	106	147	\N	f
1850	106	149	\N	f
1851	106	179	\N	f
1852	107	9	\N	f
1853	107	19	\N	f
1854	107	24	\N	f
1855	107	37	\N	f
1856	107	71	\N	f
1857	107	77	\N	f
1858	107	78	\N	f
1859	107	82	\N	f
1860	107	109	\N	f
1861	107	134	\N	f
1862	107	137	\N	f
1863	107	139	\N	f
1864	107	158	\N	f
1865	107	182	\N	f
1118	71	129	4.00	f
1120	71	137	4.00	f
1121	71	139	4.00	f
1122	71	153	4.00	f
1123	71	158	4.00	f
1125	71	164	4.00	f
1127	71	174	4.00	f
1129	71	178	4.00	f
1131	71	185	4.00	f
1133	71	194	4.00	f
1134	71	197	4.00	f
1137	72	10	4.00	f
1138	72	13	4.00	f
1139	72	16	4.00	f
1142	72	29	4.00	f
1144	72	43	4.00	f
1145	72	46	4.00	f
1146	72	47	4.00	f
1866	107	192	\N	f
1867	107	197	\N	f
1868	107	10	\N	f
1869	107	13	\N	f
1870	107	16	\N	f
1871	107	29	\N	f
1872	107	43	\N	f
1873	107	46	\N	f
1874	107	47	\N	f
1875	107	53	\N	f
1876	107	58	\N	f
1877	107	64	\N	f
1878	107	68	\N	f
1879	107	153	\N	f
1880	107	164	\N	f
1920	112	89	\N	f
1147	72	53	4.00	f
1148	72	58	4.00	f
1149	72	64	4.00	f
1150	72	68	4.00	f
1161	72	153	4.00	f
1164	72	164	4.00	f
1165	72	168	4.00	f
1921	112	128	\N	f
1922	112	40	\N	f
1923	112	92	\N	f
1924	112	195	\N	f
1925	112	120	\N	f
1926	112	86	\N	f
1927	112	62	\N	f
1928	112	159	\N	f
1929	112	114	\N	f
1930	114	89	\N	f
1931	114	17	\N	f
1932	114	40	\N	f
1933	114	114	\N	f
1934	114	120	\N	f
1935	114	130	\N	f
1936	114	86	\N	f
1937	114	62	\N	f
1938	114	128	\N	f
1939	114	92	\N	f
1940	114	159	\N	f
1941	114	195	\N	f
1942	115	130	\N	f
1943	115	89	\N	f
1944	115	62	\N	f
1945	115	40	\N	f
1946	115	86	\N	f
1947	115	128	\N	f
1948	115	92	\N	f
1949	115	159	\N	f
1950	115	195	\N	f
1951	115	120	\N	f
1952	109	12	\N	f
1953	109	41	\N	f
1954	109	88	\N	f
1955	109	95	\N	f
1166	72	174	4.00	f
1168	72	178	4.00	f
1170	72	185	4.00	f
1172	72	194	4.00	f
1174	73	7	4.00	f
886	40	141	4.00	f
1176	73	10	4.00	f
961	44	169	4.00	f
972	45	189	4.00	f
974	45	39	4.00	f
976	45	105	4.00	f
978	45	176	4.00	f
980	46	76	4.00	f
982	46	39	4.00	f
983	46	48	4.00	f
986	46	105	4.00	f
1232	74	82	4.00	f
1233	74	90	4.00	f
1234	74	109	4.00	f
1237	74	137	4.00	f
1238	74	139	4.00	f
1241	74	162	4.00	f
1242	74	164	4.00	f
1243	74	168	4.00	f
1244	74	174	4.00	f
1250	74	194	4.00	f
1251	74	197	4.00	f
409	18	167	1.40	f
461	20	167	1.90	f
561	27	167	1.40	f
128	5	167	3.30	f
194	7	167	1.20	f
161	6	167	2.00	f
440	19	180	3.10	f
562	27	180	2.70	f
130	5	180	3.70	f
163	6	180	3.70	f
1253	75	42	4.00	f
1261	75	12	4.00	f
1265	75	98	4.00	f
1277	77	65	4.00	f
1278	77	67	4.00	f
1279	77	88	4.00	f
1281	77	148	4.00	f
1282	77	150	4.00	f
1286	77	61	4.00	f
1287	77	96	4.00	f
1290	77	123	4.00	f
1291	77	141	4.00	f
1292	77	147	4.00	f
1297	77	181	4.00	f
1300	78	42	4.00	f
1302	78	65	4.00	f
1303	78	123	4.00	f
1309	78	41	4.00	f
1313	78	98	4.00	f
1314	78	147	4.00	f
1315	78	149	4.00	f
1318	79	42	4.00	f
1320	79	88	4.00	f
1323	79	103	4.00	f
1324	79	141	4.00	f
1326	79	150	4.00	f
1328	79	179	4.00	f
1329	79	6	4.00	f
1330	79	12	4.00	f
1332	79	61	4.00	f
1334	79	123	4.00	f
1336	79	173	4.00	f
1339	80	65	4.00	f
1340	80	88	4.00	f
1343	80	103	4.00	f
1348	80	179	4.00	f
1350	80	12	4.00	f
1351	80	45	4.00	f
1357	81	6	4.00	f
1360	81	61	4.00	f
1427	85	6	4.00	f
1428	85	12	4.00	f
1430	85	65	4.00	f
1434	85	181	4.00	f
1440	85	147	4.00	f
1441	85	149	4.00	f
1443	85	179	4.00	f
1448	86	176	4.00	f
1449	86	51	4.00	f
1956	109	96	\N	f
1957	109	98	\N	f
1958	109	141	\N	f
1959	109	147	\N	f
1452	86	169	4.00	f
1960	109	175	\N	f
1961	109	181	\N	f
1962	109	42	\N	f
1963	109	123	\N	f
1964	109	11	\N	f
1965	109	67	\N	f
1966	109	103	\N	f
1967	109	148	\N	f
1968	109	150	\N	f
1969	109	173	\N	f
1970	109	179	\N	f
1971	109	48	\N	f
1972	109	189	\N	f
1973	109	105	\N	f
1974	109	6	\N	f
1975	109	61	\N	f
1976	109	176	\N	f
1977	109	51	\N	f
1978	109	169	\N	f
1979	110	12	\N	f
1980	110	41	\N	f
1981	110	88	\N	f
1982	110	95	\N	f
1983	110	96	\N	f
1984	110	98	\N	f
1985	110	141	\N	f
1986	110	147	\N	f
1987	110	175	\N	f
1988	110	181	\N	f
1989	110	42	\N	f
1990	110	123	\N	f
1991	110	11	\N	f
1992	110	67	\N	f
1993	110	103	\N	f
1994	110	148	\N	f
1995	110	150	\N	f
1996	110	173	\N	f
1997	110	179	\N	f
1998	110	48	\N	f
1999	110	189	\N	f
2000	110	105	\N	f
2001	110	6	\N	f
2002	110	61	\N	f
2003	110	176	\N	f
2004	110	51	\N	f
2005	110	169	\N	f
1482	89	18	\N	f
1483	89	22	\N	f
1484	89	26	\N	f
1485	89	31	\N	f
1486	89	44	\N	f
1487	89	50	\N	f
1488	89	63	\N	f
1489	89	66	\N	f
1490	89	84	\N	f
1491	89	87	\N	f
1492	89	94	\N	f
1493	89	101	\N	f
1494	89	102	\N	f
1495	89	106	\N	f
1496	89	113	\N	f
1497	89	125	\N	f
1498	89	127	\N	f
1499	89	133	\N	f
1500	89	138	\N	f
1501	89	143	\N	f
1502	89	166	\N	f
1503	89	172	\N	f
1504	89	184	\N	f
1505	90	18	\N	f
1506	90	22	\N	f
1507	90	26	\N	f
1508	90	31	\N	f
1509	90	44	\N	f
1510	90	50	\N	f
1511	90	63	\N	f
1512	90	66	\N	f
1513	90	84	\N	f
1514	90	87	\N	f
1515	90	94	\N	f
1516	90	101	\N	f
1517	90	102	\N	f
1518	90	106	\N	f
1519	90	113	\N	f
1520	90	125	\N	f
1521	90	127	\N	f
1522	90	133	\N	f
1523	90	138	\N	f
1524	90	143	\N	f
1525	90	166	\N	f
1526	90	172	\N	f
1527	90	184	\N	f
1528	91	18	\N	f
1529	91	22	\N	f
1530	91	26	\N	f
1531	91	31	\N	f
1532	91	44	\N	f
1533	91	50	\N	f
1534	91	63	\N	f
1535	91	66	\N	f
1536	91	84	\N	f
1537	91	87	\N	f
1538	91	94	\N	f
1539	91	101	\N	f
1540	91	102	\N	f
1541	91	106	\N	f
1542	91	113	\N	f
1454	87	17	4.00	f
1457	87	159	4.00	f
1458	87	163	4.00	f
1460	87	120	4.00	f
1465	87	89	4.00	f
1466	87	70	4.00	f
1467	87	114	4.00	f
1468	87	128	4.00	f
1470	88	86	4.00	f
1473	88	128	4.00	f
1476	88	92	4.00	f
1477	88	159	4.00	f
1479	88	195	4.00	f
1481	88	120	4.00	f
187	7	122	4.00	f
401	18	122	4.00	f
430	19	122	4.00	f
447	20	122	4.00	f
547	27	126	4.00	f
426	19	131	4.00	f
450	20	23	4.00	f
171	7	30	4.00	f
392	18	33	4.00	f
452	20	33	4.00	f
173	7	33	4.00	f
141	6	38	4.00	f
174	7	38	4.00	f
209	8	69	4.00	f
393	18	69	4.00	f
771	35	20	4.00	f
696	28	100	4.00	f
699	28	132	4.00	f
700	28	117	4.00	f
942	42	181	1.40	f
943	43	3	1.30	f
944	43	15	2.80	f
946	43	48	2.50	f
947	43	76	3.70	f
948	43	105	1.60	f
949	43	169	3.30	f
951	43	56	2.40	f
954	43	176	3.20	f
955	44	3	2.60	f
654	32	3	3.50	f
656	32	39	2.70	f
657	32	48	0.00	f
658	32	51	3.50	f
660	32	57	1.30	f
661	32	76	2.60	f
662	32	93	1.80	f
663	32	105	2.50	f
665	32	169	2.10	f
666	32	176	1.40	f
697	28	91	3.40	f
698	28	32	3.30	f
702	28	49	3.70	f
703	28	79	2.70	f
704	28	85	2.40	f
705	28	122	2.00	f
706	28	1	3.40	f
707	28	146	3.60	f
708	28	161	2.00	f
709	28	131	1.90	f
710	28	33	2.70	f
711	28	69	2.90	f
712	28	99	1.40	f
750	34	62	2.80	f
755	34	92	2.00	f
756	34	114	1.60	f
757	34	120	2.10	f
760	34	155	1.30	f
761	34	159	3.10	f
762	34	36	2.60	f
763	34	59	1.20	f
764	34	75	2.40	f
765	34	86	1.80	f
767	34	128	1.30	f
768	34	135	2.80	f
770	35	17	1.50	f
773	35	34	2.30	f
779	35	190	3.10	f
780	35	195	1.80	f
784	35	112	3.70	f
785	35	118	3.20	f
790	35	92	3.60	f
795	36	144	3.60	f
796	36	186	2.80	f
797	36	60	2.20	f
798	36	154	2.10	f
799	37	100	1.70	f
802	37	132	1.70	f
803	37	117	3.10	f
805	37	49	3.70	f
806	37	79	3.10	f
808	37	122	3.50	f
810	37	146	3.80	f
813	37	38	2.70	f
814	37	167	3.90	f
815	37	180	3.40	f
816	37	188	1.10	f
817	37	142	2.90	f
818	37	170	2.20	f
819	37	187	1.70	f
989	47	17	4.00	f
655	32	15	4.00	f
659	32	56	4.00	f
664	32	110	4.00	f
667	32	189	4.00	f
820	37	193	1.70	f
1028	49	12	1.50	f
1029	49	41	3.10	f
1032	49	61	2.00	f
1033	49	65	2.20	f
713	28	81	1.90	f
714	28	38	3.10	f
715	28	167	3.00	f
717	28	188	3.70	f
719	28	170	3.20	f
721	28	193	3.50	f
722	28	8	2.70	f
612	29	3	3.30	f
613	29	15	3.00	f
614	29	39	2.50	f
615	29	48	2.60	f
619	29	76	3.60	f
621	29	105	2.60	f
622	29	110	1.90	f
623	29	169	3.90	f
625	29	189	1.20	f
626	30	3	2.30	f
627	30	15	1.70	f
631	30	56	1.40	f
632	30	57	1.80	f
633	30	76	2.30	f
636	30	110	1.40	f
638	30	176	2.10	f
641	31	15	1.70	f
643	31	48	3.90	f
645	31	56	1.90	f
646	31	57	2.10	f
647	31	76	3.70	f
648	31	93	2.00	f
651	31	169	2.70	f
653	31	189	2.70	f
821	37	8	2.60	f
822	37	28	3.70	f
233	9	21	1.80	f
823	38	100	2.50	f
824	38	91	1.00	f
826	38	132	3.10	f
828	38	115	1.00	f
829	38	49	1.70	f
251	10	21	1.40	f
830	38	79	2.90	f
831	38	85	2.40	f
833	38	1	1.20	f
834	38	146	1.50	f
835	38	33	1.20	f
836	38	69	1.40	f
837	38	38	3.90	f
839	38	180	3.50	f
257	10	171	1.10	f
252	10	35	1.30	f
268	11	35	1.10	f
843	38	187	1.20	f
845	38	8	3.90	f
846	38	28	3.80	f
5	1	21	2.30	f
30	2	21	1.90	f
55	3	21	2.70	f
80	4	21	2.20	f
31	2	35	1.80	f
56	3	35	1.10	f
12	1	108	1.10	f
37	2	108	1.80	f
62	3	108	1.70	f
87	4	108	2.40	f
19	1	171	2.90	f
44	2	171	1.60	f
94	4	171	2.90	f
352	15	155	2.40	f
385	16	155	1.90	f
494	17	155	2.30	f
320	14	156	1.60	f
495	17	156	3.90	f
321	14	159	2.30	f
1034	49	67	3.30	f
1036	49	98	3.40	f
1037	49	123	2.20	f
1038	49	141	2.60	f
448	20	126	3.90	f
570	21	126	2.50	f
156	6	131	2.90	f
189	7	131	1.40	f
404	18	131	2.40	f
449	20	131	3.30	f
548	27	131	2.90	f
571	21	131	1.70	f
123	5	131	3.80	f
222	8	131	2.70	f
406	18	23	3.00	f
432	19	23	3.70	f
554	27	23	3.70	f
572	21	23	2.40	f
169	7	23	2.60	f
103	5	23	3.30	f
136	6	23	1.80	f
202	8	23	2.20	f
204	8	30	3.90	f
434	19	30	3.30	f
451	20	30	2.20	f
556	27	30	2.20	f
573	21	30	2.70	f
105	5	30	3.60	f
138	6	30	1.10	f
107	5	33	2.50	f
140	6	33	3.90	f
416	19	33	3.90	f
538	27	33	1.10	f
574	21	33	2.10	f
206	8	33	3.50	f
108	5	38	2.80	f
207	8	38	2.80	f
453	20	38	1.00	f
575	21	38	3.90	f
110	5	69	3.50	f
143	6	69	3.10	f
454	20	69	3.20	f
540	27	69	2.10	f
116	5	99	2.30	f
149	6	99	3.60	f
215	8	99	1.40	f
413	18	188	2.50	f
441	19	188	2.90	f
563	27	188	1.10	f
585	21	188	2.00	f
198	7	188	1.50	f
231	8	188	1.60	f
165	6	188	3.70	f
408	18	142	2.10	f
464	20	142	3.90	f
125	5	142	3.30	f
158	6	142	3.00	f
224	8	142	1.40	f
191	7	142	2.80	f
410	18	170	1.10	f
587	21	170	3.30	f
129	5	170	3.40	f
162	6	170	3.40	f
228	8	170	3.20	f
195	7	170	1.70	f
412	18	187	3.80	f
438	19	187	1.50	f
466	20	187	3.00	f
560	27	187	2.20	f
588	21	187	1.10	f
131	5	187	3.90	f
164	6	187	3.90	f
230	8	187	2.40	f
197	7	187	1.30	f
414	18	193	2.20	f
467	20	193	1.80	f
133	5	193	1.70	f
166	6	193	3.10	f
199	7	193	1.20	f
234	9	60	1.40	f
505	25	60	1.40	f
8	1	60	1.80	f
83	4	60	3.80	f
1040	49	149	1.30	f
1042	49	175	3.60	f
1043	49	179	1.40	f
1044	49	181	2.30	f
1045	50	3	2.20	f
1046	50	76	1.60	f
1048	50	39	2.70	f
1049	50	48	3.70	f
1054	50	189	3.70	f
1057	51	60	1.50	f
1058	51	154	1.30	f
1059	51	97	2.20	f
1060	51	17	3.20	f
1061	51	40	2.90	f
1062	51	73	3.10	f
1063	51	92	1.20	f
1066	51	159	3.30	f
1067	51	86	1.80	f
1069	51	62	1.40	f
1071	51	163	3.50	f
1072	51	195	3.30	f
1074	51	120	2.20	f
1075	51	75	1.10	f
1077	51	135	1.40	f
1079	52	40	3.40	f
1080	52	73	3.60	f
1083	52	155	1.60	f
1085	52	86	2.20	f
1087	52	62	1.90	f
1088	52	70	2.50	f
1089	52	163	2.70	f
1090	52	195	1.90	f
1091	52	114	1.60	f
1094	52	128	1.50	f
1095	52	135	3.60	f
117	5	100	3.30	f
150	6	100	2.70	f
397	18	100	3.70	f
216	8	100	2.80	f
701	28	115	4.00	f
716	28	180	4.00	f
718	28	142	4.00	f
720	28	187	4.00	f
723	28	28	4.00	f
616	29	51	4.00	f
617	29	56	4.00	f
618	29	57	4.00	f
620	29	93	4.00	f
624	29	176	4.00	f
628	30	39	4.00	f
629	30	48	4.00	f
630	30	51	4.00	f
634	30	93	4.00	f
635	30	105	4.00	f
637	30	169	4.00	f
639	30	189	4.00	f
640	31	3	4.00	f
642	31	39	4.00	f
644	31	51	4.00	f
649	31	105	4.00	f
650	31	110	4.00	f
652	31	176	4.00	f
727	33	62	4.00	f
728	33	70	4.00	f
730	33	163	4.00	f
731	33	195	4.00	f
733	33	114	4.00	f
734	33	120	4.00	f
741	33	75	4.00	f
744	33	128	4.00	f
745	33	135	4.00	f
751	34	70	4.00	f
752	34	73	4.00	f
753	34	163	4.00	f
754	34	195	4.00	f
758	34	124	4.00	f
759	34	130	4.00	f
772	35	27	4.00	f
774	35	36	4.00	f
775	35	40	4.00	f
776	35	59	4.00	f
777	35	62	4.00	f
778	35	159	4.00	f
781	35	163	4.00	f
782	35	86	4.00	f
783	35	89	4.00	f
786	35	119	4.00	f
787	35	124	4.00	f
788	35	140	4.00	f
789	35	75	4.00	f
791	35	107	4.00	f
792	35	128	4.00	f
793	35	156	4.00	f
794	36	97	4.00	f
800	37	91	4.00	f
801	37	32	4.00	f
804	37	115	4.00	f
807	37	85	4.00	f
809	37	1	4.00	f
811	37	33	4.00	f
812	37	69	4.00	f
6	1	35	4.00	f
81	4	35	4.00	f
825	38	32	4.00	f
827	38	117	4.00	f
832	38	122	4.00	f
838	38	167	4.00	f
840	38	188	4.00	f
841	38	142	4.00	f
842	38	170	4.00	f
844	38	193	4.00	f
69	3	171	4.00	f
326	15	17	4.00	f
328	15	27	4.00	f
471	17	34	4.00	f
297	14	36	4.00	f
475	17	59	4.00	f
300	14	59	4.00	f
476	17	62	4.00	f
477	17	70	4.00	f
478	17	73	4.00	f
304	14	75	4.00	f
370	16	75	4.00	f
480	17	86	4.00	f
305	14	86	4.00	f
306	14	89	4.00	f
340	15	92	4.00	f
373	16	92	4.00	f
374	16	107	4.00	f
342	15	112	4.00	f
484	17	112	4.00	f
485	17	114	4.00	f
486	17	118	4.00	f
488	17	120	4.00	f
315	14	128	4.00	f
381	16	128	4.00	f
259	10	196	4.00	f
276	11	196	4.00	f
47	2	196	4.00	f
237	9	5	4.00	f
28	2	5	4.00	f
239	9	72	4.00	f
34	2	72	4.00	f
84	4	72	4.00	f
4	1	14	4.00	f
109	5	49	4.00	f
175	7	49	4.00	f
1035	49	96	4.00	f
177	7	79	4.00	f
419	19	79	4.00	f
145	6	81	4.00	f
178	7	81	4.00	f
394	18	81	4.00	f
444	20	81	4.00	f
114	5	85	4.00	f
567	21	85	4.00	f
118	5	104	4.00	f
184	7	104	4.00	f
398	18	104	4.00	f
446	20	104	4.00	f
589	21	193	4.00	f
232	8	193	4.00	f
270	11	60	4.00	f
281	12	60	4.00	f
33	2	60	4.00	f
32	2	54	4.00	f
82	4	54	4.00	f
277	11	97	4.00	f
283	12	97	4.00	f
86	4	97	4.00	f
519	24	97	4.00	f
24	1	199	4.00	f
14	1	144	4.00	f
64	3	144	4.00	f
284	12	144	4.00	f
39	2	144	4.00	f
523	24	186	4.00	f
46	2	186	4.00	f
71	3	186	4.00	f
272	11	74	4.00	f
289	12	74	4.00	f
511	25	154	4.00	f
597	26	154	4.00	f
93	4	154	4.00	f
68	3	154	4.00	f
848	39	11	4.00	f
849	39	12	4.00	f
852	39	45	4.00	f
853	39	61	4.00	f
858	39	96	4.00	f
859	39	98	4.00	f
860	39	103	4.00	f
861	39	123	4.00	f
862	39	141	4.00	f
863	39	147	4.00	f
865	39	149	4.00	f
867	39	173	4.00	f
868	39	175	4.00	f
869	39	179	4.00	f
870	39	181	4.00	f
872	40	11	4.00	f
875	40	42	4.00	f
879	40	67	4.00	f
884	40	103	4.00	f
885	40	123	4.00	f
888	40	148	4.00	f
890	40	150	4.00	f
891	40	173	4.00	f
893	40	179	4.00	f
895	41	6	4.00	f
898	41	41	4.00	f
901	41	61	4.00	f
903	41	67	4.00	f
906	41	96	4.00	f
907	41	98	4.00	f
911	41	147	4.00	f
913	41	149	4.00	f
916	41	175	4.00	f
919	42	6	4.00	f
921	42	12	4.00	f
924	42	45	4.00	f
925	42	61	4.00	f
930	42	96	4.00	f
933	42	123	4.00	f
935	42	147	4.00	f
939	42	173	4.00	f
945	43	39	4.00	f
950	43	51	4.00	f
952	43	57	4.00	f
953	43	93	4.00	f
956	44	15	4.00	f
990	47	40	4.00	f
992	47	92	4.00	f
995	47	159	4.00	f
1000	47	163	4.00	f
1001	47	195	4.00	f
1002	47	114	4.00	f
1003	47	120	4.00	f
1008	48	11	4.00	f
1010	48	41	4.00	f
1011	48	42	4.00	f
1012	48	45	4.00	f
1017	48	98	4.00	f
1020	48	147	4.00	f
1021	48	149	4.00	f
1023	48	175	4.00	f
1024	48	179	4.00	f
1030	49	42	4.00	f
1031	49	45	4.00	f
1039	49	147	4.00	f
1041	49	150	4.00	f
1047	50	176	4.00	f
1050	50	51	4.00	f
1051	50	93	4.00	f
1052	50	105	4.00	f
1053	50	169	4.00	f
1055	51	144	4.00	f
1056	51	186	4.00	f
1064	51	130	4.00	f
1065	51	155	4.00	f
1068	51	89	4.00	f
1070	51	70	4.00	f
1073	51	114	4.00	f
1076	51	128	4.00	f
1078	52	17	4.00	f
1081	52	92	4.00	f
1082	52	130	4.00	f
1084	52	159	4.00	f
1086	52	89	4.00	f
1092	52	120	4.00	f
1093	52	75	4.00	f
183	7	100	4.00	f
301	14	62	4.00	f
293	14	17	2.50	f
359	16	17	2.50	f
468	17	17	3.40	f
294	14	20	2.70	f
327	15	20	1.40	f
360	16	20	3.80	f
469	17	20	2.00	f
470	17	27	2.60	f
295	14	27	1.40	f
361	16	27	2.10	f
296	14	34	1.20	f
329	15	34	3.70	f
362	16	34	3.40	f
472	17	36	3.30	f
330	15	36	3.50	f
363	16	36	3.50	f
473	17	40	1.10	f
298	14	40	2.60	f
331	15	40	1.40	f
364	16	40	2.50	f
474	17	55	1.10	f
299	14	55	1.70	f
332	15	55	1.10	f
365	16	55	1.60	f
333	15	59	3.00	f
366	16	59	2.60	f
334	15	62	1.30	f
367	16	62	2.60	f
302	14	70	2.40	f
335	15	70	2.20	f
368	16	70	1.00	f
303	14	73	3.20	f
70	3	183	4.00	f
388	16	163	4.00	f
356	15	190	4.00	f
498	17	190	4.00	f
325	14	195	4.00	f
500	17	195	4.00	f
20	1	183	4.00	f
45	2	183	4.00	f
354	15	159	3.00	f
387	16	159	3.50	f
496	17	159	3.90	f
322	14	163	3.10	f
355	15	163	2.70	f
497	17	163	3.90	f
323	14	190	1.20	f
389	16	190	2.00	f
324	14	191	1.90	f
357	15	191	1.80	f
390	16	191	1.60	f
499	17	191	2.00	f
358	15	195	2.30	f
391	16	195	2.90	f
264	10	183	2.30	f
274	11	183	1.70	f
95	4	183	2.80	f
504	25	183	3.40	f
235	9	2	1.10	f
265	11	2	2.90	f
246	10	2	3.40	f
501	25	2	2.10	f
26	2	2	2.50	f
51	3	2	2.70	f
520	24	200	4.00	f
280	11	200	4.00	f
1	1	2	4.00	f
236	9	4	4.00	f
514	24	4	4.00	f
288	12	200	4.00	f
75	3	200	4.00	f
290	12	136	4.00	f
88	4	136	4.00	f
76	4	2	1.70	f
513	24	2	2.50	f
267	11	4	3.50	f
249	10	4	3.30	f
502	25	4	3.20	f
2	1	4	1.80	f
27	2	4	2.20	f
52	3	4	1.10	f
77	4	4	2.70	f
510	25	200	1.70	f
261	10	200	3.50	f
25	1	200	1.00	f
50	2	200	3.80	f
100	4	200	2.20	f
521	24	136	2.20	f
244	9	136	3.20	f
262	10	136	2.90	f
278	11	136	2.50	f
13	1	136	3.50	f
38	2	136	3.80	f
63	3	136	3.00	f
255	10	145	1.40	f
273	11	145	2.00	f
65	3	145	3.10	f
15	1	145	3.30	f
90	4	145	3.60	f
241	9	145	3.20	f
40	2	145	3.50	f
524	13	145	2.70	f
245	9	196	3.90	f
97	4	196	2.40	f
72	3	196	1.40	f
22	1	196	1.50	f
516	24	196	3.10	f
525	13	196	1.80	f
247	10	5	3.30	f
266	11	5	2.10	f
503	25	5	1.20	f
78	4	5	3.80	f
53	3	5	3.20	f
3	1	5	3.10	f
526	13	5	2.30	f
248	10	72	2.80	f
271	11	72	2.30	f
9	1	72	3.10	f
59	3	72	2.50	f
515	24	72	2.70	f
527	13	72	3.50	f
250	10	14	3.70	f
66	3	151	4.00	f
537	13	152	4.00	f
17	1	152	4.00	f
260	10	198	4.00	f
243	9	198	4.00	f
23	1	198	4.00	f
48	2	198	4.00	f
285	12	151	4.00	f
522	24	152	4.00	f
291	12	152	4.00	f
42	2	152	4.00	f
212	8	83	4.00	f
214	8	91	4.00	f
421	19	91	4.00	f
29	2	14	1.70	f
54	3	14	1.80	f
79	4	14	2.00	f
528	13	14	3.90	f
512	24	198	3.20	f
531	13	198	1.70	f
73	3	198	1.20	f
98	4	198	1.10	f
532	13	151	2.50	f
16	1	151	3.30	f
41	2	151	1.80	f
91	4	151	1.50	f
242	9	152	1.20	f
256	10	152	2.10	f
67	3	152	3.30	f
92	4	152	2.00	f
113	5	83	2.30	f
146	6	83	1.30	f
179	7	83	2.80	f
395	18	83	3.10	f
420	19	83	3.90	f
542	27	83	1.10	f
115	5	91	2.90	f
148	6	91	2.90	f
181	7	91	3.50	f
543	27	91	3.80	f
153	6	117	4.00	f
219	8	117	4.00	f
546	27	117	4.00	f
551	27	115	4.00	f
152	6	115	4.00	f
435	19	132	4.00	f
120	5	117	1.70	f
186	7	117	3.60	f
400	18	117	1.10	f
424	19	117	1.30	f
106	5	32	1.40	f
172	7	32	2.30	f
205	8	32	3.90	f
428	19	32	2.20	f
550	27	32	2.40	f
139	6	32	2.60	f
119	5	115	3.30	f
185	7	115	1.70	f
218	8	115	2.40	f
399	18	115	3.20	f
429	19	115	2.70	f
124	5	132	1.70	f
403	18	132	2.70	f
557	27	132	2.30	f
157	6	132	2.70	f
190	7	132	1.30	f
223	8	132	3.10	f
443	20	79	4.00	f
220	8	122	4.00	f
142	6	49	3.30	f
208	8	49	1.10	f
417	19	49	1.50	f
442	20	49	3.10	f
539	27	49	2.00	f
564	21	49	2.20	f
111	5	79	3.70	f
144	6	79	2.30	f
541	27	79	2.60	f
565	21	79	1.30	f
210	8	79	2.30	f
112	5	81	2.10	f
211	8	81	2.00	f
566	21	81	3.30	f
147	6	85	3.00	f
180	7	85	3.00	f
213	8	85	1.30	f
445	20	85	3.90	f
151	6	104	1.20	f
217	8	104	1.40	f
423	19	104	1.30	f
545	27	104	3.60	f
568	21	104	1.60	f
121	5	122	2.10	f
552	27	122	1.20	f
569	21	122	1.10	f
154	6	122	2.10	f
122	5	126	1.60	f
155	6	126	1.70	f
188	7	126	2.50	f
221	8	126	2.70	f
402	18	126	2.50	f
425	19	126	2.40	f
579	21	8	4.00	f
168	7	8	4.00	f
422	19	99	3.80	f
455	20	99	2.30	f
544	27	99	3.80	f
577	21	99	2.10	f
182	7	99	3.10	f
427	19	1	2.30	f
456	20	1	3.90	f
549	27	1	1.20	f
578	21	1	3.10	f
134	6	1	3.50	f
167	7	1	1.90	f
405	18	8	1.90	f
553	27	8	3.00	f
102	5	8	3.40	f
201	8	8	1.20	f
407	18	28	3.80	f
433	19	28	3.10	f
458	20	28	3.00	f
555	27	28	3.00	f
580	21	28	3.30	f
415	18	146	2.30	f
436	19	146	3.30	f
459	20	146	2.70	f
558	27	146	1.10	f
581	21	146	2.40	f
159	6	146	2.70	f
192	7	146	1.40	f
225	8	146	3.70	f
126	5	146	1.30	f
437	19	161	3.00	f
460	20	161	1.10	f
559	27	161	2.00	f
582	21	161	1.60	f
160	6	161	3.40	f
193	7	161	3.40	f
336	15	73	3.90	f
369	16	73	1.70	f
479	17	75	2.70	f
337	15	75	1.60	f
338	15	86	2.20	f
371	16	86	3.10	f
339	15	89	3.60	f
372	16	89	2.90	f
481	17	89	3.20	f
307	14	92	2.90	f
482	17	92	3.30	f
308	14	107	1.70	f
341	15	107	3.00	f
483	17	107	2.10	f
309	14	112	1.50	f
375	16	112	3.30	f
310	14	114	3.60	f
343	15	114	1.50	f
376	16	114	1.30	f
311	14	118	1.70	f
344	15	118	2.90	f
377	16	118	2.50	f
312	14	119	1.90	f
345	15	119	2.30	f
378	16	119	3.10	f
487	17	119	1.70	f
313	14	120	2.40	f
346	15	120	1.90	f
379	16	120	1.90	f
314	14	124	2.80	f
347	15	124	3.90	f
380	16	124	3.00	f
489	17	124	2.30	f
348	15	128	2.80	f
316	14	130	2.10	f
382	16	130	1.70	f
491	17	130	2.10	f
350	15	135	3.80	f
383	16	135	1.40	f
492	17	135	1.60	f
351	15	140	3.60	f
384	16	140	3.30	f
493	17	140	2.20	f
319	14	155	3.00	f
592	26	97	2.30	f
533	13	199	2.50	f
593	26	199	1.00	f
287	12	199	2.30	f
49	2	199	2.20	f
74	3	199	1.20	f
99	4	199	2.60	f
263	10	144	1.30	f
240	9	144	3.00	f
518	24	144	2.10	f
535	13	144	1.40	f
594	26	144	3.10	f
89	4	144	1.20	f
508	25	186	1.50	f
595	26	186	2.10	f
275	11	186	1.60	f
21	1	186	3.80	f
58	3	60	2.70	f
529	13	60	3.80	f
590	26	60	2.90	f
238	9	54	3.50	f
253	10	54	2.60	f
269	11	54	1.80	f
506	25	54	1.20	f
282	12	54	1.80	f
7	1	54	1.50	f
57	3	54	3.00	f
517	24	54	3.30	f
530	13	54	2.30	f
591	26	54	1.10	f
507	25	97	1.60	f
254	10	97	3.10	f
11	1	97	2.50	f
36	2	97	1.30	f
61	3	97	2.10	f
258	10	186	3.70	f
286	12	186	3.00	f
96	4	186	2.30	f
509	25	74	1.40	f
536	13	74	3.90	f
596	26	74	1.10	f
60	3	74	1.80	f
490	17	128	4.00	f
349	15	130	4.00	f
317	14	135	4.00	f
318	14	140	4.00	f
353	15	156	4.00	f
386	16	156	4.00	f
418	19	69	4.00	f
576	21	69	4.00	f
176	7	69	4.00	f
396	18	99	4.00	f
101	5	1	4.00	f
200	8	1	4.00	f
431	19	8	4.00	f
457	20	8	4.00	f
135	6	8	4.00	f
203	8	28	4.00	f
104	5	28	4.00	f
137	6	28	4.00	f
170	7	28	4.00	f
127	5	161	4.00	f
226	8	161	4.00	f
439	19	167	4.00	f
583	21	167	4.00	f
227	8	167	4.00	f
411	18	180	4.00	f
462	20	180	4.00	f
584	21	180	4.00	f
196	7	180	4.00	f
229	8	180	4.00	f
463	20	188	4.00	f
132	5	188	4.00	f
586	21	142	4.00	f
465	20	170	4.00	f
85	4	74	2.40	f
10	1	74	3.20	f
35	2	74	3.00	f
534	13	154	1.50	f
18	1	154	2.30	f
43	2	154	3.20	f
279	11	154	1.40	f
292	12	154	3.30	f
\.


--
-- Data for Name: seminar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seminar (seminarkey, locationkey, theme, seminardate, description) FROM stdin;
\.


--
-- Data for Name: seminardetails; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seminardetails (seminardetailkey, seminarkey, topic, presenttime, room, instructorkey, description) FROM stdin;
\.


--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status (statuskey, statusname) FROM stdin;
1	current
2	hiatus
3	completed
4	unknown
\.


--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student (studentkey, personkey, studentstartdate, statuskey) FROM stdin;
1	201	2017-09-14	1
2	202	2017-08-19	1
3	203	2018-04-17	1
4	204	2017-07-10	1
5	205	2017-08-15	1
6	206	2018-08-10	1
7	207	2018-11-24	1
8	208	2017-12-08	1
9	209	2018-11-10	1
10	210	2018-11-06	1
11	211	2018-09-27	1
12	212	2018-07-01	1
13	213	2018-10-30	1
14	214	2017-06-25	1
15	215	2018-06-18	1
16	216	2018-12-22	1
17	217	2018-01-08	1
18	218	2019-04-20	1
19	219	2018-11-04	1
20	220	2018-02-07	1
21	221	2017-07-22	1
22	222	2019-01-19	1
23	223	2017-11-25	1
24	224	2018-10-25	1
25	225	2019-05-27	1
26	226	2019-01-24	1
27	227	2018-02-07	1
28	228	2017-10-11	1
29	229	2018-11-18	1
30	230	2017-10-21	1
31	231	2019-01-29	1
32	232	2017-11-03	1
33	233	2017-09-14	1
34	234	2018-02-03	1
36	236	2018-01-03	1
37	237	2018-10-27	1
38	238	2017-09-03	1
39	239	2018-06-01	1
40	240	2018-03-14	1
41	241	2018-09-29	1
42	242	2018-08-29	1
43	243	2019-01-02	1
44	244	2019-02-15	1
45	245	2018-08-19	1
46	246	2018-12-03	1
47	247	2018-11-20	1
48	248	2018-06-17	1
49	249	2017-11-01	1
50	250	2019-03-17	1
51	251	2018-05-22	1
52	252	2019-06-08	1
53	253	2018-12-31	1
54	254	2017-08-27	1
55	255	2018-02-10	1
56	256	2018-06-04	1
57	257	2018-06-22	1
58	258	2019-01-03	1
59	259	2018-02-11	1
60	260	2017-08-04	1
61	261	2018-07-16	1
62	262	2018-03-09	1
63	263	2019-02-10	1
64	264	2018-11-25	1
65	265	2018-09-15	1
66	266	2019-03-22	1
67	267	2018-09-27	1
68	268	2018-10-12	1
69	269	2017-10-15	1
70	270	2018-01-14	1
71	271	2018-11-11	1
72	272	2017-06-25	1
73	273	2018-03-30	1
75	275	2018-03-02	1
76	276	2018-05-31	1
77	277	2018-10-30	1
78	278	2018-10-11	1
79	279	2017-12-19	1
80	280	2019-05-06	1
81	281	2017-09-30	1
82	282	2018-10-07	1
83	283	2017-10-02	1
84	284	2019-02-27	1
85	285	2017-11-23	1
86	286	2018-03-20	1
87	287	2019-02-09	1
88	288	2018-07-25	1
89	289	2018-03-29	1
90	290	2019-01-11	1
91	291	2017-10-02	1
92	292	2018-03-20	1
93	293	2018-05-24	1
94	294	2019-03-30	1
95	295	2018-07-15	1
96	296	2018-09-29	1
97	297	2017-08-11	1
98	298	2018-07-28	1
99	299	2017-12-08	1
100	300	2017-11-06	1
101	301	2019-04-21	1
102	302	2019-03-13	1
103	303	2018-08-14	1
104	304	2017-10-13	1
105	305	2018-05-25	1
106	306	2019-03-26	1
107	307	2018-03-10	1
109	309	2018-11-20	1
110	310	2018-04-26	1
111	311	2019-06-08	1
112	312	2018-04-08	1
113	313	2019-04-04	1
114	314	2018-03-25	1
115	315	2017-10-26	1
116	316	2019-05-30	1
117	317	2017-11-16	1
118	318	2018-02-12	1
119	319	2018-03-07	1
120	320	2018-01-29	1
121	321	2019-06-08	1
122	322	2017-09-11	1
123	323	2018-07-28	1
124	324	2018-04-01	1
125	325	2019-03-13	1
126	326	2017-11-03	1
127	327	2019-04-12	1
128	328	2018-04-07	1
129	329	2018-12-21	1
130	330	2018-03-16	1
131	331	2017-10-06	1
132	332	2017-12-26	1
133	333	2019-02-06	1
134	334	2018-12-30	1
135	335	2018-01-12	1
136	336	2017-08-08	1
137	337	2018-11-23	1
138	338	2019-03-12	1
139	339	2018-10-19	1
140	340	2018-02-15	1
141	341	2018-07-25	1
142	342	2017-10-08	1
143	343	2019-03-07	1
144	344	2017-07-12	1
145	345	2017-08-10	1
146	346	2017-09-04	1
147	347	2018-07-04	1
148	348	2018-09-18	1
149	349	2018-08-04	1
150	350	2018-08-13	1
151	351	2017-08-04	1
152	352	2017-07-22	1
153	353	2018-12-14	1
154	354	2017-07-01	1
155	355	2018-01-05	1
156	356	2018-02-15	1
157	357	2019-05-15	1
158	358	2018-10-22	1
159	359	2018-04-08	1
160	360	2019-05-21	1
161	361	2017-12-11	1
162	362	2018-10-25	1
163	363	2018-01-17	1
164	364	2018-10-09	1
165	365	2019-05-12	1
166	366	2019-03-05	1
167	367	2017-09-04	1
168	368	2018-11-19	1
169	369	2018-05-05	1
170	370	2017-10-06	1
172	372	2019-04-21	1
173	373	2018-09-18	1
174	374	2018-12-02	1
175	375	2018-08-28	1
176	376	2018-05-10	1
177	377	2018-12-06	1
178	378	2018-11-27	1
179	379	2018-07-24	1
180	380	2017-10-26	1
181	381	2018-09-16	1
182	382	2018-10-01	1
184	384	2019-02-27	1
185	385	2018-12-31	1
187	387	2017-09-12	1
188	388	2017-09-11	1
189	389	2018-06-29	1
190	390	2018-04-08	1
191	391	2018-02-21	1
192	392	2018-12-31	1
193	393	2017-12-01	1
194	394	2018-10-20	1
195	395	2018-02-02	1
196	396	2017-07-07	1
197	397	2018-10-20	1
200	400	2017-07-07	1
35	235	2017-07-11	4
74	274	2017-06-18	4
108	308	2017-06-17	4
171	371	2017-07-27	4
183	383	2017-08-22	4
186	386	2017-07-02	4
198	398	2017-08-16	4
199	399	2017-06-30	4
203	405	2019-01-02	1
205	411	2019-03-07	1
207	413	2019-03-07	1
208	414	2019-03-07	4
\.


--
-- Data for Name: substitution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.substitution (substitutionkey, certificatekey, coursekey, substitutekey, studentkey, certadminkey) FROM stdin;
\.


--
-- Name: attendance_attendancekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_attendancekey_seq', 1, false);


--
-- Name: businessrule_businessrulekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.businessrule_businessrulekey_seq', 16, true);


--
-- Name: certadmin_certadminkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.certadmin_certadminkey_seq', 4, true);


--
-- Name: certificate_certificatekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.certificate_certificatekey_seq', 19, true);


--
-- Name: course_coursekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_coursekey_seq', 28, true);


--
-- Name: coursesection_sectionkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coursesection_sectionkey_seq', 115, true);


--
-- Name: instructionalarea_instructionalareakey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructionalarea_instructionalareakey_seq', 6, true);


--
-- Name: instructor_instructorkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_instructorkey_seq', 11, true);


--
-- Name: location_locationkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.location_locationkey_seq', 1, false);


--
-- Name: loginhistory_loginhistorykey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.loginhistory_loginhistorykey_seq', 1, false);


--
-- Name: logintable_logintablekey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logintable_logintablekey_seq', 219, true);


--
-- Name: person_personkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_personkey_seq', 414, true);


--
-- Name: pricehistory_pricehistorykey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pricehistory_pricehistorykey_seq', 3, true);


--
-- Name: quarter_quarterkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quarter_quarterkey_seq', 4, true);


--
-- Name: roster_rosterkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roster_rosterkey_seq', 2005, true);


--
-- Name: seminar_seminarkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seminar_seminarkey_seq', 1, false);


--
-- Name: seminardetails_seminardetailkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seminardetails_seminardetailkey_seq', 1, false);


--
-- Name: status_statuskey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_statuskey_seq', 4, true);


--
-- Name: student_studentkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_studentkey_seq', 208, true);


--
-- Name: substitution_substitutionkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.substitution_substitutionkey_seq', 1, false);


--
-- Name: attendance attendancekey_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendancekey_pk PRIMARY KEY (attendancekey);


--
-- Name: businessrule businessrule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.businessrule
    ADD CONSTRAINT businessrule_pkey PRIMARY KEY (businessrulekey);


--
-- Name: certadmin certadmin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certadmin
    ADD CONSTRAINT certadmin_pkey PRIMARY KEY (certadminkey);


--
-- Name: certificate certificate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificate
    ADD CONSTRAINT certificate_pkey PRIMARY KEY (certificatekey);


--
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (coursekey);


--
-- Name: coursesection coursesection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coursesection
    ADD CONSTRAINT coursesection_pkey PRIMARY KEY (sectionkey);


--
-- Name: instructionalarea instructionalarea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructionalarea
    ADD CONSTRAINT instructionalarea_pkey PRIMARY KEY (instructionalareakey);


--
-- Name: instructor instructor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_pkey PRIMARY KEY (instructorkey);


--
-- Name: location location_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_email_key UNIQUE (email);


--
-- Name: location location_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pk PRIMARY KEY (locationkey);


--
-- Name: loginhistory loginhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loginhistory
    ADD CONSTRAINT loginhistory_pkey PRIMARY KEY (loginhistorykey);


--
-- Name: logintable logintable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logintable
    ADD CONSTRAINT logintable_pkey PRIMARY KEY (logintablekey);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (personkey);


--
-- Name: certificatecourse pk_certificatecourse; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificatecourse
    ADD CONSTRAINT pk_certificatecourse PRIMARY KEY (certificatekey, coursekey);


--
-- Name: instructorarea pk_instructorarea; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructorarea
    ADD CONSTRAINT pk_instructorarea PRIMARY KEY (instructionalareakey, instructorkey);


--
-- Name: pricehistory pricehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pricehistory
    ADD CONSTRAINT pricehistory_pkey PRIMARY KEY (pricehistorykey);


--
-- Name: quarter quarter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quarter
    ADD CONSTRAINT quarter_pkey PRIMARY KEY (quarterkey);


--
-- Name: roster roster_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster
    ADD CONSTRAINT roster_pkey PRIMARY KEY (rosterkey);


--
-- Name: seminar seminar_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seminar
    ADD CONSTRAINT seminar_pk PRIMARY KEY (seminarkey);


--
-- Name: seminardetails seminardetails_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seminardetails
    ADD CONSTRAINT seminardetails_pkey PRIMARY KEY (seminardetailkey);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (statuskey);


--
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (studentkey);


--
-- Name: substitution substitution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.substitution
    ADD CONSTRAINT substitution_pkey PRIMARY KEY (substitutionkey);


--
-- Name: person unique_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- Name: coursesection_coursekey_quarterkey_sectionyear_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX coursesection_coursekey_quarterkey_sectionyear_idx ON public.coursesection USING btree (coursekey, quarterkey, sectionyear);


--
-- Name: person_lastname_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX person_lastname_idx ON public.person USING btree (lastname);


--
-- Name: roster_studentkey_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX roster_studentkey_idx ON public.roster USING btree (studentkey);


--
-- Name: roster fire_fgf; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER fire_fgf AFTER UPDATE ON public.roster FOR EACH ROW EXECUTE PROCEDURE public.setflag();


--
-- Name: roster fires_finalgradeflag; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER fires_finalgradeflag AFTER UPDATE ON public.roster FOR EACH ROW EXECUTE PROCEDURE public.setflag();


--
-- Name: roster fires_flag_finalgrade; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER fires_flag_finalgrade AFTER UPDATE ON public.roster FOR EACH ROW EXECUTE PROCEDURE public.setflag2();


--
-- Name: roster flag_finalgrade; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER flag_finalgrade AFTER INSERT ON public.roster FOR EACH ROW EXECUTE PROCEDURE public.setflag();


--
-- Name: certadmin certadmin_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certadmin
    ADD CONSTRAINT certadmin_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: certadmin certadmin_statuskey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certadmin
    ADD CONSTRAINT certadmin_statuskey_fkey FOREIGN KEY (statuskey) REFERENCES public.status(statuskey);


--
-- Name: certificatecourse certificatecourse_certificatekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificatecourse
    ADD CONSTRAINT certificatecourse_certificatekey_fkey FOREIGN KEY (certificatekey) REFERENCES public.certificate(certificatekey);


--
-- Name: certificatecourse certificatecourse_coursekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificatecourse
    ADD CONSTRAINT certificatecourse_coursekey_fkey FOREIGN KEY (coursekey) REFERENCES public.course(coursekey);


--
-- Name: coursesection coursesection_coursekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coursesection
    ADD CONSTRAINT coursesection_coursekey_fkey FOREIGN KEY (coursekey) REFERENCES public.course(coursekey);


--
-- Name: coursesection coursesection_instructorkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coursesection
    ADD CONSTRAINT coursesection_instructorkey_fkey FOREIGN KEY (instructorkey) REFERENCES public.instructor(instructorkey);


--
-- Name: coursesection fk_price; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coursesection
    ADD CONSTRAINT fk_price FOREIGN KEY (pricehistorykey) REFERENCES public.pricehistory(pricehistorykey);


--
-- Name: coursesection fk_quarter; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coursesection
    ADD CONSTRAINT fk_quarter FOREIGN KEY (quarterkey) REFERENCES public.quarter(quarterkey);


--
-- Name: instructor instructor_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: instructor instructor_statuskey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_statuskey_fkey FOREIGN KEY (statuskey) REFERENCES public.status(statuskey);


--
-- Name: instructorarea instructorarea_instructionalareakey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructorarea
    ADD CONSTRAINT instructorarea_instructionalareakey_fkey FOREIGN KEY (instructionalareakey) REFERENCES public.instructionalarea(instructionalareakey);


--
-- Name: instructorarea instructorarea_instructorkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructorarea
    ADD CONSTRAINT instructorarea_instructorkey_fkey FOREIGN KEY (instructorkey) REFERENCES public.instructor(instructorkey);


--
-- Name: seminardetails instructorkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seminardetails
    ADD CONSTRAINT instructorkey_fk FOREIGN KEY (instructorkey) REFERENCES public.instructor(instructorkey);


--
-- Name: seminar location_locationkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seminar
    ADD CONSTRAINT location_locationkey_fk FOREIGN KEY (locationkey) REFERENCES public.location(locationkey) ON UPDATE CASCADE;


--
-- Name: loginhistory loginhistory_logintablekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loginhistory
    ADD CONSTRAINT loginhistory_logintablekey_fkey FOREIGN KEY (logintablekey) REFERENCES public.logintable(logintablekey);


--
-- Name: logintable logintable_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logintable
    ADD CONSTRAINT logintable_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: attendance person_personkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT person_personkey_fk FOREIGN KEY (personkey) REFERENCES public.person(personkey) ON UPDATE CASCADE;


--
-- Name: roster roster_sectionkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster
    ADD CONSTRAINT roster_sectionkey_fkey FOREIGN KEY (sectionkey) REFERENCES public.coursesection(sectionkey);


--
-- Name: roster roster_studentkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roster
    ADD CONSTRAINT roster_studentkey_fkey FOREIGN KEY (studentkey) REFERENCES public.student(studentkey);


--
-- Name: attendance seminardetails_seminardk_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT seminardetails_seminardk_fk FOREIGN KEY (seminardetailkey) REFERENCES public.seminardetails(seminardetailkey) ON UPDATE CASCADE;


--
-- Name: seminardetails seminarkey_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seminardetails
    ADD CONSTRAINT seminarkey_fk FOREIGN KEY (seminarkey) REFERENCES public.seminar(seminarkey);


--
-- Name: student student_personkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_personkey_fkey FOREIGN KEY (personkey) REFERENCES public.person(personkey);


--
-- Name: student student_statuskey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_statuskey_fkey FOREIGN KEY (statuskey) REFERENCES public.status(statuskey);


--
-- Name: substitution substitution_certadminkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.substitution
    ADD CONSTRAINT substitution_certadminkey_fkey FOREIGN KEY (certadminkey) REFERENCES public.certadmin(certadminkey);


--
-- Name: substitution substitution_certificatekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.substitution
    ADD CONSTRAINT substitution_certificatekey_fkey FOREIGN KEY (certificatekey) REFERENCES public.certificate(certificatekey);


--
-- Name: substitution substitution_coursekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.substitution
    ADD CONSTRAINT substitution_coursekey_fkey FOREIGN KEY (coursekey) REFERENCES public.course(coursekey);


--
-- Name: substitution substitution_studentkey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.substitution
    ADD CONSTRAINT substitution_studentkey_fkey FOREIGN KEY (studentkey) REFERENCES public.student(studentkey);


--
-- Name: substitution substitution_substitutekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.substitution
    ADD CONSTRAINT substitution_substitutekey_fkey FOREIGN KEY (substitutekey) REFERENCES public.course(coursekey);


--
-- Name: studentstatus; Type: MATERIALIZED VIEW DATA; Schema: instructorschema; Owner: postgres
--

REFRESH MATERIALIZED VIEW instructorschema.studentstatus;


--
-- PostgreSQL database dump complete
--

\connect postgres

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 10.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- PostgreSQL database dump complete
--

\connect template1

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 10.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

