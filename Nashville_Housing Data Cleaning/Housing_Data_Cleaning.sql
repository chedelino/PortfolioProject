-- Nashville Housing Data Cleaning

-- In this Project, I use some of the most common techniques data cleaning techniques in SQL.

-- Skills used: Joins, CTE's, Converting Data Types, Remove duplicates, CASE WHEN, PARSENAME, SUBSTRING, PARTITION BY 


-- Quick inspection of the entire dataset

Select *
From PortfolioProject..NashvilleHousingData$


-- Standardize the date format of SaleDate column 

ALTER TABLE NashvilleHousingData$
Add ConvertedSaleDate Date

Update NashvilleHousingData$
SET ConvertedSaleDate = CONVERT(Date,SaleDate)


Select ConvertedSaleDate
From PortfolioProject..NashvilleHousingData$


-- Populate PropertyAddress data to remove null values


Select dt.ParcelID, dt.PropertyAddress, dx.ParcelID, dx.PropertyAddress, ISNULL(dt.PropertyAddress,dx.PropertyAddress)
From PortfolioProject..NashvilleHousingData$ dt
JOIN PortfolioProject..NashvilleHousingData$ dx
	on dt.ParcelID = dx.ParcelID
	AND dt.[UniqueID ] <> dx.[UniqueID ]
Where dt.PropertyAddress is null



Update dt
SET PropertyAddress = ISNULL(dt.PropertyAddress,dx.PropertyAddress)
From PortfolioProject..NashvilleHousingData$ dt
JOIN PortfolioProject..NashvilleHousingData$ dx
	on dt.ParcelID = dx.ParcelID
	AND dt.[UniqueID ] <> dx.[UniqueID ]
Where dt.PropertyAddress is null



-- Breaking out PropertyAddress into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingData$


ALTER TABLE NashvilleHousingData$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingData$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousingData$
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousingData$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--Using PARSENAMNE to break out OwnerAddress into Individual Columns

Select OwnerAddress
FROM PortfolioProject..NashvilleHousingData$


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashvilleHousingData$


ALTER TABLE NashvilleHousingData$
Add OwnerAddress Nvarchar(255);

Update NashvilleHousingData$
SET OwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousingData$
Add OwnerCity Nvarchar(255);

Update NashvilleHousingData$
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousingData$
Add OwnerState Nvarchar(255);

Update NashvilleHousingData$
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousingData$
Group by SoldAsVacant
Order by Count(SoldAsVacant) DESC


Select SoldAsVacant,
 CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousingData$


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates rows from the dataset

WITH DuplicateCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) DupRows

From PortfolioProject..NashvilleHousingData$
--order by ParcelID
)
DELETE
From DuplicateCTE
Where DupRows > 1



-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousingData$


ALTER TABLE PortfolioProject..NashvilleHousingData$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

