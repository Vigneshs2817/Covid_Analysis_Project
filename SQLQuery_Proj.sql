select *
from Portfolio_Project..CovidDeaths
order by 3,4

--select *
--from Portfolio_Project..CovidVaccinations
--order by 3,4

--selecting the required data

select location, date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..CovidDeaths
order by 1,2

--Total cases vs Total deaths

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
--particularly in INDIA
where location='India'
order by 1,2

--TotalCases vs Population

select location, date,total_cases,population,(total_cases/population)*100 as AffectedPercentage
from Portfolio_Project..CovidDeaths
order by 1,2


select location ,population, max(total_cases) as HighestInfected , Max(total_cases/population)*100 as AffectedPercentage
from Portfolio_Project..CovidDeaths
group by location ,population
order by 4 desc

--Countries with highest death count per population

select location ,population , max(total_deaths)as HighestDeathCount ,max(total_deaths/population)*100 as deathperPopulation
from Portfolio_Project..CovidDeaths
group by location ,population
order by 4 desc

--The above may be wrong because in some cases the continents are null and in the location place the continent name is provided 

select location,max(cast(total_deaths as int)) as Max_death
from Portfolio_Project..CovidDeaths
group by location 
order by 2 desc

--since the numbers are in the wrong count as the datatype of the total_deaths are not in int format
--thus we can do casting

select location,max(cast(total_deaths as int)) as Max_death
from Portfolio_Project..CovidDeaths
group by location 
order by 2 desc


--death rates by continent and location

select continent ,max(cast(total_deaths as int))
from Portfolio_Project..CovidDeaths
group by continent
order by 1

select location ,max(total_deaths)
from Portfolio_Project..CovidDeaths
group by location
order by 1

--Since in the location are we found continents name and in continent column we see null row ,resolving it

select *
from Portfolio_Project..CovidDeaths
where continent is null
order by 3,4

--replacing the continent name with the location

UPDATE Portfolio_Project..CovidDeaths
SET continent = COALESCE(continent, location)
WHERE continent IS NULL;


--we can find day-by-day cases and deaths 
select date,sum(new_cases) as totalNewCases,sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/nullif (sum(new_cases),0)*100as deathPercentage
from Portfolio_Project..CovidDeaths
group by date
order by 1,2

--total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--Day by Day vaccination count using Partition by

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPplVacc
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null		
order by 2,3

--Since we cant use directly the created column to a formula so we need to create a CTE 

with PopvsVacc (continent,location,date,population,new_vaccinations,RollingPplVacc) 
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPplVacc
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null)	

SELECT *,(RollingPplVacc/population)*100 as PerVaccinated
FROM PopvsVacc;


--let see the above using a temp table 
drop table if exists #vaccperpop 
create table #vaccperpop 
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVacc numeric
)
insert into #vaccperpop 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPplVacc
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
--where dea.continent is not null	

SELECT *,(RollingPplVacc/population)*100 as Per_Vaccinated
FROM #vaccperpop
order by 1

--let us create a view table for later visualisation
create view vaccperpop as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPplVacc
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date

select * 
from vaccperpop

