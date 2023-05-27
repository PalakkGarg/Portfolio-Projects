/*
Covid 19 Data Exploration 

*/
use sqlportfolioproject;

SELECT * FROM covid_deaths 
where continent != ''
order by 3,4;

-- Select Data that we are going to be starting with

select location, date, total_cases,new_cases,total_deaths,population 
from covid_deaths
where continent != '' 
order by 1,2;

-- Change the data type of the Date Column

UPDATE `sqlportfolioproject`.`covid_deaths`
SET `date` = STR_TO_DATE(`date`, '%d-%m-%Y');

ALTER TABLE `sqlportfolioproject`.`covid_deaths`
MODIFY COLUMN `date` DATETIME NULL DEFAULT NULL;

-- Looking at Total Cases vs Total Deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from covid_deaths 
-- where location = 'India'
-- and continent != ''
order by 1,2;

-- Looking at the Total Cases vs Population

select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected 
from covid_deaths 
-- where location = 'India'
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

select Location,Population,max(total_cases) as HighestInfectionCount,population, max((total_cases/population))*100 as PercentPopulationInfected 
from covid_deaths 
-- where location = 'India'
group by location, population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

select Location,max(total_deaths) as TotalDeathCount
from covid_deaths 
where continent != ''
group by location
order by TotalDeathCount desc;

-- Total Population vs Vaccinations

select covid_deaths.continent, covid_deaths.location,covid_deaths.date,covid_deaths.population, covid_vaccinations.new_vaccinations,
sum(covid_vaccinations.new_vaccinations) over (partition by covid_deaths.location order by covid_deaths.location, covid_deaths.date)
as RollingPeopleVaccinated
from covid_deaths inner join covid_vaccinations
on covid_deaths.location = covid_vaccinations.location
and covid_deaths.date = covid_vaccinations.date
where covid_deaths.continent != ''
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

	with PopulationVSVaccition(Continent,Location,Date,Population,New_Vaccitions,RollingPeopleVaccinated)
	as
	(
	select covid_deaths.continent, covid_deaths.location,covid_deaths.date,covid_deaths.population, covid_vaccinations.new_vaccinations,
	sum(covid_vaccinations.new_vaccinations) over (partition by covid_deaths.location order by covid_deaths.location, covid_deaths.date)
	as RollingPeopleVaccinated
	from covid_deaths inner join covid_vaccinations
	on covid_deaths.location = covid_vaccinations.location
	and covid_deaths.date = covid_vaccinations.date
	where covid_deaths.continent != ''
	order by 2,3
	)
	select * , (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
	from PopulationVSVaccition;

-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists PercentPopulationVaccinated;
create temporary table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccitions text,
RollingPeopleVaccinated numeric
);
insert into PercentPopulationVaccinated
select covid_deaths.continent, covid_deaths.location,covid_deaths.date,covid_deaths.population, covid_vaccinations.new_vaccinations,
sum(covid_vaccinations.new_vaccinations) over (partition by covid_deaths.location order by covid_deaths.location, covid_deaths.date)
as RollingPeopleVaccinated
from covid_deaths inner join covid_vaccinations
on covid_deaths.location = covid_vaccinations.location
and covid_deaths.date = covid_vaccinations.date
where covid_deaths.continent != ''
order by 2,3;

select * , (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from PercentPopulationVaccinated;
