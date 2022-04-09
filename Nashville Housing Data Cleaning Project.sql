Select *
From dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------

-- Convert SalesDate to Date Data Type

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM dbo.Nashville_Housing

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date;

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress where NULL

Select *
From dbo.Nashville_Housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Nashville_Housing a
JOIN dbo.Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Nashville_Housing a
JOIN dbo.Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Break out PropertyAddress into (City, Address)

Select PropertyAddress
FROM dbo.Nashville_Housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address

FROM dbo.Nashville_Housing

-- Address
ALTER TABLE dbo.Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE dbo.Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- City
ALTER TABLE dbo.Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE dbo.Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

----------------------------------------------------------------------------------------------------------------------------

-- Break up Owner Address into State, City, Address

SELECT OwnerAddress
FROM dbo.Nashville_Housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM dbo.Nashville_Housing

-- Address
ALTER TABLE dbo.Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE dbo.Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- City
ALTER TABLE dbo.Nashville_Housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE dbo.Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

-- State
ALTER TABLE dbo.Nashville_Housing
ADD OwnerSplitState Nvarchar(255);

UPDATE dbo.Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.Nashville_Housing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From dbo.Nashville_Housing


Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.Nashville_Housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

--Dropping TaxDistrict because 53.94% Null

--SELECT DISTINCT TaxDistrict, COUNT(UniqueID)  AS num_of_properties, COUNT(UniqueID) * 100.00 / SUM(COUNT(UniqueID)) OVER () AS percent_of_total
--FROM dbo.Nashville_Housing
--GROUP BY TaxDistrict


Select *
From dbo.Nashville_Housing


ALTER TABLE dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate