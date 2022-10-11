select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2;

-- look at total cases vs total deaths, shows likelyhood of dying
-- if you re infected with covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage 
from covid_deaths
where location like 'Russia'
order by 1,2;


--total_cases vs population
select location, date,population, total_cases, (total_cases/population)*100 as cases_percentage 
from covid_deaths
where location = 'Russia'
order by 1,2;;

--highest death rate in countries
select location, population, max(total_deaths) as max_deaths, 
max(total_deaths/population)*100 as max_death_rate
from covid_deaths
group by 1,2
order by 4 desc;


--highest infection rate in countries
select location, population, max(total_cases) as max_cases, 
max(total_cases/population)*100 as max_case_rate
from covid_deaths
group by 1,2
order by 4 desc;

-- global statistics
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, round(Cast(float8 (SUM(new_deaths)/SUM(new_cases))*100 as numeric),3)||'%' as DeathPercentage
FROM covid_deaths
where continent is not NULL
group by date
order by 1,2;

with PopvsVac (continent, location, date, population, new_vac, vac_per_country) AS
(
select dea.continent, dea.LOCATION, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as BIGINT )) over ( Partition by dea.location order by dea.location, dea.date) as vac_per_country
from covid_deaths as dea 
JOIN covid_vaccination as vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3
);

select * from PopvsVac;

select *, round(Cast(float8(vac_per_country/population)*100 as numeric),3)||'%' as percentage_vaccinated 
from PopvsVac
where location = 'Russia';

DROP TABLE if exists extra_tab;
creating temp table
drop table if exists extra_tab;
create temp table extra_tab as 
(select dea.continent, dea.LOCATION, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as BIGINT )) over ( Partition by dea.location order by dea.location, dea.date) as vac_per_country
from covid_deaths as dea 
JOIN covid_vaccination as vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3
)

select *, vac_per_country/population*100 from extra_tab;


-- creating view to vizualise data

DROP VIEW if exists percentvacpop;
CREATE VIEW PercentVacPop as 
(
select dea.continent, dea.LOCATION, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as BIGINT )) over ( Partition by dea.location order by dea.location, dea.date) as vac_per_country
from covid_deaths as dea 
JOIN covid_vaccination as vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
	);

select * from PercentVacPop;