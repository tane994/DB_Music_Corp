import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.*;


    public class App
    {

        public static void main(String[] args) throws Exception
        {
            // Local Variables
            //statement: execute SQL statement. table creation, tuple insertion, update, querying
            Statement stmt;
            //prepared statement takes as argument a query that has a fixed structure, but that can receive parameters at run time
            PreparedStatement pstmt;
            String query;
            InputStreamReader input = new InputStreamReader(System.in);
            BufferedReader keyboard = new BufferedReader(input);
            String inputChoice;
            String inputValue;
            int choice;
            String answer = "y";
            //result set is used to execute a query
            ResultSet rs;
            String output;
            String name;

            // Establish connection
            System.out.print("Insert DB username: ");
            name = keyboard.readLine();
            System.out.print("Insert DB password: ");
            inputValue = keyboard.readLine();

            // We assume that PostgreSQL is installed on localhost, and that it
            // contains a database named idblab05, over which we have already executed
            // the SQL code in lab05jdbcs1.sql.
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://localhost:5432/music_industry";


            Connection conn = DriverManager.getConnection(url, name, inputValue);

            // Exit condition
            boolean exit_true = false;
            int timeout = 10; // Seconds to wait before invalidating the connection


            // Main cycle

                while (!exit_true && conn.isValid(timeout))
                { // The connection might have been lost
                        System.out.print("Queries \n" +
                                "1.\tName, and ssn of clients which belong to a group and have at least 13 years of career and are born in Seattle.\n" +
                                "2.\tFind the genre of record which sold the most copies.\n" +
                                "3.\tCity that doesn’t host any music corporations.\n" +
                                "4.\tAverage number of clients of corporations.\n" +
                                "5.\tInsertion of a city\n" +
                                "6.\tProducer who produces records whose sum of awards amounts to at least 5.\n" +
                                "7.\tTotal revenues for each corporation.\n" +
                                "8.\tList of clients performing at concerts, ordered by code of concert.\n ");
                        System.out.print("\nChoose one option: ");
                        //each option corresponds to a query
                        inputChoice = keyboard.readLine();
                        choice = Integer.valueOf(inputChoice);
                        System.out.println();
                         exit_true = false;
                        switch (choice)
                        {

                            case 1:
                                query = "SELECT client.first_name, client.last_name, client.group_name, city.name from client, city WHERE client.birthplace=city.postal_code and year_of_career>12 AND city.name = 'Seattle' AND client.group_name IS NOT NULL ";
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery(query);
                                //System.out.println("first_name" + "   " +"last_name" + "   " +"group_name" + "   " +"cityName");
                                while (rs.next()) {
                                    String first_name = rs.getString(1);
                                    String last_name = rs.getString(2);
                                    String group_name = rs.getString(3);
                                    String cityName = rs.getString(4);
                                    System.out.println(first_name + "   " + last_name + "   " + group_name + "   " + cityName);
                                }

                                stmt.close();
                                exit_true = false;
                                break;

                            case 2:
                                query = "SELECT genre from record where copies_sold =(SELECT max(copies_sold) from record)";
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery(query);
                                while (rs.next()) {
                                    String genre = rs.getString("genre");
                                    System.out.println(genre);
                                }
                                stmt.close();
                                exit_true = false;
                                break;


                            case 3:
                                query = "SELECT postal_code, name from city where postal_code NOT IN(SELECT location from MUSIC_CORPORATION)";
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery(query);
                                while (rs.next()) {
                                    String postal_code = rs.getString("postal_code");
                                    name = rs.getString("name");
                                    System.out.println(postal_code + "\t" + name);
                                }
                                stmt.close();
                                exit_true = false;
                                break;

                            case 4:
                                query = "SELECT avg(numOfClient.clients) from client, (Select count(code) as clients from client group by corp_promoting ) as numOfClient;\n";
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery(query);
                                while (rs.next()) {
                                    String avg = rs.getString(1);
                                    System.out.println("Average number of clients of corporations: " + avg + "\t");
                                }
                                stmt.close();
                                exit_true = false;
                                break;


                            case 5:
                                try {
                                    System.out.print("Insert code: ");
                                    inputValue = keyboard.readLine();
                                    String code = String.valueOf(inputValue);
                                    System.out.println("Insert name of city: ");
                                    inputValue = keyboard.readLine();
                                    String name_city = String.valueOf(inputValue);
                                    pstmt = conn.prepareStatement("INSERT INTO city VALUES(?, ?, ?) ");
                                    pstmt.setString(1, code);
                                    pstmt.setString(2, "United States");
                                    pstmt.setString(3, name_city);
                                    pstmt.executeUpdate();
                                    query = "SELECT * from city";
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery(query);

                                    while (rs.next()) {
                                        String postal_code = rs.getString(1);
                                        String country = rs.getString(2);
                                        name = rs.getString(3);
                                        System.out.println(postal_code + "\t" + country + "\t" + name);
                                    }
                                    exit_true = false;
                                    stmt.close();
                                }
                                catch (Exception e ){
                                    System.out.println("Code unsupported. Must be a string -20 char max- and unique");
                                }
                                break;

                            case 6:
                                query = "SELECT DISTINCT producer.id_prod, producer.first_name, producer.last_name\n" +
                                        "\tfrom record, producer,award, (SELECT count(id_award) as num, winning_record as awardedRecord from award group by winning_record )as numOfAward\n" +
                                        "\twhere numOfAward.awardedRecord= record.code_rec and producer_rec=id_prod and num>4;";
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery(query);
                                while (rs.next()) {
                                    String id_prod = rs.getString(1);
                                    name = rs.getString(2);
                                    String last_name = rs.getString(3);
                                    System.out.println(id_prod + "\t" + name + "\t" + last_name);
                                }
                                exit_true = false;
                                stmt.close();
                                break;

                            case 7:
                                query = "select sum(sale), music_corporation.name from\n" +
                                        "music_corporation, record, concert, gadget,\n" +
                                        "(select sum(record.sales) as sale, tax_number as corp from music_corporation, record where revenues_record=tax_number group by corp\n" +
                                        "union\n" +
                                        "select sum(concert.sales) as sale, tax_number as corp  from music_corporation, concert where concert_organizer=tax_number group by corp\n" +
                                        "union\n" +
                                        "select sum(gadget.sales) as sale, tax_number as corp  from music_corporation, gadget where corp_id=tax_number group by corp)  temp3\n" +
                                        "where corp=tax_number group by music_corporation.name, corp;";
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery(query);
                                while (rs.next()) {

                                    String revenue = rs.getString(1);
                                    String music_corporation = rs.getString(2);
                                    System.out.println("Revenues of corporation: " + revenue + "\t" + music_corporation + "\t");
                                }
                                exit_true = false;
                                stmt.close();
                                break;

                            case 8:
                                query = " SELECT distinct client.stage_name, performing.code_concert " +
                                        "from performing, client " +
                                        " where performing.code_client=client.code order by code_concert;";

                                stmt = conn.createStatement();
                                rs = stmt.executeQuery(query);
                                while (rs.next()) {

                                    String stageName = rs.getString(1);
                                    String performanceCode = rs.getString(2);
                                    System.out.println(stageName + "\t" + performanceCode);
                                }
                                exit_true = false;
                                stmt.close();
                                break;


                            default:
                                System.out.println("Unsupported choice.");
                                break;


                        }
                        System.out.println();
                        System.out.println("Do you want to continue? y/n\n");
                        answer = keyboard.readLine();
                        if (answer.equals("n")) {
                            exit_true = true;
                        }

                }

            conn.close();
        }

    }

