--------------------WHOLE DATASET--------------------

SELECT *
FROM   PortfolioProject..NashvilleHousing



--------------------Standardize Date Format--------------------

SELECT SaleDate
FROM   PortfolioProject..NashvilleHousing

SELECT SaleDate, CONVERT(date, SaleDate)
FROM   PortfolioProject..NashvilleHousing

---Create New Column For Corrected Data---

ALTER TABLE PortfolioProject..NashvilleHousing
ADD         SaleDateConverted date;

UPDATE PortfolioProject..NashvilleHousing
SET    SaleDateConverted = CONVERT(date, SaleDate)

---Checking Newly Inserted Data In Table---

SELECT SaleDateConverted
FROM   PortfolioProject..NashvilleHousing



--------------------Populating Property Address Data--------------------

SELECT *
FROM   PortfolioProject..NashvilleHousing
WHERE  PropertyAddress IS NULL

---Reference Point For NULL Values---

SELECT   *
FROM     PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM   PortfolioProject..NashvilleHousing A
JOIN   PortfolioProject..NashvilleHousing B
ON     A.ParcelID =B.ParcelID
AND    A.[UniqueID ] <> B.[UniqueID ]
WHERE  A.PropertyAddress IS NULL

---Populating NULL Values Using Reference Point---

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM   PortfolioProject..NashvilleHousing A
JOIN   PortfolioProject..NashvilleHousing B
ON     A.ParcelID =B.ParcelID
AND    A.[UniqueID ] <> B.[UniqueID ]
WHERE  A.PropertyAddress IS NULL

---Update Corrected Data---

UPDATE A
SET    PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM   PortfolioProject..NashvilleHousing A
JOIN   PortfolioProject..NashvilleHousing B
ON     A.ParcelID =B.ParcelID
AND    A.[UniqueID ] <> B.[UniqueID ]
WHERE  A.PropertyAddress IS NULL

---Checking Corrected Data In Table---

SELECT *
FROM   PortfolioProject..NashvilleHousing
WHERE  PropertyAddress IS NULL



--------------------Breaking Out Address Into Individual Columns [SUBSTRINGS]--------------------

SELECT PropertyAddress
FROM   PortfolioProject..NashvilleHousing

---To Seperate The Address---

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) AS Address
FROM   PortfolioProject..NashvilleHousing

---To Remove The Comma---

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
FROM   PortfolioProject..NashvilleHousing

---To Seperate The Address and State---
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
,      SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM   PortfolioProject..NashvilleHousing

---Create And Update New Column For Corrected Data---

ALTER TABLE PortfolioProject..NashvilleHousing
ADD         PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET    PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD         PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

---Checking Newly Inserted Data In Table---

SELECT *
FROM   PortfolioProject..NashvilleHousing


--------------------Breaking Out Address Into Individual Columns [PARSENAME]--------------------

SELECT OwnerAddress
FROM   PortfolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,      PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,	   PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM   PortfolioProject..NashvilleHousing

---Create And Update New Column For Corrected Data---

ALTER TABLE PortfolioProject..NashvilleHousing
ADD         OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET    OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD         OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD         OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

---Checking Newly Inserted Data In Table---

SELECT *
FROM   PortfolioProject..NashvilleHousing



--------------------Changing Y and N to Yes and No In 'Sold As Vacant' Field--------------------

SELECT DISTINCT(SoldAsVacant)
FROM   PortfolioProject..NashvilleHousing

SELECT   DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM     PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
       END
FROM   PortfolioProject..NashvilleHousing

---Update Corrected Data---

UPDATE PortfolioProject..NashvilleHousing
SET    SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                           WHEN SoldAsVacant = 'N' THEN 'No'
	                       ELSE SoldAsVacant
                           END



--------------------Removing Duplicates--------------------

---Identifying Duplicates---

WITH     RowNumCTE AS (
SELECT   *,
         ROW_NUMBER() OVER(
	     PARTITION BY ParcelID,
	                  PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
					  ORDER BY UniqueID
					  )row_num
FROM     PortfolioProject..NashvilleHousing
)
SELECT   *
FROM     RowNumCTE
WHERE    row_num > 1
ORDER BY PropertyAddress

---Deleting Duplicates---

WITH   RowNumCTE AS (
SELECT *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID
					)row_num
FROM   PortfolioProject..NashvilleHousing
)
DELETE
FROM   RowNumCTE
WHERE  row_num > 1



--------------------Deleting Unused Columns--------------------

SELECT *
FROM   PortfolioProject..NashvilleHousing

---Identifying and Deleting Unused Columns---

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

---Nice Try SaleDate---

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate



--------------------THE END--------------------