DROP TABLE IF EXISTS city CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS music_corporation CASCADE;
DROP TABLE IF EXISTS manager CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS concert CASCADE;
DROP TABLE IF EXISTS producer CASCADE;
DROP TABLE IF EXISTS video CASCADE;
DROP TABLE IF EXISTS gadget CASCADE;
DROP TABLE IF EXISTS record CASCADE;
DROP TABLE IF EXISTS award CASCADE;
DROP TABLE IF EXISTS performing CASCADE;

CREATE TABLE IF NOT EXISTS city (

	postal_code CHAR (20) NOT NULL PRIMARY KEY,
	country CHAR(20) NOT NULL,
	name CHAR(20) NOT NULL
);


CREATE TABLE IF NOT EXISTS person (

	ssn CHAR(20) NOT NULL PRIMARY KEY,
	first_name VARCHAR(20) NOT NULL,
	last_name VARCHAR(20) NOT NULL,
	date_of_birth DATE NOT NULL,

	birthplace CHAR(20) REFERENCES city (postal_code)
	/*UNIQUE(birthplace)*/
);


CREATE TABLE music_corporation(
tax_number CHAR(20) NOT NULL PRIMARY KEY,
name VARCHAR(20) NOT NULL,
location CHAR(20) REFERENCES city(postal_code)
/*UNIQUE(location)*/
);


CREATE TABLE IF NOT EXISTS manager (

	code_manager CHAR(20) NOT NULL PRIMARY KEy,
	email VARCHAR(50)

) INHERITS (person);

ALTER TABLE manager ADD CONSTRAINT check_age
CHECK (date_part('year',age(date_of_birth))>17);

CREATE TABLE IF NOT EXISTS client (

	code CHAR(20) NOT NULL PRIMARY KEY,
	stage_name CHAR(20) NOT NULL,
	email VARCHAR(50) NOT NULL,
	year_of_career NUMERIC NOT NULL,
	corp_promoting CHAR(20) REFERENCES music_corporation (tax_number),
	/*UNIQUE(corp_promoting),*/
	manager_id CHAR(20) REFERENCES manager (code_manager),
	group_name CHAR(20),
	/*UNIQUE(manager_id),*/
	CONSTRAINT yearCareer CHECK(year_of_career >= 2)

)INHERITS (person);


create table IF NOT EXISTS concert(
code_concert CHAR(20) NOT NULL PRIMARY KEY,
date_of_concert DATE NOT NULL,
sales NUMERIC NOT NULL,
cityConcert CHAR(20) REFERENCES city (postal_code),
/*UNIQUE(cityConcert),*/
concert_organizer CHAR(20) REFERENCES music_corporation(tax_number)
/*UNIQUE(concert_organizer),*/

);

CREATE TABLE IF NOT EXISTS performing (
	code_performance CHAR(20) NOT NULL PRIMARY KEY,
	code_concert CHAR(20) NOT NULL REFERENCES concert (code_concert),
	code_client CHAR(20) NOT NULL REFERENCES client (code)


);

CREATE TABLE IF NOT EXISTS producer(

	id_prod CHAR(20) NOT NULL PRIMARY KEY,
	producers_employer CHAR(20) REFERENCES music_corporation(tax_number)
	/*UNIQUE(producers_employer)*/
	/*CONSTRAINT age CHECK((DATEDIFF(hour,date_of_birth,GETDATE())/8766)>=18)*/
)INHERITS (person);
ALTER TABLE producer ADD CONSTRAINT check_age1
CHECK (date_part('year',age(date_of_birth))>17);


CREATE TABLE IF NOT EXISTS video(
	code_video CHAR(20) NOT NULL PRIMARY KEY,
	title CHAR(20) NOT NULL,
	length NUMERIC NOT NULL
);


CREATE TABLE IF NOT EXISTS gadget(

	id_product CHAR(20) NOT NULL PRIMARY KEY,
	name CHAR(200) NOT NULL,
	type CHAR(50) NOT NULL,
	sales NUMERIC NOT NULL,
	branding_client CHAR(20) REFERENCES client(code),
	/*UNIQUE(branding_client),*/
	corp_id CHAR(20) REFERENCES music_corporation(tax_number)
	/*UNIQUE(corp_id),*/

);


CREATE TABLE IF NOT EXISTS record(

	code_rec CHAR(20)NOT NULL PRIMARY KEY,
	name CHAR(100) NOT NULL,
	hit CHAR(50),
	copies_sold NUMERIC NOT NULL,
	sales NUMERIC NOT NULL,
	genre CHAR(20),
	producer_rec CHAR(20) REFERENCES producer (id_prod),
	/*UNIQUE(producer_rec),*/
	video_id CHAR(20) REFERENCES video (code_video),
	UNIQUE(video_id),
	record_client CHAR(20) REFERENCES client(code),
	/*UNIQUE(record_client),*/
	revenues_record CHAR(20) REFERENCES music_corporation (tax_number)
	/*UNIQUE(revenues_record),*/

);


CREATE TABLE IF NOT EXISTS award(

	id_award CHAR(20) NOT NULL PRIMARY KEY,
	name CHAR(500) NOT NULL,
	date DATE NOT NULL,
	winning_record CHAR(20) REFERENCES record (code_rec)
	/*UNIQUE(winning_record),*/
);






/*TRIGGERS*/

CREATE OR REPLACE FUNCTION online_sales_funct() RETURNS TRIGGER AS $online_sales_funct$
BEGIN
	UPDATE concert
	 	SET sales = sales + 1000;
		RETURN NEW;
END;
$online_sales_funct$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS online_sales_tr on concert;
CREATE TRIGGER online_sales_tr AFTER INSERT ON concert FOR EACH STATEMENT EXECUTE FUNCTION online_sales_funct();


/*INSERTION*/

BEGIN TRANSACTION;

insert into city (postal_code, country, name) values ('10007', 'United States', 'New York'),
('48202', 'United States', 'Detroit'),
('77070', 'United States', 'Houston'),
('60606', 'United States', 'Chicago'),
('90210', 'United States', 'Beverly Hills'),
('33162', 'United States', 'Miami'),
('97210', 'United States', 'Portland'),
('84060', 'United States', 'Park City'),
('94104', 'United States', 'San Francisco'),
('98101', 'United States', 'Seattle');


insert into person (SSN, first_name, last_name, date_of_birth, birthplace) values 
('369-HgV5K', 'Theo', 'Haquard', '2/20/1974', '77070'),
('482-lHM9d', 'Bernette', 'Bance', '9/1/1932', '84060'),
('076-XJwbb', 'Sarah', 'Greendale', '4/18/1971', '60606'),
('487-tdkLD', 'Devlen', 'MacConnulty', '4/4/1987', '60606'),
('124-q0aMT', 'Leonelle', 'Hiscocks', '3/2/1984', '98101'),
('355-rkDNL', 'Tedie', 'Leap', '12/19/1996', '98101'),
('867-xdvhH', 'Brody', 'Wogden', '3/8/1957', '60606'),
('936-Q7QB0', 'Frayda', 'Blumer', '9/18/1962', '33162'),
('202-x3blC', 'Selena', 'Yakubovics', '6/19/1995', '60606'),
('167-O4RkD', 'Isaac', 'Ithell', '10/28/1931', '33162'),
('350-5EDPe', 'Sutton', 'Peret', '11/23/1948', '97210'),
('259-1S6cj', 'Barbara', 'Cushelly', '4/7/1962', '94104'),
('692-fh3jU', 'Thea', 'Chansonnau', '12/18/1966', '94104'),
('214-ht15d', 'Louie', 'Limb', '5/19/1938', '97210'),
('531-23LSh', 'Cleo', 'Northall', '8/20/1986', '10007');


insert into music_corporation (tax_number, name, location) values ('06744', 'Atlantic Records', '10007'),
('63460', 'Def Jam', '90210' ),
('79996', 'Universal Music', '60606');

SET datestyle = mdy;
insert into manager (SSN, first_name, last_name, date_of_birth, birthplace, code_manager, email) values
('536-KKfLi', 'Bevvy', 'Tomsett', '5/11/1983', '10007','10vx8u', 'shambric0@twitpic.com'),
('312-1TDBH', 'Jennica', 'Muehle', '10/15/1998', '48202','25iq2x', 'mbartlet1@prweb.com'),
('367-z0AuL', 'Jacklyn', 'Gillingwater', '6/14/1959', '10007','01wq0f', 'cshutt2@blog.com'),
('938-zr1GO', 'See', 'Connar', '9/13/1957', '48202','74bk4b', 'gnelle3@forbes.com');

insert into client (SSN, first_name, last_name, date_of_birth, birthplace,code, stage_name, email, year_of_career, corp_promoting, manager_id, group_name) values
('517-IUvK0', 'Kylen', 'Cleverly', '4/27/1981', '48202','74546', 'Claude', 'ckillik4@youku.com', 20, '79996', '25iq2x', NULL),
('338-epSr2', 'Thain', 'Crocumbe', '3/9/1949', '10007','69783', 'Thain', 'tprivett5@php.net', 3, '06744', '01wq0f', NULL),
('715-CcCz9', 'Ernaline', 'Carter', '6/20/2003', '10007','84596', 'Forbes', 'feyckelberg7@shop-pro.jp', 36, '06744', '10vx8u', NULL),
('695-yKGgA', 'Stace', 'Neicho', '8/8/2002', '48202','78059', 'Kippy', 'khessed@salon.com', 4, '06744', '74bk4b', NULL),
('538-986ij', 'Krishna', 'Le Estut', '8/26/1946', '10007', '42186', 'Birdie', 'bdowreyg@fastcompany.com', 24, '63460', '74bk4b', NULL),
('224-UT70n', 'Veronike', 'Dyet', '4/26/1994', '97210','98272', 'Aguistin', 'alathaye0@irs.gov', 7, '06744', '10vx8u', 'Thundercats'),
('599-CtUNw', 'Rora', 'Chauvey', '1/23/1940', '48202','45514', 'Cyrille', 'cgirogetti1@japanpost.jp', 18, '06744', '25iq2x','Thundercats'),
('782-4JjL7', 'Vladimir', 'Renard', '12/20/1960', '84060','78442', 'Harper', 'hdickey2@dailymail.co.uk', 10, '63460', '25iq2x','Beatles'),
('110-zo84O', 'Pietrek', 'Crowch', '1/27/1977', '48202','80461', 'Alyssa', 'achiles3@examiner.com', 3, '63460', '10vx8u','Beatles'),
('776-kaWPr', 'Saba', 'Hutchinson', '3/9/1943', '98101','09256', 'Maitilde', 'mwestwood6@ftc.gov', 29, '06744', '01wq0f', 'Thundercats'),
('568-v5J9Q', 'Quincey', 'Bravery', '2/17/1969', '84060','08462', 'Dinny', 'dfarlambea@bing.com', 12, '79996', '01wq0f',  'The Neptunes'),
('792-DyDv9', 'Rosemary', 'Itzcovichch', '1/25/1983', '48202', '37862', 'Jard', 'jgwilliamsb@indiegogo.com', 31, '06744',  '10vx8u', 'The Neptunes'),
('151-OJh2Z', 'Derry', 'Flieg', '5/15/1997', '48202', '21716', 'Nedi', 'ntatfordc@yellowbook.com', 27, '79996', '74bk4b', 'The Neptunes'),
('044-9rhF8', 'Samson', 'Giacomi', '2/17/1988', '60606','03997', 'Tim', 'tnafzigerh@ihg.com', 35, '79996', '74bk4b', 'NxWorries'),
('892-1C8aO', 'Jill', 'McGarrahan', '2/8/1930', '60606','25175', 'Ruby', 'rkilloughi@google.co.jp', 34, '79996', '74bk4b','NxWorries');/* 3rd*/


SET datestyle = dmy;
insert into concert (code_concert, date_of_concert, sales, concert_organizer, cityConcert)
values 
('55527', '20/01/2020', 4679, '06744', '10007'),
('11638', '02/09/2020', 4048, '06744', '97210'),
('15586', '03/07/2020', 9751, '06744', '60606'),
('92380', '01/01/2020', 9416, '06744', '94104'),
('77153', '04/03/2020', 17, '06744', '33162'),
('39722', '28/02/2020', 3867, '06744', '60606'),
('96142', '31/01/2020', 9007, '63460', '10007'),
('11697', '17/05/2020', 7532, '63460', '10007'),
('66282', '20/10/2020', 963, '63460', '97210'),
('39932', '14/11/2020', 3039, '63460', '94104'),
('32902', '21/02/2020', 456, '63460', '33162'),
('63701', '31/03/2020', 1202, '63460', '33162'),
('02889', '25/04/2020', 1328, '79996', '10007'),
('72342', '08/06/2020', 2162, '79996', '60606'),
('24808', '22/06/2020', 6052, '79996', '97210');



SET datestyle = mdy;
insert into producer (SSN, first_name, last_name, date_of_birth, birthplace, id_prod,  producers_employer) values
('428-1EsfZ', 'Elia', 'Duffin', '2/11/1936', '77070','28oj77', '06744'),
('378-ORRog', 'Cart', 'Swateridge', '7/20/1935', '10007','82if31', '63460'),
('107-kf1Fj', 'Melisenda', 'Manus', '11/14/1980', '60606','24mi07', '06744'),
('763-cWHjq', 'Ginni', 'Chillistone', '2/26/1987', '90210','74xs90',  '06744'),
('455-As8IQ', 'Hayes', 'O''Crevan', '5/16/1979', '48202', '72lh73', '79996'),
('520-xB8RF', 'Adela', 'Slany', '12/5/1986', '90210', '36wp73', '79996');

insert into video (code_video, title, length) values
('78ju0v', 'in tempus sit', 299),
('86cr2m', 'lacus morbi', 626),
('03ao0a', 'felis sed interdum', 966),
('67lf8a', 'ornare consequat', 217),
('80rw3s', 'et ultrices posuere', 397),
('69ak1y', 'quis lectus', 38),
('61xk1m', 'pede morbi', 865),
('76ho5h', 'quis libero', 957),
('93kh9s', 'libero nullam sit', 766),
('91qi0b', 'viverra diam vitae', 1125),
('04fl8q', 'accumsan odio ', 220);




insert into record (code_rec, name, hit, copies_sold, producer_rec, video_id, record_client, revenues_record, sales, genre ) values
('62972', 'It Was Written', 'pellentesque ultrices phasellus', 10000, '28oj77', '78ju0v','98272', '06744', 1000000, 'Rock'),
('79057', 'Abbey Road', 'at vulputate vitae', 20000, '82if31', '86cr2m','45514', '63460', 2000000, 'Pop' ),
('18369', 'The Blueprint', 'nec dui luctus', 30000, '24mi07', '03ao0a','78442', '06744', 3000000, 'Heavy Metal'),
('57276', 'Futuristic Interface', 'pede libero', 25000, '82if31', '67lf8a','80461', '63460', 2500000, 'Classical'),
('32487', 'DDL', 'posuere nonummy integer', 15000, '74xs90', '69ak1y','78059', '06744', 1500000, 'Rap'),
('01059', 'Adaptive', 'elit ac nulla', 50000, '72lh73', '93kh9s', '25175', '79996', 5000000, 'Opera'),
('07240', 'Inverse', 'posuere cubilia', 40000, '36wp73', '91qi0b','03997', '79996', 4000000, 'Jazz');

insert into performing(code_performance, code_concert, code_client) values
('5890', '55527', '98272'),
('5891', '11638', '45514'),
('5892', '15586', '21716'),
('5893', '92380', '42186'),
('5894', '77153', '08462'),
('5895', '77153', '09256'),
('5897', '77153', '42186'),
('6897', '77153', '80461'),
('7895', '92380', '80461'),
('6898', '24808', '42186'),
('6892', '15586', '45514'),
('5898', '72342', '80461'),
('9890', '32902', '08462'),
('9891', '32902', '98272'),
('9892', '32902', '78059');

insert into gadget (id_product, name, type, branding_client, corp_id, sales) values
('06xl2b', 'Autobiography', 'Book', '98272', '06744', 150000),
('02dl2s', 'Our Journey', 'Movie', '45514', '63460', 125000),
('83aq5k', 'Blueprint: the making of a legendary record', 'Documentary', '78442', '06744', 72000),
('65kp0h', 'Vivamus Metus Arcu', 'Videogame', '80461', '63460', 90000),
('32tm9p', 'Thundercats - Action Figures', 'Toys', '78059', '06744', 190000),
('77ao8t', 'Freedom', 'Book', '25175', '79996', 85000),
('37he6t', 'Life', 'Magazine', '03997','79996',  200000);

insert into award (id_award, name, date, winning_record) values
('97258', 'Best single', '2/21/2020', '62972'),
('49321', 'Best guitar track', '9/5/2020', '79057'),
('20003', 'Most insightful lyrics', '10/31/2020', '62972'),
('27289', 'Best drum track', '4/6/2020', '62972'),
('50838', 'Best voice performance', '2/23/2020', '62972'),
('94955', 'Worst single', '10/8/2020', '79057'),
('34556', 'Best album', '3/22/2020', '01059'),
('79959', 'Best mixing', '10/20/2020', '07240'),
('91485', 'Music Award', '3/24/2020', '07240'),
('06308', 'Best artwork', '9/9/2020', '62972'),
('81404', 'Best performance', '5/28/2020', '57276'),
('24536', 'Best cover of song', '3/3/2020', '07240'),
('23060', 'Best soundtrack', '4/19/2020', '07240'),
('13586', 'Reward for brilliant career', '12/23/2020', '62972'),
('81940', 'Gold Award', '12/1/2020', '18369');



END TRANSACTION;


/*QUERIES*/




SELECT client.first_name, client.last_name, client.group_name, city.name from client, city WHERE client.birthplace=city.postal_code and year_of_career>12 AND city.name = 'Seattle' AND client.group_name IS NOT NULL ;

SELECT genre from record where copies_sold =(SELECT max(copies_sold) from record) ;

SELECT postal_code, name from city where postal_code NOT IN(SELECT location from MUSIC_CORPORATION);

SELECT DISTINCT producer.id_prod, producer.first_name, producer.last_name
	from record, producer,award, (SELECT count(id_award) as num, winning_record as awardedRecord from award group by winning_record )as numOfAward
	where numOfAward.awardedRecord= record.code_rec and producer_rec=id_prod and num>4;

SELECT avg(numOfClient.clients) from client, (Select count(code) as clients from client group by corp_promoting ) as numOfClient;

SELECT client.stage_name, performing.code_concert from performing, client where performing.code_client=client.code;


select sales as sale, tax_number as corp  from music_corporation, concert where concert_organizer=tax_number;

select sum(sale), music_corporation.name from
music_corporation, record, concert, gadget,
(select sum(record.sales) as sale, tax_number as corp from music_corporation, record where revenues_record=tax_number group by corp
union
select sum(concert.sales) as sale, tax_number as corp  from music_corporation, concert where concert_organizer=tax_number group by corp
union
select sum(gadget.sales) as sale, tax_number as corp  from music_corporation, gadget where corp_id=tax_number group by corp)  temp3
where corp=tax_number group by music_corporation.name, corp;




