# Trigger for registering Student

CREATE TRIGGER registeringStudent 
INSTEAD OF INSERT OR UPDATE OR DELETE ON registrations
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
					ELSE INSERT INTO iswaiting VALUES(current_date, new.studentid,new.coursecode);
							return new;
					END IF;
				-- if the course has no limited number of participants		
			ELSE INSERT INTO isregistered VALUES (new.coursecode, new.studentid);
					return new;
			END IF;
		END IF;
END;
$$ LANGUAGE 'plpgsql' ;

