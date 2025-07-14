Task 1: Basic SELECT Query
retrieve all columns from the clients table in the sql_invoicing database. 

	SELECT * 
	from clients
	
Task 2: Filtering with WHERE Clause
retrieve the name, city, and state of clients from the clients table who are located in the state of California (CA)

	SELECT name, city, state 
	from clients
	where state = 'CA'
	
Task 3: Sorting with ORDER BY
retrieve the name and city of all clients from the clients table, sorted alphabetically by name in ascending order.

	SELECT name, city 
	FROM clients
	ORDER BY name ASC
	
Task 4: Using Multiple Conditions with WHERE
retrieve the invoice_id, number, and invoice_total from the invoices table where the invoice_total is greater than 150 and the client_id is 5.
	
	SELECT invoice_id, number, invoice_total 
	FROM invoices
WHERE invoice_total > 150 AND client_id = 5

Task 5: Using OR and IN for Flexible Filtering
retrieve the invoice_id, number, client_id, and invoice_date from the invoices table for invoices where the client_id is either 1 or 3, and the invoice_date is in the year 2019.

	SELECT invoice_id, number, client_id, invoice_date 
	from invoices 
	where client_id in (1,3) and year(invoice_date) = 2019
	
Task 6: Joining Tables with INNER JOIN
retrieve the invoice_id, number, invoice_total, and the name of the client from the invoices and clients tables. Only include invoices where the associated client exists (use an INNER JOIN)

	SELECT i.invoice_id, i.number, i.invoice_total, c.name
FROM invoices i
JOIN clients c ON c.client_id = i.client_id
	
Task 7: Joining Multiple Tables
retrieve the invoice_id, number, invoice_total, the client’s name, and the name of the payment method from the invoices, clients, and payments tables. Only include invoices that have associated payments (use INNER JOIN for both joins).
	
	SELECT i.invoice_id, i.number, i.invoice_total, c.name, pm.name 
	from invoices i 
	join clients c on c.client_id = i.client_id 
	join payments p on p.invoice_id = i.invoice_id 
	join payment_methods pm on p.payment_method = pm.payment_method_id order by invoice_id
	
Task 8: Using LEFT JOIN for Optional Relationships
retrieve the invoice_id, number, invoice_total, and the client’s name from the invoices and clients tables, and include the amount and date from the payments table. Use a LEFT JOIN to include all invoices, even those without payments

	SELECT i.invoice_id, i.number, i.invoice_total, c.name, p.amount, p.date
	from invoices i
	    join clients c on c.client_id = i.client_id
	    left join payments p on p.invoice_id = i.invoice_id
	order by invoice_id
	
Task 9: Aggregation with GROUP BY
calculate the total invoice_total and total payment_total for each client in the invoices table, along with the client’s name. Use the clients and invoices tables, and group the results by client.

	SELECT c.name, 
       COALESCE(SUM(i.invoice_total), 0) AS total_invoiced, 
       COALESCE(SUM(i.payment_total), 0) AS total_paid
FROM clients c
LEFT JOIN invoices i ON c.client_id = i.client_id
GROUP BY c.client_id, c.name
ORDER BY COALESCE(SUM(i.invoice_total), 0) DESC

Task 10: Aggregation with HAVING Clause
find clients who have a total invoice_total greater than 500, showing their name, total invoice_total, and the number of invoices. Use the clients and invoices tables

	SELECT c.name, 
       COALESCE(SUM(i.invoice_total), 0) AS total_invoiced, 
       COUNT(i.invoice_id) AS invoice_count
FROM invoices i
LEFT JOIN clients c ON c.client_id = i.client_id
GROUP BY c.client_id, c.name
HAVING COALESCE(SUM(i.invoice_total), 0) > 500
ORDER BY COALESCE(SUM(i.invoice_total), 0) DESC
	
Task 11: Combining Aggregations with Subqueries
find clients who have paid more than 50% of their total invoiced amount. Show the client’s name, total invoiced amount, total paid amount, and the payment percentage

	SELECT name, total_invoiced, total_paid,
	       CASE 
	           WHEN total_invoiced = 0 THEN 0
	           ELSE (total_paid / total_invoiced * 100)
	       END AS payment_percentage
	FROM (
	    SELECT c.name, 
	           COALESCE(SUM(i.invoice_total), 0) AS total_invoiced, 
	           COALESCE(SUM(i.payment_total), 0) AS total_paid
	    FROM clients c
	    LEFT JOIN invoices i ON c.client_id = i.client_id
	    GROUP BY c.client_id, c.name
	) t
	WHERE total_invoiced > 0
	HAVING total_paid / total_invoiced > 0.5
	ORDER BY payment_percentage DESC
	
Task 12: Filtering Date Comparisons with Aggregation
find clients who have at least one invoice with a payment date later than the due date. Show the client’s name, the number of late invoices, and the total invoice_total of those late invoices.

	SELECT s.name, 
       COUNT(s.invoice_id) AS late_invoices,
       COALESCE(SUM(s.invoice_total), 0) AS total_late_invoiced
FROM (
    SELECT c.name, c.client_id, i.invoice_id, i.invoice_total, i.due_date, i.payment_date
    FROM clients c
    LEFT JOIN invoices i ON i.client_id = c.client_id
    WHERE i.payment_date IS NOT NULL AND i.payment_date > i.due_date
) s
GROUP BY s.client_id, s.name
HAVING COUNT(s.invoice_id) > 0
ORDER BY late_invoices DESC
	
Task 13: Unpaid Invoices by Client 
find clients with unpaid invoices (invoices where payment_total = 0 or payment_date is NULL). Show the client’s name, the number of unpaid invoices, and the total invoice_total of unpaid invoices.

	select name,
		 count(invoice_date) as unpaid_invoices, 
		coalesce(sum(invoice_total),0) as invoice_total 
	from clients c 
	left join invoices i on i.client_id = c.client_id 
	where payment_total = 0 or payment_date is null 
	group by c.client_id, c.name 
	order by unpaid_invoices desc

Task 14: Advanced Aggregation with HAVING
find clients whose total unpaid invoice balance (invoice_total - payment_total) exceeds $200. Show the client’s name, the number of unpaid or partially paid invoices, and the total unpaid balance.

select x.name, count(x.invoice_id) as no_of_unpaid_invoices,
	 (coalesce(sum(x.invoice_total),0) - coalesce(sum(x.payment_total),0)) as total_unpaid_amount 
from (
	select c.name,  c.client_id,  i.invoice_id,  i.invoice_total, i.payment_total
	from clients c 
		left join invoices i on i.client_id = c.client_id
		where i.invoice_total > i.payment_total) x
group by x.client_id
having COALESCE(SUM(x.invoice_total - x.payment_total), 0) > 200
order by total_unpaid_amount desc
----------------------------------------------------
select c.name, 
count(i.invoice_id) as unpaid_invoices, 
coalesce(sum(i.invoice_total-i.payment_total),0) as unpaid_amount
from clients c 
	left join invoices i on c.client_id = i.client_id
group by c.client_id, c.name
having coalesce(sum(i.invoice_total -i.payment_total),0) > 200
order by unpaid_amount desc

Task 15: Filtering by Date with Aggregation
find clients with unpaid or partially paid invoices issued in 2019. Show the client’s name, the number of such invoices, and the total unpaid balance for those invoices.

select c.name, count(i.invoice_id) as unpaid_invoices_2019, sum(i.invoice_total-i.payment_total) as total_unpaid_balance_2019
from clients c 
left join invoices i on c.client_id = i.client_id
where YEAR(invoice_date) = 2019
group by c.client_id, c.name
having sum(i.invoice_total-i.payment_total) > 0 and count(i.invoice_id) > 0
order by total_unpaid_balance_2019

Task 16: Combining Date and Null Checks with Aggregation
 find clients with overdue invoices (invoices where the due date has passed, and the invoice is unpaid or partially paid). Show the client’s name, the number of overdue invoices, and the total unpaid balance of those invoices.

SELECT 
c.name, 
COUNT(i.invoice_id) AS overdue_invoices, 
COALESCE(SUM(i.invoice_total - i.payment_total), 0) AS total_unpaid_balance
FROM 
clients c 
LEFT JOIN invoices i ON c.client_id = i.client_id
WHERE 
i.payment_date IS NULL OR i.payment_date > i.due_date 
GROUP BY 
c.name, c.client_id
ORDER BY 
total_unpaid_balance DESC; 

Task 17: Subquery Aggregation
find clients whose average unpaid balance per invoice (for unpaid or partially paid invoices) exceeds the overall average unpaid balance per invoice across all clients. Show the client’s name, number of unpaid invoices, and their average unpaid balance per invoice.

SELECT c.name, 
       COUNT(i.invoice_id) AS unpaid_invoices,
       COALESCE(AVG(i.invoice_total - i.payment_total), 0) AS avg_unpaid_balance
FROM clients c
LEFT JOIN invoices i ON c.client_id = i.client_id
WHERE i.invoice_total > i.payment_total
GROUP BY c.client_id, c.name
HAVING COALESCE(AVG(i.invoice_total - i.payment_total), 0) > (
    SELECT AVG(invoice_total - payment_total)
    FROM invoices
    WHERE invoice_total > payment_total
)
ORDER BY avg_unpaid_balance DESC


Task 18: Window Functions for Ranking
Write a SQL query to rank clients by their total unpaid balance for unpaid or partially paid invoices, assigning a rank based on the balance. Show the client’s name, number of unpaid invoices, total unpaid balance, and their rank.

select c.name, count(invoice_id) as unpaid_invoices, COALESCE(SUM(i.invoice_total - i.payment_total), 0) AS total_unpaid_balance, 
	rank() over( order by  COALESCE(SUM(i.invoice_total - i.payment_total), 0) desc) as 'rank'
	from clients c 
	left join invoices i 
	on i.client_id = c.client_id 
	group by c.client_id, c.name
    having SUM(i.invoice_total - i.payment_total) != 0 







