/*

Limpando os Dados - SQL Queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardizing the data format

SELECT 
SaleDateConverted,
CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

--Populate propery Adress Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT
a.[UniqueID ],
a.ParcelID,
a.PropertyAddress,
b.[UniqueID ],
b.ParcelID,
b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into individual Columns (Adress, City, State)

SELECT *
FROM PortfolioProject..NashvilleHousing

-- PropertyAdress

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyStreet NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- OwnerAddress

SELECT *--OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreet NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

-- Change Y an N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT
SoldAsVacant,
COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

/*
DELETE
FROM RowNumCTE
WHERE row_num > 1 
*/

SELECT *
FROM RowNumCTE
WHERE row_num > 1 

-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
