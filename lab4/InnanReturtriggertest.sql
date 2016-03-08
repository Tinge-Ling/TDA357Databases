# Testing values for trigger 1, registeringStudent

--Student wants to register to a course that doesn't need any prerequisites -> should work
INSERT INTO Registrations (coursecode, studentid) VALUES ('AIC692','4141414141');

--Student has all the prerequisites, not in the lists, have not passed -> should work (in waiting list)
INSERT INTO Registrations (coursecode, studentid) VALUES ('AER682','3131313131');


--Student has not the prerequisites -> raise exception 1
INSERT INTO Registrations (coursecode, studentid) VALUES ('AER682','1212121212');

--Student has the prerequisites, but is already in either of lists -> raise exception 2
INSERT INTO Registrations (coursecode, studentid) VALUES ('MVV395','3232323232');


--Student has the prerequisites, not in the lists but has already passed the course -> raise exception 3
INSERT INTO Registrations (coursecode, studentid) VALUES ('TKG431','1313131313');


# Testing values for trigger 2, courseunreg

--Case1: Unregister the student ('TestTrigger2 case1') from the course ('TOA194)') and then unregister again from the same course. Show that the student is unregistered
Query:
DELETE FROM registrations WHERE studentid = '1111111111' AND coursecode = 'TOA194';
DELETE FROM registrations WHERE studentid = '1111111111' AND coursecode = 'TOA194';

--Case2: Unregister the student ('TestTrigger2 case2') from a restricted course ('MVV395') that they are registered to, and which has at least two students in the queue. Register again to the same course and show that the student gets the correct (last) position in the waiting list.
Query:
DELETE FROM registrations WHERE studentid = '2222222222' AND coursecode = 'MVV395';
INSERT INTO registrations (coursecode, studentid) VALUES ('MVV395','2222222222');


--Case3: Finally, unregister the student ('TestTrigger2 case3')  from an overfull course (‘AKR245’), i.e. one with more students registered than there are places on the course (you need to set this situation up in the database directly). Show that no student was moved from the queue to being registered as a result.
Query:
DELETE FROM registrations WHERE studentid = '3333333333' AND coursecode = 'AKR245';



