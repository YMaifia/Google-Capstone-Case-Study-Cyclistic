/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ride_id]
      ,[rideable_type]
      ,[started_at]
      ,[ended_at]
      ,[start_station_name]
      ,[start_station_id]
      ,[end_station_name]
      ,[end_station_id]
      ,[start_lat]
      ,[start_lng]
      ,[end_lat]
      ,[end_lng]
      ,[member_casual]
  FROM [Case-Study1].[dbo].['202201-divvy-tripdata$']

/* COPY the headers into a new table called dbo.tripdata */
SELECT TOP 0 * INTO dbo.tripdata from dbo.['202201-divvy-tripdata$'];

/* Insert tables into dbo.tripdata  */

INSERT INTO dbo.tripdata SELECT * from  dbo.['202201-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202202-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202203-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202204-divvy-tripdata$'];

INSERT INTO dbo.tripdata SELECT * from  dbo.['202205-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202206-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202207-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202208-divvy-tripdata$'];

INSERT INTO dbo.tripdata SELECT * from  dbo.['202209-divvy-publictripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202210-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202211-divvy-tripdata$'];
INSERT INTO dbo.tripdata SELECT * from  dbo.['202212-divvy-tripdata$'];
  

  select* from dbo.tripdata

  /* Data cleaning */

  -- look for duplicate to delete:

   select ride_id, count(*) as duplicate 
    from dbo.tripdata
       group by ride_id
         having count(*) >1

  -- check for null value:

   select *
      from dbo.tripdata
         where 
          started_at is null or
          ended_at is null or
          start_lat is null or 
          start_lng is null or 
          end_lat is null or 
          end_lng is null

 -- Delete null values :

  Delete 
   from dbo.tripdata
    where  
      start_lat is null or start_lng is null or end_lat is null or end_lng is null


  --  Delete incoherent data: 

     delete 
     from dbo.tripdata
     where ended_at < started_at



  -- Extract day and quarter from trip start time in a computed column:
     --  day_of_the_week:
   
         alter table dbo.tripdata
         add day_of_the_week as DATEPART(weekday, started_at)
   
     --  Year Quater:
   
        alter table dbo.tripdata
        add year_quarter as datepart(quarter, started_at)

/* Data exploration*/

--  Total users in each category:
 
      select member_casual, count(*)
      from dbo.tripdata
         group by member_casual

 -- Percentage of each user type 
 
    select member_casual, count(member_casual) as user_type, 
    concat(convert(decimal(10,2), count(*)*100.0/sum(count(*)) over()),'%')
         from dbo.tripdata
         group by member_casual

 -- calculate ride_lenght in minute in a computed column:
   
      alter table dbo.tripdata
       add ride_lenght as datediff(mi, started_at, ended_at)

 --   Sum ride_lenght per user type: 
 
     select member_casual, sum(ride_lenght) as total_ride_lenght
     from dbo.tripdata
     group by member_casual 

-- ride per weekday:

     select member_casual, case 
       when day_of_the_week= '1' then 'sunday' 
	   when day_of_the_week= '2' then 'monday'
	   when day_of_the_week= '3' then 'tuesday'
	   when day_of_the_week= '4' then 'wednesday'
	   when day_of_the_week= '5' then 'thursday'
	   when day_of_the_week= '6' then ' friday'
	   when day_of_the_week= '7' then 'saturday'
	   END as day_of_week,
	   count(*) total_ride
          from dbo.tripdata
          group by member_casual, day_of_the_week
          order by member_casual


-- ride per weekday:

     select member_casual, case 
       when day_of_the_week= '1' then 'sunday' 
	   when day_of_the_week= '2' then 'monday'
	   when day_of_the_week= '3' then 'tuesday'
	   when day_of_the_week= '4' then 'wednesday'
	   when day_of_the_week= '5' then 'thursday'
	   when day_of_the_week= '6' then ' friday'
	   when day_of_the_week= '7' then 'saturday'
	   END as day_of_week,
	   count(*) total_ride
          from dbo.tripdata
          group by member_casual, day_of_the_week
          order by member_casual
          
-- total ride per quarter :

    select member_casual, case 
       when year_quarter= '1' then 'Q1' 
	   when year_quarter= '2' then 'Q2'
	   when year_quarter= '3' then 'Q3'
	   when year_quarter= '4' then 'Q4'
	    END As quarter,
	    count(*) as total_ride
           from dbo.tripdata
           group by member_casual, year_quarter
           order by member_casual
           
-- Sum ride_lenght per weekday :

    select member_casual, case 
       when day_of_the_week= '1' then 'sunday' 
	   when day_of_the_week= '2' then 'monday'
	   when day_of_the_week= '3' then 'tuesday'
	   when day_of_the_week= '4' then 'wednesday'
	   when day_of_the_week= '5' then 'thursday'
	   when day_of_the_week= '6' then ' friday'
	   when day_of_the_week= '7' then 'saturday'
	   END as day_of_week, sum(ride_lenght) as total_ride_lenght
           from dbo.tripdata
           group by member_casual, day_of_the_week
           
--   Sum ride_lenght per year quarter:

     select member_casual, case 
      when year_quarter= '1' then 'Q1' 
	  when year_quarter= '2' then 'Q2'
	  when year_quarter= '3' then 'Q3'
	  when year_quarter= '4' then 'Q4'
	  END as year_quarter, sum(ride_lenght) as total_ride_lenght
          from dbo.tripdata
          group by member_casual, year_quarter
           
 --   total ride per day range (AM-PM):
 
      with cte as (select member_casual, started_at,
      case
        when datepart(hour, started_at) <12 then 'AM'
        Else 'PM' end as day_range
         from dbo.tripdata)
      select member_casual, day_range, count(*)
        from cte
        group by member_casual,day_range
        
 --   Sum ride lenght per day range (AM-PM):
  
      with cte as (select member_casual, started_at, ride_lenght,
      case
        when datepart(hour, started_at) <12 then 'AM'
        Else 'PM' end as day_range
        from dbo.tripdata)
      select member_casual, day_range, sum(ride_lenght)
        from cte
        group by member_casual,day_range
  
  --   Total ride per bike type: 
  
      select member_casual, rideable_type, count(*)
	   from dbo.tripdata
	      group by member_casual, rideable_type
       
 --  max  ride lenght per user type:
 
      select member_casual, max(ride_lenght) as max_ride_lenght
        from dbo.tripdata
          group by member_casual

-- calculate average ride lenght:
   
     select member_casual, avg(ride_lenght) as average_ride_lenght
          from dbo.tripdata
              group by member_casual

 --  calculate the standard deviation: 
 
    select member_casual, stdev(ride_lenght) as stdev_ride_lenght
       from dbo.tripdata
          group by member_casual

 --  calculate the median:
 
    select member_casual, PERCENTILE_CONT(0.5) within group (order by ride_lenght)         over(partition by member_casual) as median
          from dbo. tripdata