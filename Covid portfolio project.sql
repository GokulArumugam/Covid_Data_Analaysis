--TABLE: 1
SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--TABLE: 2
SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


-- SELECT THE DATA THAT WE ARE GOING TO BE USING


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases Vs. Total Deaths in tearms of percentage to find out how many % of people dies with the increasing in total_cases
-- It shows the likelihood of Dying if you contact covid in your country


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
AND continent IS NOT NULL
ORDER BY 1,2



-- Looking at the total cases VS. Population
-- This query will help us to find the answer for the question 'what percentage affected by Covid?'


SELECT Location, date, Population, total_cases,(total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
ORDER BY 1,2



-- Looking at Countries with Highest Infection Rate compared to Population
--"What countries have the highest infection rate when compared to the Population?"


SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC



-- Showing Countries with Highest Death Count per Population
--I have used CAST function becasue the Total_deaths column in my data had nvarchar data type

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Trying to break down by continent so that we get a clear picture about the data we are relying upon. 
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global numbers
--Query to check the number date wise (date is optional as we we need only the total cases,total deaths and DeathPercentage

SELECT DATE, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2

--Query to check the number without date 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2



--Looking at Total Population Vs. Vaccinations
--RollingPeopleVaccinated column addes the no. of people got vaccinated on a rolling basis

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations 
, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location,DEA.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
ORDER BY 2,3


--Shows Percentage of Population that has recieved at least one Covid Vaccine
--Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations 
, SUM(CONVERT(BIGINT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location,DEA.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PopvsVac 


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations 
, SUM(CONVERT(BIGINT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location,DEA.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL 
ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
From #PercentPopulationVaccinated 




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations 
, SUM(CONVERT(BIGINT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location,DEA.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
     AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--ORDER BY 2,3


SELECT * FROM PercentPopulationVaccinated
