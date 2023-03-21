select *
from CovidDeaths
where continent is not null
order BY 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in United States

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
-- show what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc


-- showing the countries with the highest death count per populatiion

select location, MAX (total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- let's break things down by continent
-- showing the continents with the highest death count

select continent, MAX (total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by [continent]
order by TotalDeathCount desc


-- GLOBAL NUMBERS


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
case
  when sum(new_cases) = 0 then null
  else sum(cast(new_deaths as float))/sum(new_cases)*100 
end as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2 

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 -- using CTE

 with PopsvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 )
 select *, (RollingPeopleVaccinated/population)*100
 from PopsvsVac


 -- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent NVARCHAR (255),
Location NVARCHAR (255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 order by 2,3

 select *, (RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null


select*
from PercentPopulationVaccinated