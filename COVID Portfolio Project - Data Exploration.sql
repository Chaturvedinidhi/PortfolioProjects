/*
Covid 19 Data Exploration Using SQL(MS SQL server management studio)
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * 
from PortfolioProject..CovidDeaths
where continent IS NOT NULL
order by 3,4


-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent IS NOT NULL
order by 1,2


--Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'INDIA' AND continent IS NOT NULL
order by 1,2



-- Total cases vs population
-- Shows what percentage of population infected with covid


select location, date,population ,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'INDIA'
order by 1,2


--Countries with Highest Infection Rate compared to Population

select location,population ,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'INDIA'
Group By Location,Population
order by PercentPopulationInfected desc



--BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the Highest Death Count per  Population


select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount from PortfolioProject..CovidDeaths
--where location = 'INDIA'
where continent IS NOT NULL
Group By continent
order by TotalDeathCount desc 



-- GLOBAL NUMBERS

select  SUM(new_cases) as total_cases , SUM(cast(new_deaths as bigint)) as total_deaths , SUM(cast(new_deaths as bigint))/SUM(new_cases)  * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'INDIA'
where continent IS NOT NULL
--Group by date
order by 1,2


--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over 
(partition by  dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
       ON dea.location = vac.location 
       AND dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3



- Using CTE to perform Calculation on Partition By in previous query

with PopvsVAC(Continent,location,date,Population,new_vaccinations,RollingPeopleVaccinated)

as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over 
(partition by  dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location 
     AND dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)* 100
from PopvsVAC




-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over 
(partition by  dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location 
     AND dea.date = vac.date
--where dea.continent IS NOT NULL
--order by 2,3

select *, (RollingPeopleVaccinated/Population)* 100 
from #PercentPopulationVaccinated




--Creating View to store data later for later visualization


Create view PercentPopulationVaccinated as 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over 
(partition by  dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3

Create view  Highestdeathcountperpopulation as
select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount from PortfolioProject..CovidDeaths
--where location = 'INDIA'
where continent IS NOT NULL
Group By Location
--order by TotalDeathCount desc

Select * from PercentPopulationVaccinated
select * from Highestdeathcountperpopulation





















