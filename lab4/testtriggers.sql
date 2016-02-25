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
