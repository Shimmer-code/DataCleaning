SELECT *
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

--标准化销售时间格式Standarlize SaleDate Format
SELECT SaleDate,CONVERT(Date,SaleDate)
From [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET SaleDate=CONVERT(Date,SaleDate)


--将ParcelID相同但空缺PropertyAdress的ID填充相同地址Populate PropertyAdress
SELECT PropertyAddress
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
where PropertyAddress is null

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning] b
 ON a.ParcelID=b.ParcelID and 
	a. [UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning] b
 ON a.ParcelID=b.ParcelID and 
	a. [UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--将以逗号为分隔符的长字符段PropertyAddress中的内容分隔成三个不同部分
SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1,LEN(PropertyAddress)) as Address
FROM 
  [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
WHERE 
  PropertyAddress IS NOT NULL 
  AND PropertyAddress <> ''
  AND CHARINDEX(',', PropertyAddress) > 0

  ALTER TABLE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  ADD PropertySplitAddress NVARCHAR(255)

  UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
  WHERE PropertyAddress IS NOT NULL AND CHARINDEX(',', PropertyAddress) > 0;

  ALTER TABLE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  ADD PropertySplitCity NVARCHAR(255)

  UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  SET PropertySplitCity=  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1,LEN(PropertyAddress))

  SELECT *
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]


--以更简单的方法对长字符段对OwnerAddress进行分隔
SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  ADD OwnerSplitCity NVARCHAR(255)

UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  SET OwnerSplitCity=  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  ADD OwnerSplitState NVARCHAR(255)

UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
  SET OwnerSplitState=  PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

--将SoldAsVacant里面的Y和N统一修改为Yes和No
SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by SoldAsVacant desc
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END



--将表中重复的数据删除Remove Duplicates
WITH ROWNUMCTE AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference ORDER BY UniqueID)row_num
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning])
SELECT *
FROM ROWNUMCTE
WHERE row_num>1
--order by PropertyAddress


--删除不必要的数据Delete unused columns
SELECT *
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress,PropertyAddress,TAXDistrict,SaleDate
