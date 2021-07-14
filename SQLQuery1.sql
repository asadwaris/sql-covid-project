
--seleselect * from Portfolio_Project..covid_vaccinations order by 3,4
--select * from Portfolio_Project..covid_death order by 3,4

--selecting data that we are going to use
--use Portfolio_Project
select location,date,total_cases, new_cases,total_deaths,population from covid_death order by 1,2

--looking at total cases vs total death
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covid_death order by 1,2

-- shows likelihood of dying if you contact covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covid_death where location='india' order by 1,2

-- looking at total cases vs total population
-- show what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as percentage_population_infected
from covid_death where location like '%states' order by 1,2


-- looking at country with highest infection rate compared to population
select location,population,max(total_cases) as total_cases_count,max(total_cases/population)*100 as percentage_population_infected
from covid_death 
--where location like '%states' 
group by location, population
order by percentage_population_infected desc

-- looking at country with highest death count per population
select location,population,max(cast(total_deaths as int)) as total_death_count,max(total_deaths/population)*100 as percentage_population_deaths
from covid_death 
--where location like '%states' 
where continent is not null
group by location, population
order by total_death_count desc

--Global numbers
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death_count,sum(cast(new_deaths as int))/sum(new_cases)*100 as deaths_percentage
from covid_death 
--where location like '%states' 
where continent is not null
group by date
order by 1,2

--have a look at vaccination data
select * from covid_vaccinations

-- join covid and vaccination data
--looking at total population vs vaccination 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as total_vaccination_current_date
from Portfolio_Project..covid_death cd
join Portfolio_Project..covid_vaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cv.continent is not null
order by 2,3

--using cte
with popvsvac (continent,location,date,population,new_vaccinations,total_vaccination_current_date)
as (select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as total_vaccination_current_date
from Portfolio_Project..covid_death cd
join Portfolio_Project..covid_vaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cv.continent is not null
--order by 2,3
)

select *,(total_vaccination_current_date/population)*100 as percentage_of_population_vaccinated_till_current_date from popvsvac


--Temp tabl

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
total_vaccination_current_date numeric
)
insert into #percentpopulationvaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as total_vaccination_current_date
from Portfolio_Project..covid_death cd
join Portfolio_Project..covid_vaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cv.continent is not null

select *,(total_vaccination_current_date/population)*100 as percentage_of_population_vaccinated_till_current_date
from #percentpopulationvaccinated
