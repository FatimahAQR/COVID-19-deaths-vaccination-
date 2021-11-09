
select *
from portoflioprojectcovid..coviddeaths
where continent is not null
order by 3,4

--select * 
--from portoflioprojectcovid..covidvaccination
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths,population
from portoflioprojectcovid..coviddeaths
where continent is not null
order by 1,2

-- Now i'm making a super simple calculation to now
--total deaths Vs total cases | shows likelihood of dying if you contract covied in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portoflioprojectcovid..coviddeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Now lokking at total cases Vs population
-- Show us what percentage of population got covied

select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is not null
order by 1,2

--what country have higher infecation rate depend on population
--countries with highes infection reates compared to population we use her MAX because we are looking for the highest

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is not null
Group By population, location
order by percentpopulationinfected desc

-- Showin countries with highest death per population here we want the integer total deaths no percentage

select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is not null
Group By location
order by TotalDeathCount desc 

-- Now lest see everything depend on CONTIENT

select continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is not null
Group By continent
order by TotalDeathCount desc 

-- golbal numbers

select date, SUM(new_cases) as GlobalNumbers
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

-- sum newcases and new deaths and get the percentage globally depend on date

select date, SUM(new_cases) as totalcases, SUM(CAST(new_deaths as INT)) as totaldeathas, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100  as Deathpercentage
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--- sum new cases and deaths and death percentage globally


select SUM(new_cases) as totalcases, SUM(CAST(new_deaths as INT)) as totaldeathas, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100  as Deathpercentage
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is not null
order by 1,2

--now we are display covid vaccination table
select*
from portoflioprojectcovid..covidvaccination

-- now we are gonna join the two table together

select *
from portoflioprojectcovid..covidvaccination vac
join portoflioprojectcovid..coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date

--looking at total population Vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portoflioprojectcovid..covidvaccination vac
join portoflioprojectcovid..coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
order by 1,2

--

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as rollingpeoplevaccinated
from portoflioprojectcovid..covidvaccination vac
join portoflioprojectcovid..coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- now we gonna use CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as ( 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as rollingpeoplevaccinated
from portoflioprojectcovid..covidvaccination vac
join portoflioprojectcovid..coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null )

select *, (rollingpeoplevaccinated/population)
from popvsvac

-- TEM table

Drop Table if exists #percentagepeoplevaccinated
Create Table #percentagepeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated numeric,
)


Insert into #percentagepeoplevaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as rollingpeoplevaccinated
from  portoflioprojectcovid..coviddeaths dea
join  portoflioprojectcovid..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select *, (rollingpeoplevaccinated/population)
from #percentagepeoplevaccinated 
order by Location
 
--- create view ti stire data later for visualization

create view percentagepeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as rollingpeoplevaccinated
from  portoflioprojectcovid..coviddeaths dea
join  portoflioprojectcovid..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select location, SUM(CAST(new_deaths as INT)) as totaldeathas
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
where continent is null
and location not in ('world', 'European Union', 'International')
group by location
order by totaldeathas desc

select location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
from portoflioprojectcovid..coviddeaths
--where location like '%states%'
Group By location,population,date
order by percentpopulationinfected desc