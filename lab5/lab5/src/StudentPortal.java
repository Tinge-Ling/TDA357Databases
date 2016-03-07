/* This is the driving engine of the program. It parses the command-line
 * arguments and calls the appropriate methods in the other classes.
 *
 * You should edit this file in two ways:
 * 1) Insert your database username and password in the proper places.
 * 2) Implement the three functions getInformation, registerStudent
 *    and unregisterStudent.
 */

import java.sql.*; // JDBC stuff.
import java.util.Properties;
import java.util.Scanner;
import java.io.*;  // Reading user input.

public class StudentPortal {
    /* TODO Here you should put your database name, username and password */
    static final String USERNAME = "tda357_049";
    static final String PASSWORD = "tingkiwi";

    /* Print command usage.
     * /!\ you don't need to change this function! */
    public static void usage() {
        System.out.println("Usage:");
        System.out.println("    i[nformation]");
        System.out.println("    r[egister] <course>");
        System.out.println("    u[nregister] <course>");
        System.out.println("    q[uit]");
    }

    /* main: parses the input commands.
     * /!\ You don't need to change this function! */
    public static void main(String[] args) throws Exception {
        try {
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://ate.ita.chalmers.se/";
            Properties props = new Properties();
            props.setProperty("user", USERNAME);
            props.setProperty("password", PASSWORD);
            Connection conn = DriverManager.getConnection(url, props);

            String student = args[0]; // This is the identifier for the student.

            Console console = System.console();
            usage();
            System.out.println("Welcome!");
            while (true) {
                String mode = console.readLine("? > ");
                String[] cmd = mode.split(" +");
                cmd[0] = cmd[0].toLowerCase();
                if ("information".startsWith(cmd[0]) && cmd.length == 1) {
                    /* Information mode */
                    getInformation(conn, student);
                } else if ("register".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Register student mode */
                    registerStudent(conn, student, cmd[1]);
                } else if ("unregister".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Unregister student mode */
                    unregisterStudent(conn, student, cmd[1]);
                } else if ("quit".startsWith(cmd[0])) {
                    break;
                } else usage();
            }
            System.out.println("Goodbye!");
            conn.close();
        } catch (SQLException e) {
            System.err.println(e);
            System.exit(2);
        }
    }

    /* Given a student identification number, ths function should print
     * - the name of the student, the students national identification number
     *   and their university issued login name (something similar to a CID)
     * - the programme and branch (if any) that the student is following.
     * - the courses that the student has read, along with the grade.
     * - the courses that the student is registered to.
     * - the mandatory courses that the student has yet to read.
     * - whether or not the student fulfills the requirements for graduation
     */
    static void getInformation(Connection conn, String student) throws SQLException
    {
        String studentQuery = "SELECT name,spname FROM studentsfollowing WHERE id = '"+student+"'";

        String branchQuery = "SELECT bname FROM studentsfollowing WHERE id = '"+student+"'";

        String readCoursesQuery = "SELECT c.coursename,c.code,fc.grade,fc.creditpoints FROM Course AS c, finishedcourses AS fc " +
                "WHERE fc.id = '"+student+"' AND fc.coursecode = c.code";

        String registeredCoursesQuery = "SELECT c.coursename,c.code,reg.status FROM Course AS c, registrations AS reg " +
                "WHERE reg.studentid = '"+student+"' AND reg.coursecode = c.code";

        String positionQuery = "SELECT cqp.position FROM coursequeuepositions AS cqp WHERE cqp.studentid = '"+student+"'";

        String pathToGradQuery = "SELECT ptg.nbrofseminar, ptg.mathcredits, ptg.researchcredits, ptg.totalcreditpoints, " +
                "ptg.isqualifiedtograduate " +
                "FROM pathtograduation AS ptg " +
                "WHERE ptg.id = '"+student+"'";


        Statement myStatement = conn.createStatement();
        Statement mS = conn.createStatement();
        ResultSet res = myStatement.executeQuery(studentQuery); 
        ResultSet res2;


        if(res.next()) {
            System.out.print("Information for student " + student.substring(0, 6) + "-" + student.substring(6) + "\n");
            System.out.println("------------------");
            System.out.println("Name: " + res.getString(1));
            System.out.println("Line: " + res.getString(2));
            res.close();
        }

        res = myStatement.executeQuery(branchQuery);
        if(res.next()) {
            System.out.println("Branch: " + res.getString(1));
            res.close();
        }

        System.out.print("\nRead Courses (name (code), credits : grade): \n");
        res = myStatement.executeQuery(readCoursesQuery);

        while(res.next()){
            System.out.print(res.getString(1)+" ("+res.getString(2)+"), "+ res.getString(4)+"p: " +res.getString(3)+"\n");

        }
        res.close();

        res = myStatement.executeQuery(registeredCoursesQuery);
        res2 = mS.executeQuery(positionQuery);
        System.out.print("\nRegistered Courses (name (code), credits : status):\n");

        while(res.next()){
            if(res.getString(3).equals("waiting")){
                if(res2.next()){
                    System.out.print(res.getString(1)+" ("+res.getString(2)+"): "+ res.getString(3)+" as nr "+ res2.getString(1)+"\n");

                }
            }else {
                System.out.print(res.getString(1)+" ("+res.getString(2)+"): "+ res.getString(3)+"\n");

            }


        }
        res2.close();
        res.close();
        mS.close();

        res = myStatement.executeQuery(pathToGradQuery);

        if(res.next()) {
            System.out.print("\nSeminar courses taken: " +res.getString(1)+ "\nMath credits taken: "+res.getString(2)+
                    "\nResearch credits taken: "+res.getString(3)+"\nTotal credits taken: "+res.getString(4)+
                    "\nFulfills the requirements for graduation: "+res.getString(5)+"\n");

        }
        res.close();
        myStatement.close();
    }


    /* Register: Given a student id number and a course code, this function
     * should try to register the student for that course.
     */
    static void registerStudent(Connection conn, String student, String course)
            throws SQLException {
        String registerStudentStr = "INSERT INTO Registrations (coursecode, studentid) VALUES ('"+course+"','"+student+"')";

        PreparedStatement registerStudentStm = conn.prepareStatement(registerStudentStr);
        registerStudentStm.executeUpdate();
        registerStudentStm.close();

        String getCourseNameStr = "SELECT coursename FROM course WHERE code='" + course + "'";
        Statement getCourseStm = conn.createStatement();
        ResultSet rs = getCourseStm.executeQuery(getCourseNameStr);
        if(rs.next()) {
            System.out.println("You are now successfully registered to course "+course+" "+rs.getString(1)+"!");

        }

        rs.close();
        getCourseStm.close();
    }


    /* Unregister: Given a student id number and a course code, this function
     * should unregister the student from that course.
     */
    static void unregisterStudent(Connection conn, String student, String course)
            throws SQLException {
        String unregStudentStr = "DELETE FROM registrations WHERE studentid = '"+student+"' AND coursecode = '"+course+"';";

        PreparedStatement unregStudentStm = conn.prepareStatement(unregStudentStr);
        unregStudentStm.executeUpdate();
        unregStudentStm.close();

        String getCourseNameStr = "SELECT coursename FROM course WHERE code='" + course + "'";
        Statement getCourseStm = conn.createStatement();
        ResultSet rs = getCourseStm.executeQuery(getCourseNameStr);
        if(rs.next()) {
            System.out.println("You are now successfully unregistered from course "+course+" "+rs.getString(1)+"!");

        }

        rs.close();
        getCourseStm.close();
    }
}