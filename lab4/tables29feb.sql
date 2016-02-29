CREATE TABLE Department(
	name			VARCHAR(100) NOT NULL,		
	abbreviation		VARCHAR(5),
	PRIMARY KEY(abbreviation),
	UNIQUE(name)
);

CREATE TABLE StudyProgramme(
	name			VARCHAR(80),
	abbreviation		VARCHAR(5)  NOT NULL,
	PRIMARY KEY(name)
);

CREATE TABLE Branch(
	spName		VARCHAR(100) REFERENCES StudyProgramme,
	name			VARCHAR(100),
	PRIMARY KEY(spName, name)
);

CREATE TABLE Course(
	courseName		VARCHAR(80)  NOT NULL,
creditPoints		REAL   NOT NULL,
code			CHAR(6),
departAbb		VARCHAR(5)	REFERENCES Department,
PRIMARY KEY(code),
CONSTRAINT ValidCreditPoints CHECK (creditPoints>0)
);

CREATE TABLE LimitedCourse(
	courseCode		CHAR(6)	REFERENCES Course,
maxParticipants	INT,
PRIMARY KEY(courseCode),
CONSTRAINT ValidParticipants CHECK(maxParticipants>0)

);

CREATE TABLE Student(
	name			VARCHAR(40)  NOT NULL,
	id			CHAR(10),			
	spName		VARCHAR(80)	REFERENCES StudyProgramme,
	PRIMARY KEY(id),
	UNIQUE(id,spname)
);

CREATE TABLE Classification(
name			VARCHAR(30),
PRIMARY KEY(name)
);

CREATE TABLE HostBy(
	dAbbreviation		VARCHAR(5) REFERENCES Department,
	spName		VARCHAR(80) REFERENCES StudyProgramme,
	PRIMARY KEY(dAbbreviation, spName)
);

CREATE TABLE HasBranch(
	studentID		CHAR(10) REFERENCES Student,
bName			VARCHAR(80),
bProgramme		VARCHAR(80),
	PRIMARY KEY(studentID),
	FOREIGN KEY(bName, bProgramme) REFERENCES Branch(name,spname),
	FOREIGN KEY(studentID, bProgramme) REFERENCES Student(id,spname)
);

CREATE TABLE IsMandatory(
	courseCode 		CHAR(6)	REFERENCES Course,
	spName		VARCHAR(80) REFERENCES StudyProgramme,
	PRIMARY KEY(courseCode, spName)
);

CREATE TABLE IsRecommended(
courseCode		CHAR(6)	REFERENCES Course,
bName			VARCHAR(80),
bProgramme		VARCHAR(80),
PRIMARY KEY(courseCode, bName, bProgramme),
	FOREIGN KEY(bProgramme,bName) REFERENCES Branch
);

CREATE TABLE IsAddMandatory(
courseCode		CHAR(6)	REFERENCES Course,
bName			VARCHAR(80),
bProgramme		VARCHAR(80),
PRIMARY KEY(courseCode,bProgramme,bName),
	FOREIGN KEY(bProgramme,bName) REFERENCES Branch
);

CREATE TABLE IsRegistered(
	courseCode		CHAR(6)	REFERENCES Course,
	studentID		CHAR(10) REFERENCES Student,
	PRIMARY KEY(courseCode, studentID)
);

CREATE TABLE HasCompleted(
grade			CHAR(1),
	courseCode		CHAR(10)	REFERENCES Course,
studentID		CHAR(10) REFERENCES Student,
PRIMARY KEY(courseCode, studentID),
CONSTRAINT ValidGrade CHECK(grade in('U','3','4','5'))
);

CREATE TABLE IsWaiting(
	sinceDate		TIMESTAMP,
	studentID		CHAR(10) REFERENCES Student,
	courseCode		CHAR(6)	REFERENCES LimitedCourse,
PRIMARY KEY(studentID, courseCode),
UNIQUE(sinceDate, courseCode)
);

CREATE TABLE HasClassification(
	courseCode		CHAR(6)	REFERENCES Course,
	className		VARCHAR(80)	REFERENCES Classification,
PRIMARY KEY(courseCode, className)
);


CREATE TABLE isprerequisite (
    coursecode character(6) REFERENCES Course,
    prereq character(6) REFERENCES Course,
   PRIMARY KEY (coursecode, prereq)
);


