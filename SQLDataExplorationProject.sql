
/*In the following project i will be exploring the Covid19 Dataset taken from ourworldindata.org
I will be looking into some intriguing stats and figures by querying the dataset.*/

--Taking a proper look at both the tables.

Select *
From CovidDataExploration..CovidCases
Where continent is not null
Order By 3,4

Select *
From CovidDataExploration..CovidVaccinations
Where continent is not null
Order By 3,4

--Selecting a few columns that can be useful

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDataExploration..CovidCases
Where continent is not null 
order by 1,2

--Calculating the infection rate worldwide

Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectionRate
From CovidDataExploration..CovidCases
Where continent is not null
Order By 1,2

--Calculating the highest infection rate for each country

Select Location,Population, MAX(total_cases) as TotalCases,  MAX((total_cases/population))*100 as HighestInfectionRate
From CovidDataExploration..CovidCases
Where continent is not null
Group By location,population
Order By HighestInfectionRate desc

--Calculating the infection rate of India

Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectionRate
From CovidDataExploration..CovidCases
Where location = 'India'
Order By 1,2

--Calculating the mortality rate worldwide

Select Location, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths,
(MAX(cast(total_deaths as int))/MAX(total_cases))*100 as MortalityRate
From CovidDataExploration..CovidCases
Where continent is not null
Group By location
order by MortalityRate desc

--Calculating the mortality rate in India

Select Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as MortalityRate
From CovidDataExploration..CovidCases
Where continent is not null
AND location = 'India'
order by 1,2

--Number of mortalities per continent

Select location, MAX(cast(Total_deaths as int)) as Mortalities
From CovidDataExploration..CovidCases
Where continent is null
AND
(location='Asia' or location='Europe' or location='South America' or location='North America' or location='Africa' or location='Oceania')
Group by location
order by Mortalities desc

--Global Statistics

Select location,SUM(population) OVER (Partition by Location) as TotalPopulation
,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as MortalityRate
,MAX((total_cases/population))*100 as InfectionRate
From CovidDataExploration..CovidCases
where continent is not null 
group by location,population
order by 3 desc

--Total vaccinations carried out per country

Select cas.location, cas.population,MAX(cast(vac.Total_vaccinations as bigint)) as VaccinesAdministered
From CovidDataExploration..CovidCases Cas join CovidDataExploration..CovidVaccinations Vac
On cas.location = vac.location
and cas.date = Vac.date
Where cas.continent is not null
Group by cas.location,cas.population
Order by 1 

--Percentage of population vaccinated(Atleast first dose)

DROP Table if exists #PopulationVaccinated
Create Table #PopulationVaccinated
(
Location nvarchar(255),
Population numeric,
PeopleVaccinated numeric
)

Insert into #PopulationVaccinated
Select cas.location,cas.population
,MAX(cast(vac.people_vaccinated as bigint)) as PeopleVaccinated
From CovidDataExploration..CovidCases cas
Join CovidDataExploration..CovidVaccinations vac
On cas.location = vac.location
And cas.date = vac.date
Where cas.continent is not null
Group by cas.location,cas.population


Select *, (PeopleVaccinated/Population)*100 as VaccinationPercentage
From #PopulationVaccinated
Order By 1

--Percentage of population completely vaccinated

DROP Table if exists #CompletelyVaccinated
Create Table #CompletelyVaccinated
(
Location nvarchar(255),
Population numeric,
FullyVaccinated numeric
)

Insert into #CompletelyVaccinated
Select cas.location,cas.population
,MAX(cast(vac.people_fully_vaccinated as bigint)) as FullyVaccinated
From CovidDataExploration..CovidCases cas
Join CovidDataExploration..CovidVaccinations vac
On cas.location = vac.location
And cas.date = vac.date
Where cas.continent is not null
Group by cas.location,cas.population


Select *, (FullyVaccinated/Population)*100 as CompleteVaccinationPercentage
From #CompletelyVaccinated
Order By 1

--Percentage of average tests conducted daily by countries

Create View DailyTests as
Select cas.location, cas.population
,AVG(cast(vac.new_tests as bigint)) as AverageTests
From CovidDataExploration..CovidCases cas
Join CovidDataExploration..CovidVaccinations vac
On cas.location = vac.location
and cas.date = vac.date
where cas.continent is not null
Group By cas.location,cas.population

Select *, (AverageTests/population)*100 as Percentage
From DailyTests
Order By 3 desc

