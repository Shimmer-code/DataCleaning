SELECT *
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

--��׼������ʱ���ʽStandarlize SaleDate Format
SELECT SaleDate,CONVERT(Date,SaleDate)
From [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

UPDATE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET SaleDate=CONVERT(Date,SaleDate)


--��ParcelID��ͬ����ȱPropertyAdress��ID�����ͬ��ַPopulate PropertyAdress
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

--���Զ���Ϊ�ָ����ĳ��ַ���PropertyAddress�е����ݷָ���������ͬ����
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


--�Ը��򵥵ķ����Գ��ַ��ζ�OwnerAddress���зָ�
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

--��SoldAsVacant�����Y��Nͳһ�޸�ΪYes��No
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



--�������ظ�������ɾ��Remove Duplicates
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


--ɾ������Ҫ������Delete unused columns
SELECT *
FROM [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE [SQL Portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress,PropertyAddress,TAXDistrict,SaleDate
