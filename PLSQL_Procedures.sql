/*Discount Procedure*/
CREATE OR REPLACE PROCEDURE DISCOUNT_AMOUNT
(dlNum IN CUSTOMER.DL_NUMBER%TYPE,
amount IN BILLING.TOTAL_AMOUNT%TYPE,
discountCode IN DISCOUNT.DISCOUNT_CODE%TYPE,
discountAmt OUT BILLING.DISCOUNT_AMOUNT%TYPE) AS
--local declarations
memberType CUSTOMER.MEMBERSHIP_TYPE%TYPE;
discountPercentage DISCOUNT.DISCOUNT_PERCENTAGE%TYPE;
BEGIN
SELECT MEMBERSHIP_TYPE INTO memberType FROM CUSTOMER
WHERE DL_NUMBER = dlNum;
IF NVL(discountCode,'NULL') <> 'NULL' THEN
SELECT DISCOUNT_PERCENTAGE INTO discountPercentage
FROM DISCOUNT WHERE DISCOUNT_CODE = discountCode;
IF memberType = 'M' THEN
discountAmt := amount * ((discountPercentage+10)/100);
ELSE
discountAmt := amount * (discountPercentage/100);
END IF;
ELSE
IF memberType = 'M' THEN
discountAmt := amount * 0.1;
ELSE
discountAmt := 0;
END IF;
END IF;
END;
/

/*Late Fee Procedure*/
CREATE OR REPLACE PROCEDURE LATE_FEE_AND_TAX
(actualReturnDateTime IN BOOKING.ACT_RET_DT_TIME%TYPE,
ReturnDateTime IN BOOKING.RET_DT_TIME%TYPE,
regNum IN BOOKING.REG_NUM%TYPE,
amount IN BOOKING.AMOUNT%TYPE,
totalLateFee OUT BILLING.TOTAL_AMOUNT%TYPE,
totalTax OUT BILLING.TAX_AMOUNT%TYPE ) AS
--local declarations
lateFeePerHour BIKE_CATEGORY.LATE_FEE_PER_HOUR%TYPE;
hourDifference DECIMAL(10,2);
BEGIN
SELECT LATE_FEE_PER_HOUR INTO lateFeePerHour
FROM BIKE_CATEGORY BC INNER JOIN BIKE B ON BC.CATEGORY_NAME =
B.BIKE_CATEGORY_NAME WHERE B.REGISTRATION_NUMBER = regNum;
IF actualReturnDateTime > ReturnDateTime THEN
hourDifference := (TO_DATE (TO_CHAR (actualReturnDateTime,
'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')
- TO_DATE (TO_CHAR (ReturnDateTime, 'dd/mm/yyyy hh24:mi:ss')
,'dd/mm/yyyy hh24:mi:ss'))*(24);
totalLateFee := hourDifference * lateFeePerHour;
ELSE
totalLateFee := 0;
END IF;
totalTax := (amount + totalLateFee)*0.0825;
END;
/

/*Revenue Report Procedure*/
CREATE OR REPLACE PROCEDURE REVENUE_REPORT AS
--local declarations
thisLocationID LOCATION.LOCATION_ID%TYPE;
currentLocationID LOCATION.LOCATION_ID%TYPE;
locationName LOCATION.LOCATION_NAME%TYPE;
thisCategoryName BIKE_CATEGORY.CATEGORY_NAME%TYPE;
thisNoOfBikes integer; thisRevenue DECIMAL(15,2);
--Cursor declaration
CURSOR CURSOR_REPORT IS SELECT TABLE1.LOCATIONID, TABLE1.CATNAME ,
TABLE1.NOOFBIKES,SUM(NVL((TABLE2.AMOUNT),0)) AS REVENUE
FROM (SELECT LC.LID AS LOCATIONID, LC.CNAME AS CATNAME ,
COUNT(B.REGISTRATION_NUMBER) AS NOOFBIKES FROM (SELECT
L.LOCATION_ID AS LID, BC.CATEGORY_NAME AS CNAME FROM
BIKE_CATEGORY BC CROSS JOIN LOCATION L) LC LEFT OUTER JOIN
BIKE B ON LC.CNAME = B.BIKE_CATEGORY_NAME AND LC.LID = B.LOC_ID
GROUP BY LC.LID, LC.CNAME ORDER BY LC.LID) TABLE1 LEFT OUTER JOIN
(SELECT BBC.PLOC AS PICKLOC,BBC.CNAME AS CNAMES, SUM(BL.TOTAL_AMOUNT) AS
AMOUNT FROM (SELECT B.PICKUP_LOC AS PLOC, B1.BIKE_CATEGORY_NAME AS CNAME,
B.BOOKING_ID AS BID FROM BOOKING B INNER JOIN BIKE B1 ON
B.REG_NUM = B1.REGISTRATION_NUMBER) BBC INNER JOIN BILLING BL
ON BBC.BID = BL.BOOKING_ID WHERE
(to_date (SYSDATE,'dd-MM-yyyy') - to_date(BL.BILL_DATE,'dd-MM-yyyy'))
<=30 GROUP BY BBC.PLOC,BBC.CNAME ORDER BY BBC.PLOC) TABLE2
ON TABLE1.LOCATIONID=TABLE2.PICKLOC AND TABLE1.CATNAME = TABLE2.CNAMES
GROUP BY TABLE1.LOCATIONID, TABLE1.CATNAME, TABLE1.NOOFBIKES
ORDER BY TABLE1.LOCATIONID;
BEGIN
dbms_output.put_line(' ');
dbms_output.put_line('Revenue Report');
OPEN CURSOR_REPORT;
FETCH CURSOR_REPORT INTO thisLocationID, thisCategoryName,
thisNoOfBikes, thisRevenue;
IF CURSOR_REPORT%NOTFOUND THEN
dbms_output.put_line('No Report to be generated');
ELSE
currentLocationID := thisLocationID;
<<LABEL_NEXTLOC>>
SELECT LOCATION_NAME INTO locationName from LOCATION
WHERE LOCATION_ID = currentLocationID;
dbms_output.put_line('Location Name: '|| locationName);
dbms_output.put_line(' ');
dbms_output.put_line('Bike Category' || ' '||'Number of Bikes'
||' '|| 'Revenue');
dbms_output.put_line('------------' || ' '||'--------------'
||' '|| '-------');
dbms_output.put_line(thisCategoryName ||
RPAD(' ', (16 - LENGTH(thisCategoryName)))||thisNoOfBikes
||RPAD(' ', (18 - LENGTH(thisNoOfBikes)))|| thisRevenue);
LOOP
FETCH CURSOR_REPORT INTO thisLocationID, thisCategoryName,
thisNoOfBikes, thisRevenue;
EXIT WHEN (CURSOR_REPORT%NOTFOUND);
IF thisLocationID = currentLocationID THEN
dbms_output.put_line(thisCategoryName ||
RPAD(' ', (16 - LENGTH(thisCategoryName)))||thisNoOfBikes
||RPAD(' ', (18 - LENGTH(thisNoOfBikes)))|| thisRevenue);
ELSE
currentLocationID := thisLocationID;
dbms_output.put_line(' ');
dbms_output.put_line('***********************
*********************************************
*************************************');
dbms_output.put_line(' ');
GOTO LABEL_NEXTLOC;
END IF;
END LOOP;
END IF;
END;
/
