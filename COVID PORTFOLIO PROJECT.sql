-- comments done in between this characters *(  )* are translations to spanish

SELECT *
FROM covid_deaths
WHERE continent is not NULL
ORDER BY location,date

--SELECT *
--FROM covid_vaccinations
--ORDER BY location,date
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent is not NULL
ORDER BY location, date

--looking at total cases vs total deaths *(al mirar los casos totales y las muertes totales)*
--Shows likelihood of dying if you contract covid in your country *( se muestra la probabilidad de morir al contraer Covid en tu pais)*
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_deaths
where location like '%xico'
ORDER BY total_cases DESC

--looking at total cases vs population *(al mirar los casos totales y la poblacion total)*
--Shows the percentage of the population infected with covid *( se muestra el porcentage de poblacion total infectada con Covid en tu pais)*
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_percentage
FROM covid_deaths
WHERE location like '%xico' 
ORDER BY location, date

-- looking at countries with highest infection rate compared to population *( al mirar a los paises con mayor tasa de infeccion comparada con su poblacion)*
-- Shows the most infected countries *(nos muestra los paises mas infectados)*
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 AS Infected_Percentage
FROM covid_deaths
GROUP BY location, population
ORDER BY Infected_Percentage desc

--showing countries with Highest Death Count per Population *(mostrando paises por tasa de muertes mas alta respecto a la poblacion)*
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount, MAX((cast(total_deaths as int))/POPULATION)*100 AS Total_Deaths_Percentage
FROM covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY Total_Deaths_percentage desc

--showing countries with Highest Death Count *( mostrando paises con mayor cantidad de muertes)*
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount, MAX((cast(total_deaths as int))/POPULATION)*100 AS Total_Deaths_Percentage
FROM covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc


--Deaths per income level *(muertes por nivel de ingreso)*
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE location  like '%income%'
GROUP BY location
ORDER BY TotalDeathCount desc

--Data per continent *(datos por continente)*
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent is  NULL and location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount desc


SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent is not  NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc



SELECT DEA.continent, DEA.location, DEA.date, DEA.population,VACCS.new_vaccinations, 
SUM(CAST (VACCS.new_vaccinations AS bigint)) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date)
AS ROLLING_PEOPLE_VACCINATED --, (ROLLING_PEOPLE_VACCINATED/population)*100
FROM covid_deaths AS DEA
JOIN covid_vaccinations AS VACCS
ON DEA.location = VACCS.location
AND DEA.date = VACCS.date
WHERE DEA.continent IS NOT NULL AND DEA.location LIKE '%XICO'
ORDER BY location, date

-- Using CTE (Usando CTE )
WITH POPvsVAC (continent, location, date , population, new_vaccinations, ROLLING_PEOPLE_VACCINATED)
as
(
SELECT DEA.continent , DEA.date, DEA.location, DEA.population,VACCS.new_vaccinations, 
SUM(CAST (VACCS.new_vaccinations AS bigint)) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date)
AS ROLLING_PEOPLE_VACCINATED 
--, (ROLLING_PEOPLE_VACCINATED/population)*100
FROM covid_deaths AS DEA
JOIN covid_vaccinations AS VACCS
ON DEA.location = VACCS.location
AND DEA.date = VACCS.date
WHERE DEA.continent IS NOT NULL 
)

SELECT *, (ROLLING_PEOPLE_VACCINATED/population)*100
FROM POPvsVAC

--TEMP TABLES (TABLAS TEMPORALES)
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar (255),
Date datetime,
population numeric,
New_Vaccinations numeric,
ROLLING_PEOPLE_VACCINATED numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population,VACCS.new_vaccinations, 
SUM(CAST (VACCS.new_vaccinations AS bigint)) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date)
AS ROLLING_PEOPLE_VACCINATED 
--, (ROLLING_PEOPLE_VACCINATED/population)*100
FROM covid_deaths AS DEA
JOIN covid_vaccinations AS VACCS
ON DEA.location = VACCS.location
AND DEA.date = VACCS.date
WHERE DEA.continent IS NOT NULL 

SELECT *, (ROLLING_PEOPLE_VACCINATED/population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

CREATE VIEW 
PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population,VACCS.new_vaccinations, 
SUM(CAST (VACCS.new_vaccinations AS bigint)) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date)
AS ROLLING_PEOPLE_VACCINATED 
--, (ROLLING_PEOPLE_VACCINATED/population)*100
FROM covid_deaths AS DEA
JOIN covid_vaccinations AS VACCS
ON DEA.location = VACCS.location
AND DEA.date = VACCS.date
WHERE DEA.continent IS NOT NULL 
