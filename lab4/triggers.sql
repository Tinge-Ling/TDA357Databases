# Trigger for registering Student

CREATE TRIGGER registeringStudent 
INSTEAD OF INSERT ON registrations
FOR EACH ROW
EXECUTE PROCEDURE registeringStudent();


# Function for registering Student
CREATE OR REPLACE FUNCTION registeringStudent() RETURNS TRIGGER AS $$
BEGIN

		-- True if the course needs prerequisites
		-- True if the student has NOT passed the prerequisite course
		IF  (SELECT EXISTS (SELECT 1 FROM isprerequisite WHERE coursecode =new.coursecode) AND (SELECT NOT EXISTS (SELECT 1 FROM passedcourses WHERE coursecode = (SELECT prereq FROM isprerequisite WHERE coursecode=new.coursecode AND passedcourses.id=new.studentid)))) 
				THEN RAISE EXCEPTION 'The student is lack of prerequisites.';
		-- True if the student exists in the waiting or registered-list
		ELSEIF (SELECT EXISTS (SELECT 1 FROM registrations WHERE studentid=new.studentid AND coursecode=new.coursecode))	
				THEN RAISE EXCEPTION 'The student is already registered or on the waiting list.';
		-- True if student exists in the passedcourses for that course
		ELSEIF (SELECT EXISTS (SELECT 1 FROM passedcourses WHERE id=new.studentid AND coursecode=new.coursecode)) 
				THEN RAISE EXCEPTION 'The student has already passed the course.';	 
		ELSE 
		-- True if the course has a limited number of participants
			IF(SELECT exists(SELECT 1 FROM limitedcourse WHERE coursecode=new.coursecode))
				-- checks if the number of registered students in the course is less to maximum number of participants
			THEN IF(SELECT count(*) FROM registrations WHERE coursecode=new.coursecode AND status='registered')<(select maxparticipants from limitedcourse where coursecode=new.coursecode)
						-- if yes, insert the student to isregistered-list
					THEN INSERT INTO isregistered VALUES (new.coursecode, new.studentid);
							return new;
						-- if no, put the student into the waiting list
					ELSE INSERT INTO iswaiting VALUES(current_timestamp, new.studentid,new.coursecode);
							return new;
					END IF;
				-- if the course has no limited number of participants		
			ELSE INSERT INTO isregistered VALUES (new.coursecode, new.studentid);
					return new;
			END IF;
		END IF;
END;
$$ LANGUAGE 'plpgsql' ;



# Trigger for courseUnReg
CREATE TRIGGER courseUnReg INSTEAD OF DELETE OR UPDATE
	ON Registrations	
	FOR EACH ROW
EXECUTE PROCEDURE unregisterStudent();


# Function for unregisteringStudent()
CREATE OR REPLACE FUNCTION unregisterStudent()
RETURNS TRIGGER AS $$
BEGIN

	-- If the student is registered, then delete from registrations and isregistered.
	IF (SELECT EXISTS (SELECT 1 FROM Registrations WHERE status = 'registered' AND old.studentid = studentid))
		THEN 
			DELETE FROM isregistered WHERE (old.studentid = studentid AND old.coursecode = coursecode);
			
			--If the course is full (admins changing manually can cause this error)
			IF ((SELECT EXISTS (SELECT 1 FROM limitedcourse WHERE coursecode = old.coursecode) 
					AND
				((SELECT count(*) FROM registrations WHERE coursecode=old.coursecode AND status='registered')
					<
				(SELECT maxparticipants FROM limitedcourse WHERE coursecode=old.coursecode)))) 

				--If the old.course has any students waiting to register to it. 
				THEN IF (SELECT EXISTS (SELECT 1 FROM registrations WHERE status = 'waiting' AND coursecode=old.coursecode))
					
					
					THEN
						--Now the student is officially registered to the course, and not waiting anymore
						INSERT INTO isregistered (coursecode,studentid)
						VALUES
						((SELECT code FROM course
						    WHERE code = old.coursecode),
						(SELECT reg.studentid
						    FROM registrations AS reg, coursequeuepositions AS cqp
						    WHERE (cqp.position = '1' 
							 AND cqp.studentid = reg.studentid 
							 AND reg.coursecode = old.coursecode
							 AND reg.status = 'waiting')));

						--Deleting the newly registered course for student in iswaiting
						DELETE 
						FROM iswaiting AS iw
						 	USING registrations AS reg,
						 		  coursequeuepositions AS cqp
						WHERE (cqp.position = '1' 
						AND cqp.studentid = reg.studentid 
						AND reg.coursecode = old.coursecode
						AND iw.studentid = reg.studentid
						AND reg.status = 'registered');
				ELSE
				END IF;

		ELSE
		END IF;

		RETURN OLD;
		
	ELSE 
	END IF;
END;
$$ LANGUAGE 'plpgsql';