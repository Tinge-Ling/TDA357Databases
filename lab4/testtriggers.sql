# Testing values for trigger, registeringStudent

--Student wants to register to a course that doesn't need any prerequisites -> should work
INSERT INTO Registrations (coursecode, studentid) VALUES ('AIC692','4141414141');

--Student has all the prerequisites, not in the lists, have not passed -> should work
INSERT INTO Registrations (coursecode, studentid) VALUES ('AER682','3131313131');


--Student has not the prerequisites -> raise exception 1
INSERT INTO Registrations (coursecode, studentid) VALUES ('AER682','1212121212');

--Student has the prerequisites, but is already in either of lists -> raise exception 2
INSERT INTO Registrations (coursecode, studentid) VALUES ('MVV395','3232323232');


--Student has the prerequisites, not in the lists but has already passed the course -> raise exception 3
INSERT INTO Registrations (coursecode, studentid) VALUES ('TKG431','1313131313');


# Testing values for trigger, courseunreg

--Case1: Unregister the student ('TestTrigger2 case1') from the course ('TOA194)') and then unregister again from the same course. Show that the student is unregistered
INSERT INTO isregistered VALUES('TOA194','1111111111');
TODO write queries for unregistering this student when the trigger is done

--Case2: Unregister the student ('TestTrigger2 case2') from a restricted course ('MVV395') that they are registered to, and which has at least two students in the queue. Register again to the same course and show that the student gets the correct (last) position in the waiting list.

--make the course full and put students on the course
INSERT INTO isregistered VALUES('MVV395','2222222222');
INSERT INTO isregistered VALUES('MVV395','5407015273');
INSERT INTO isregistered VALUES('MVV395','8204206413');


--Case3: Unregister the student from a restricted course that they are registered to, and which has at least two students in the queue. Register again to the same course and show that the student gets the correct (last) position in the waiting list.

--Case4: Finally, unregister a student from an overfull course, i.e. one with more students registered than there are places on the course (you need to set this situation up in the database directly). Show that no student was moved from the queue to being registered as a result.