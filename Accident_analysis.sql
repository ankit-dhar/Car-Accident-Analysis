--Creating Databae
create database accident_analysis
use accident_analysis

--Tables Used 
select * from accident;
select * from vehicle;

--Q1 Number in accidents in urban areas versus rural areas
create proc Area_wise_accidents
as 
begin 
	select area,count(area) as [Number of accidents]
	from accident
	group by area
end 

exec Area_wise_accidents

--Q2 Which day of week has highest number of accidents
create proc day_with_highest_accidents
as 
begin 
	select top 2
	day,count(AccidentIndex) as [Number of Accidents]
	from accident
	group by day
	order by  [Number of Accidents] desc
end 

exec day_with_highest_accidents

--Q3 Average age of vehicals involved in accidents and their types
alter table vehicle 
alter column agevehicle int

select v.vehicleType as [Vehicle Type],avg(isnull(v.agevehicle,0)) as [Average Age in Years]
from vehicle as v
group by v.vehicleType
order by [Average Age in Years] desc

--Q4 Trends in accidents based on age of vehicles 
select * from vehicle

create proc accidents_by_age_of_vehicle
as 
begin 
	select count(accidentindex) as [Number of Accidents], isnull(agevehicle,0) as [Age of Vehicle]
	from vehicle
	group by agevehicle
	order by [Number of Accidents] desc
end

exec accidents_by_age_of_vehicle

--Q5 Weather conditions that contribute to severe accidents (severe accidents are those that are fatal or serious)
create proc severity_with_weather
as 
begin 
	select WeatherConditions as [Weather Conditions],
	sum(case when Severity='Fatal' then 1 else 0 end) as [Fatal],
	sum(case when Severity='Serious' then 1 else 0 end) as [Serious],
	sum(case when Severity='Slight' then 1 else 0 end) as [Slight],
	sum(case when Severity in ('Fatal','serious') then 1 else 0 end) as [Severe Accidents]
	from accident
	group by WeatherConditions
	order by WeatherConditions 
end 

exec severity_with_weather;

--Q6 Impact on left hand side 
select lefthand [Impact on Left Hand],count(*) as [Count]
from vehicle
group by lefthand
order by [Count] desc

--Q7 Realtion Between Journey purpose and severiety of accidents
create proc journeypurpose_Severity
as 
begin 
	select (journeypurpose) as [purpose of journey], 
	sum(case when Severity='Fatal' then 1 else 0 end) as [Fatal],
	sum(case when Severity='Serious' then 1 else 0 end) as [Serious],
	sum(case when Severity='Slight' then 1 else 0 end) as [Slight]
	from accident as a 
	join vehicle as v 
	on a.AccidentIndex=v.AccidentIndex
	where journeypurpose is not null
	group by journeypurpose
end

exec journeypurpose_Severity;

--Q8 Avgerage age of vehicles involved in accidents 
--light condiotion and point of impact as two variable inputs
create proc avg_age_basedon_lightCondition_PointOfImpact 
(@lightcondition varchar(100), @PoI varchar(100))
as 
begin 
	select avg(v.agevehicle) as [Average Age of Vehicle]
	from vechicle as v 
	join accident as a 
	on a.AccidentIndex=v.AccidentIndex
	where a.LightConditions= @lightcondition and v.pointimpact=@PoI
end

exec avg_age_basedon_lightCondition_PointOfImpact 'DayLight','Offside'


--Q9 Realations with speed and severity

create proc speed_and_severity
@speed int
as 
begin 
	select RoadConditions,
	sum(case when Severity='Fatal' then 1 else 0 end) as [Fatal],
	sum(case when Severity='Serious' then 1 else 0 end) as [Serious],
	sum(case when Severity='Slight' then 1 else 0 end) as [Slight],
	count(AccidentIndex) as [Total Accidents]
	from accident
	where SpeedLimit=@speed 
	group by SpeedLimit,RoadConditions
	order by [Total Accidents] desc
end

exec speed_and_severity 40
drop proc speed_and_severity

