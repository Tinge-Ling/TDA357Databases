/* StudentsFollowing */

CREATE VIEW studentsfollowing AS
SELECT student.id, student.name, student.spname, hasbranch.bname FROM (student 
	-- add the branch of the student to the view by using left join. Left join allows adding student who yet have no branch 
	LEFT JOIN hasbranch ON ((student.id = hasbranch.studentid)));



/* FinishedCourses */ 

CREATE VIEW finishedcourses AS
SELECT student.name, hascompleted.grade, hascompleted.coursecode, course.creditpoints, student.id FROM ((hascompleted 
	-- "left join student" gives the student id 
	LEFT JOIN student ON ((student.id = hascompleted.studentid)))
	-- joining course gives us the course code
	 JOIN course ON ((hascompleted.coursecode = course.code)));



/* Registrations */

CREATE VIEW registrations AS
SELECT isregistered.coursecode, isregistered.studentid, 'registered' AS status FROM isregistered 
	-- union iswaiting-table and isregistered-table add the students from isgregistered-table and iswaiting to the view
	UNION SELECT iswaiting.coursecode, iswaiting.studentid, 'waiting' AS status FROM iswaiting;



/* PassedCourses */

--get the data from finishedcourses besides the one with grade U
CREATE VIEW passedcourses AS
SELECT finishedcourses.name, finishedcourses.grade, finishedcourses.coursecode, finishedcourses.creditpoints, finishedcourses.id FROM finishedcourses WHERE (finishedcourses.grade <> 'U');



/* UnReadMandatory */

CREATE VIEW unreadmandatory AS
SELECT student.id, student.name, student.spname, hasbranch.bname, ismandatory.coursecode, hascompleted.grade 
	
	-- get students id and mandatory programme
	FROM ((((student JOIN ismandatory ON (((student.spname) = (ismandatory.spname))))
	
		--join course so we get the courses that are mandatory for both branch and the studyprogramme 
			JOIN course ON ((ismandatory.coursecode = course.code))) LEFT JOIN hasbranch ON ((student.id = hasbranch.studentid))) 

	-- left join hascompleted so we only get programme mandatory courses that are not passed
	LEFT JOIN hascompleted ON (((student.id = hascompleted.studentid) AND (ismandatory.coursecode = hascompleted.coursecode)))) WHERE ((hascompleted.grade IS NULL) OR (hascompleted.grade = 'U')) 

	-- union allows us to get branch mandatory courses as well. Do the same things as above queries
	UNION SELECT student.id, student.name, hasbranch.bprogramme AS spname, hasbranch.bname, course.code AS coursecode, hascompleted.grade 

		FROM ((((student JOIN hasbranch ON ((student.id = hasbranch.studentid))) JOIN isaddmandatory ON ((((isaddmandatory.bname) = (hasbranch.bname)) AND ((isaddmandatory.bprogramme) = (hasbranch.bprogramme))))) JOIN course ON ((course.code = isaddmandatory.coursecode))) 

		-- left join hascompleted so we only get branch mandatory courses that are not passed
		LEFT JOIN hascompleted ON (((hasbranch.studentid = hascompleted.studentid) AND (isaddmandatory.coursecode = hascompleted.coursecode)))) WHERE ((hascompleted.grade IS NULL) OR (hascompleted.grade = 'U'));



/* PathToGraduation */

CREATE VIEW pathtograduation AS
SELECT p.id, p.name, COALESCE(cred.totalcreditpoints, (0)) AS totalcreditpoints, COALESCE(unman.unpassed_mandatory, (0)) AS unreadmandatorycourses, COALESCE(mathpoints.math_credits, (0)) AS mathcredits, COALESCE(respoints.res_credits, (0)) AS researchcredits, COALESCE(sem.nbrseminar, (0)) AS nbrofseminar, 
	
	-- Checks if a student is qualified to graduate
	CASE 
		WHEN (((((unman.unpassed_mandatory IS NULL) AND (mathpoints.math_credits >= (20))) AND (respoints.res_credits >= (10))) AND (sem.nbrseminar >= 1)) AND (recomcred.recompoints >= (10))) THEN 'yes' ELSE 'no' END AS isqualifiedtograduate 


	FROM ((((((studentsfollowing p 
		-- get total credit points for the student
		NATURAL LEFT JOIN (SELECT passedcourses.id, sum(passedcourses.creditpoints) AS totalcreditpoints FROM passedcourses GROUP BY passedcourses.id) cred) 
		
		-- get the number of unread mandatory  courses
		NATURAL LEFT JOIN (SELECT unreadmandatory.id, count(unreadmandatory.coursecode) AS unpassed_mandatory FROM unreadmandatory GROUP BY unreadmandatory.id) unman) 

		-- get the total credit points of mathematical courses
		NATURAL LEFT JOIN (SELECT pc.id, sum(pc.creditpoints) AS math_credits FROM (passedcourses pc JOIN hasclassification hc ON ((pc.coursecode = hc.coursecode))) WHERE ((hc.classname) = 'Mathematics') GROUP BY pc.id) mathpoints) 
		
		-- get the total credit points of research courses
		NATURAL LEFT JOIN (SELECT pc.id, sum(pc.creditpoints) AS res_credits FROM (passedcourses pc JOIN hasclassification hc ON ((pc.coursecode = hc.coursecode))) WHERE ((hc.classname) = 'Research') GROUP BY pc.id) respoints) 
		
		-- get the total credit points of seminar courses
		NATURAL LEFT JOIN (SELECT pc.id, count(pc.coursecode) AS nbrseminar FROM (passedcourses pc JOIN hasclassification hc ON ((pc.coursecode = hc.coursecode))) WHERE ((hc.classname) = 'Seminar') GROUP BY pc.id) sem) 
		
		-- its for checking if a student is qualified to graduate. This doesn't display in the view.
		NATURAL LEFT JOIN (SELECT pc.id, sum(pc.creditpoints) AS recompoints FROM (passedcourses pc JOIN isrecommended ir ON ((pc.coursecode = ir.coursecode))) GROUP BY pc.id) recomcred);
