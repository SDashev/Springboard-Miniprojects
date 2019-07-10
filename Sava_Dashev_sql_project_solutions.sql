/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.
==
In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT `facid` , `name` , `membercost` 
FROM `Facilities` 
WHERE `membercost` =0



/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( `facid` ) AS no_charge_facilities, `membercost` 
FROM `Facilities` 
WHERE `membercost` =0



/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT `facid`,
	   `name`,
	   `membercost`,
	   `monthlymaintenance`
	FROM
	   `Facilities`
	WHERE
	   `membercost` < 0.20 * `monthlymaintenance`

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * , `facid` 
FROM `Facilities` 
WHERE `facid` IN ( 1, 5 )




/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT `facid`,
		   `monthlymaintenance`,
		   CASE WHEN `monthlymaintenance` <=100 THEN `facid` ELSE NULL END AS `cheap`,
		   CASE WHEN `monthlymaintenance` >100 THEN `facid` ELSE NULL END AS `expensive`
		FROM `Facilities` 


		

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT `firstname`,
		   `surname`,
		   `joindate`,
		   MAX(`joindate`) AS last_sighup
		FROM `Members`
		WHERE `firstname` != "GUEST"
		       OR `surname` !=`"GUEST"
			   
			   
			   

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT `f`.`facid` , `m`.`memid` , CONCAT( `name`," " , `memname` ) 
	FROM `Bookings` AS `b` 
	JOIN `Facilities` AS `f` ON `b`.`facid` = `f`.`facid` 
	JOIN ( SELECT `memid`, CONCAT(`firstname` ," ", `surname` ) AS `memname`
			FROM `Members`
		) AS `m` ON `m`.`memid` = `b`.`memid`
	WHERE `f`.`facid` IN ( 0, 1 ) 
		AND `m`.`memid` !=0
	GROUP BY `memname`
	ORDER BY `memname`
	   

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT `b`.`facid`,
	   `f`.`facid`,
	   `m`.`memid`,
	   `b`.`starttime`,
	   `f`.`name` AS `facilityused`,
	   CASE WHEN `b`.`memid` != 0 THEN CONCAT(`firstname` ," ", `surname` ) ELSE 
			`firstname` END AS `patronname`,
	   CASE WHEN `b`.`memid` != 0 THEN `f`.`membercost` ELSE 
			`f`.`guestcost` END AS `cost`
	   
	FROM `Bookings` AS `b`
		JOIN `Members` AS `m` ON `m`.`memid` = `b`.`memid`
		JOIN `Facilities` AS `f` ON `f`.`facid` = `b`.`facid`
	WHERE `starttime` LIKE "2012-09-14%"
	GROUP BY `b`.`memid`
	ORDER BY `cost` DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT `b`.`facid`,
	   `f`.`facid`,
	   `m`.`memid`,
	   `b`.`starttime`,
	   `f`.`name` AS `facilityused`,
	   `c`.`patronname`,
	   `c`.`cost`
	   
	   
	FROM `Bookings` AS `b`
		JOIN `Members` AS `m` ON `m`.`memid` = `b`.`memid`
		JOIN `Facilities` AS `f` ON `f`.`facid` = `b`.`facid`
		JOIN
		(SELECT `b`.`memid` AS  `cid`., 
			    CASE WHEN `b`.`memid` != 0 THEN CONCAT(`firstname` ," ", `surname` ) ELSE 
					`firstname` END AS `patronname`,
			    CASE WHEN `b`.`memid` != 0 THEN `f`.`membercost` ELSE 
					`f`.`guestcost` END AS `cost`
		) AS `c` ON `cid` = `b`.`memid`
	WHERE `starttime` LIKE "2012-09-14%"
	GROUP BY `b`.`memid`
	ORDER BY `c`.`cost` DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT `facilityused`,
	   `revenue` 
	FROM
		(SELECT SUM( `c`.`cost` ) AS `revenue` , `facilityused` 
		FROM (
			SELECT `f`.`facid` , `m`.`memid` , `b`.`starttime` , `f`.`name` AS `facilityused` ,  
				   CASE WHEN `b`.`memid` !=0 THEN `f`.`membercost` 
						ELSE `f`.`guestcost` END AS `cost` 
				FROM `Bookings` AS `b` 
					JOIN `Members` AS `m` ON `m`.`memid` = `b`.`memid` 
					JOIN `Facilities` AS `f` ON `f`.`facid` = `b`.`facid` 
				ORDER BY `cost` DESC ) AS `c` 
		GROUP BY `facilityused`) AS `r`
	WHERE `revenue` < 1000
	ORDER BY `revenue` DESC