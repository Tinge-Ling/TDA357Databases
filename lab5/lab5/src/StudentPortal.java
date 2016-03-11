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
        //Defining this query further down.
        String positionQuery = "";

        String studentQuery = "SELECT name,spname FROM studentsfollowing WHERE id = ?";

        String branchQuery = "SELECT bname FROM studentsfollowing WHERE id = ?";

        String readCoursesQuery = "SELECT c.coursename,c.code,fc.grade,fc.creditpoints FROM Course AS c, finishedcourses AS fc " +
                "WHERE fc.id = ? AND fc.coursecode = c.code";

        String registeredCoursesQuery = "SELECT c.coursename,c.code,reg.status FROM Course AS c, registrations AS reg " +
                "WHERE reg.studentid = ? AND reg.coursecode = c.code";

        String pathToGradQuery = "SELECT ptg.nbrofseminar, ptg.mathcredits, ptg.researchcredits, ptg.totalcreditpoints, " +
                "ptg.isqualifiedtograduate " +
                "FROM pathtograduation AS ptg " +
                "WHERE ptg.id = ?";


        //Statement myStatement = conn.createStatement();
        //Statement mS = conn.createStatement();

        PreparedStatement ps = conn.prepareStatement(studentQuery);
        ps.setString(1,student);

        ResultSet res = ps.executeQuery();
        ResultSet res2;

        //First clause
        if(res.next()) {
            System.out.print("Information for student " + student.substring(0, 6) + "-" + student.substring(6) + "\n");
            System.out.println("------------------");
            System.out.println("Name: " + res.getString(1));
            System.out.println("Line: " + res.getString(2));
            res.close();
        }

        ps = conn.prepareStatement(branchQuery);
        ps.setString(1,student);
        res = ps.executeQuery();

        if(res.next()) {
            //if no branch exists
            if(res.getString(1) == null){
                System.out.println("Branch: Have none");
            }else {
                System.out.println("Branch: " + res.getString(1));
            }
            res.close();
        }

        ps = conn.prepareStatement(readCoursesQuery);
        ps.setString(1,student);
        res = ps.executeQuery();
        //Second clause
        System.out.print("\nRead Courses (name (code), credits : grade): \n");

        while(res.next()){
            System.out.print(res.getString(1)+" ("+res.getString(2)+"), "+ res.getString(4)+"p: " +res.getString(3)+"\n");

        }
        res.close();

        ps = conn.prepareStatement(registeredCoursesQuery);
        ps.setString(1,student);
        res = ps.executeQuery();

        //third clause
        System.out.print("\nRegistered Courses (name (code), credits : status):\n");

        while(res.next()){
            //getting the position if the student is waiting for the selected course
            if(res.getString(3).equals("waiting")){
                String s = res.getString(2);
                positionQuery = "SELECT cqp.position FROM coursequeuepositions AS cqp, Course AS c WHERE cqp.studentid = ? AND cqp.coursecode = '" + s + "'";

                PreparedStatement prepstate = conn.prepareStatement(positionQuery);
                prepstate.setString(1,student);
                res2 = prepstate.executeQuery();

                if(res2.next()){
                    System.out.print(res.getString(1)+" ("+res.getString(2)+"): "+ res.getString(3)+" as nr "+ res2.getString(1)+"\n");

                }
                prepstate.close();
                res2.close();
            }else {
                System.out.print(res.getString(1)+" ("+res.getString(2)+"): "+ res.getString(3)+"\n");

            }



        }

        res.close();

        ps = conn.prepareStatement(pathToGradQuery);
        ps.setString(1,student);
        res = ps.executeQuery();

        //fourth clause
        if(res.next()) {
            System.out.print("\nSeminar courses taken: " +res.getString(1)+ "\nMath credits taken: "+res.getString(2)+
                    "\nResearch credits taken: "+res.getString(3)+"\nTotal credits taken: "+res.getString(4)+
                    "\nFulfills the requirements for graduation: "+res.getString(5)+"\n");

        }
        res.close();
        ps.close();
    }


    /* Register: Given a student id number and a course code, this function
         * should try to register the student for that course.
         */
    static void registerStudent(Connection conn, String student, String course)
            throws SQLException {
//        String registerStudentStr = "INSERT INTO Registrations (coursecode, studentid) VALUES ('"+course+"','"+student+"')";

        try {
            PreparedStatement registerStudentStm=conn.prepareStatement("INSERT INTO Registrations (coursecode, studentid) VALUES (?,?)");
            registerStudentStm.setString(1,course);
            registerStudentStm.setString(2,student);
//            PreparedStatement registerStudentStm = conn.prepareStatement(registerStudentStr);
            registerStudentStm.executeUpdate();
            registerStudentStm.close();
//            String getCourseNameStr = "SELECT coursename FROM course WHERE code='" + course + "'";
            PreparedStatement getCourseStm = conn.prepareStatement("SELECT coursename FROM course WHERE code=?");
            getCourseStm.setString(1,course);
            ResultSet rs = getCourseStm.executeQuery();
            if(rs.next()) {
                System.out.println("You are now successfully registered or put to the waiting list to course "+course+" "+rs.getString(1)+"!");

            }
            rs.close();
            getCourseStm.close();
        }catch(SQLException e){

            System.out.println(e.toString());
        }




    }


    /* Unregister: Given a student id number and a course code, this function
         * should unregister the student from that course.
         */
    static void unregisterStudent(Connection conn, String student, String course)

            throws SQLException {
//        String unregStudentStr = "DELETE FROM registrations WHERE studentid = '" + student + "' AND coursecode = '" + course + "';";

        try {
            PreparedStatement unregStudentStm=conn.prepareStatement("DELETE FROM registrations WHERE studentid = ? AND coursecode = ?");
            unregStudentStm.setString(1,student);
            unregStudentStm.setString(2,course);

//            PreparedStatement unregStudentStm = conn.prepareStatement(unregStudentStr);
            unregStudentStm.executeUpdate();
            unregStudentStm.close();

//            String getCourseNameStr = "SELECT coursename FROM course WHERE code='" + course + "'";
            PreparedStatement getCourseStm = conn.prepareStatement("SELECT coursename FROM course WHERE code= ?");
            getCourseStm.setString(1,course);
            ResultSet rs = getCourseStm.executeQuery();
            if (rs.next()) {
                System.out.println("You are now successfully unregistered or deleted from the waiting list from course " + course + " " + rs.getString(1) + "!");

            }

            rs.close();
            getCourseStm.close();
        } catch (SQLException e) {
            System.out.println(e.toString());
        }
    }
}
