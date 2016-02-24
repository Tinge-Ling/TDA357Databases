# Trigger for registering Student

CREATE TRIGGER registeringStudent 
INSTEAD OF INSERT OR UPDATE OR DELETE ON registrations
FOR EACH ROW
EXECUTE PROCEDURE registeringStudent();


# Function for registering Student
CREATE OR REPLACE FUNCTION registeringStudent() RETURNS TRIGGER AS $$
BEGIN
IF (SELECT EXISTS (SELECT 1 FROM passedcourses WHERE coursecode = (SELECT prereq FROM isprerequisite WHERE coursecode=new.coursecode AND passedcourses.id=new.studentid)))
	THEN IF(SELECT exists(SELECT 1 FROM limitedcourse WHERE coursecode=new.coursecode))
		THEN IF(SELECT count(*) FROM registrations WHERE coursecode=new.coursecode AND status='registered')<=(select maxparticipants from limitedcourse where coursecode=new.coursecode)
				THEN INSERT INTO isregistered VALUES (new.coursecode, new.studentid);
					return new;
				ELSE INSERT INTO iswaiting VALUES(current_date, new.studentid,new.coursecode);
					return new;
				END IF;
		ELSE INSERT INTO isregistered VALUES (new.coursecode, new.studentid);
			return new;
		END IF;
	ELSE RAISE EXCEPTION 'Lack of prerequisites';
	END IF;
END;

$$ LANGUAGE 'plpgsql' ;

#