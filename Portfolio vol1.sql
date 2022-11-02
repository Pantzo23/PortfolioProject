SELECT *
FROM Portofolio..['covid death$']
where continent is not null
order by 3,4

--SELECT *
--FROM Portofolio..['covid vaccination$']
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
FROM Portofolio..['covid death$']
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract  covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portofolio..['covid death$']
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs population
-- Shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as Percentagepopulationinfected
FROM Portofolio..['covid death$']
Where location like '%reece%'
order by 1,2


-- Look at countries with the hightest infection rate compared to population

Select Location, population,MAX(total_cases) as Highestinfection, MAX((total_cases/population))*100 as Percentagepopulationinfected
FROM Portofolio..['covid death$']
--Where location like '%states%'
Group by location,population
order by Percentagepopulationinfected desc

-- Showing countries with the hightest death count per population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolio..['covid death$']
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THIS DOWN BY CONTINENTS



-- Showing contintents with the hightest death counts per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolio..['covid death$']
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select SUM(new_cases) as Total_cases ,SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
From Portofolio..['covid death$']
--Where location like '%states%'
where continent is not null
--group by date
--order by 1,2


-- Looking at Total population vs Vaccination
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from Portofolio..['covid death$'] dea
join Portofolio..['covid vaccination$'] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingpeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from Portofolio..['covid death$'] dea
join Portofolio..['covid vaccination$'] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%lbania%'
--order by 2,3
)
select * , (RollingpeopleVaccinated/population)*100
from PopvsVac


-- Temp table 

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from Portofolio..['covid death$'] dea
join Portofolio..['covid vaccination$'] vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--and dea.location like '%lbania%'
--order by 2,3

select * , (RollingpeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations 

create view PercentPopulationVaccinated as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from Portofolio..['covid death$'] dea
join Portofolio..['covid vaccination$'] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%lbania%'
--order by 2,3


select *
from PercentPopulationVaccinated