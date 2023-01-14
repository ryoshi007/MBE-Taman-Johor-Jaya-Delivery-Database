/* 1. View the number of pickup done by each delivery pickup company per month.*/

SELECT
    ps.pickup_company AS pickup_company,
    EXTRACT (MONTH FROM dp.pickup_datetime) AS month,
    COUNT(dp.pickup_staff_id) AS frequency 
FROM PICKUP_STAFF ps
JOIN DELIVERY_PICKUP dp
ON ps.pickup_staff_id = dp.pickup_staff_id
GROUP BY 
    EXTRACT(MONTH FROM dp.pickup_datetime),
    pickup_company
ORDER BY pickup_company;

/* 2. Show the state with the number of successful delivery on descending order */

SELECT ADDRESS."state", COUNT(PARCEL.parcel_tracking_id) AS number_of_delivered
FROM ADDRESS
INNER JOIN PARCEL_DELIVERY_INFO ON (ADDRESS.address_id = PARCEL_DELIVERY_INFO.recipient_address_id)
INNER JOIN PARCEL ON (PARCEL_DELIVERY_INFO.delivery_info_id = PARCEL.delivery_info_id)
WHERE PARCEL.parcel_status = 'DELIVERED'
GROUP BY ADDRESS."state"
ORDER BY number_of_delivered DESC;

/* 3. View the information of the box with the largest quantity in the Inventory Table.*/

SELECT *
FROM
    (SELECT *
    FROM INVENTORY
    WHERE INVENTORY.item_name LIKE '%Box%'
    ORDER BY INVENTORY.item_quantity DESC)
WHERE ROWNUM = 1

/* 4. View and search for addresses owned by people who lived in Klang Valley.*/

SELECT PERSON.person_name, ad.address_line, ad.city, ad."state", ad.postal_code
FROM PERSON
INNER JOIN PERSON_ADDRESS
    ON PERSON.person_id = PERSON_ADDRESS.person_id
INNER JOIN ADDRESS ad
    ON ad.address_id = PERSON_ADDRESS.address_id
WHERE ad."state" = 'WPKL' OR ad."state" = 'Selangor' OR ad."state" = 'Putrajaya';

/* 5. Calculate the overtime salary earned by each staff on 19 Oct 2022.*/

SELECT res.staff_name, res.check_in_time, res.check_out_time, res.difference_in_hour, ROUND((res.difference_in_hour - 9)*res.overtime_rate, 2) AS overtime_pay, res.overtime_rate
    FROM (
        SELECT
        STAFF.staff_name as staff_name, wk.check_in_time as check_in_time, wk.check_out_time as check_out_time,
        ROUND(((EXTRACT(MINUTE FROM wk.check_out_time - wk.check_in_time) + EXTRACT(SECOND FROM wk.check_out_time - wk.check_in_time)/60)/60 + EXTRACT(HOUR FROM wk.check_out_time - wk.check_in_time)),2) as difference_in_hour,
        ps.overtime_rate as overtime_rate
        FROM STAFF
        INNER JOIN WORK_TIME wk
        ON wk.staff_id = STAFF.staff_id
        INNER JOIN POSITION ps
        ON ps.position_id = STAFF.position_id
        WHERE wk.work_date = TO_DATE ('2022-10-19', 'YYYY-MM-DD')
        )res
ORDER BY overtime_pay ASC;

/* 6. View the staff who serves the customers more than 3 times.*/

SELECT STAFF.staff_name, COUNT(custs.customer_service_id) AS number_of_service
FROM STAFF
INNER JOIN CUSTOMER_SERVICE custs
    ON custs.staff_id = STAFF.staff_id
GROUP BY staff_name
HAVING COUNT(custs.customer_service_id) > 3;

/* 7. View the contract that has expired.*/

SELECT sup.supplier_id, sup.supplier_name, cont.contract_description, cont.contract_start_date, cont.contract_end_date
FROM SUPPLIER sup
INNER JOIN SUPPLIER_CONTRACT cont
    ON cont.supplier_id = sup.supplier_id
WHERE cont.contract_end_date < sysdate;

/* 8. View the receipt of successful payments paid with card above RM20 and payment is made before August*/

SELECT *
FROM RECEIPT
JOIN PAYMENT USING (payment_id)
WHERE PAYMENT_METHOD = 'CARD' AND PAYMENT_AMOUNT > 20 AND PAYMENT_TRANSACTION_STATUS = 'SUCCESS'
AND RECEIPT_DATETIME < TO_DATE('2022-08-01', 'YYYY-MM-DD');

