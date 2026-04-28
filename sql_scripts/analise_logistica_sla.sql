/* CONSULTA AVANÇADA: PERFORMANCE LOGÍSTICA POR ESTADO
   Objetivo: Medir o SLA de entrega cruzando dados de pedidos e localização dos clientes.
*/

WITH EficienciaEntrega AS (
    SELECT 
        c.customer_state,
        o.order_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        -- Cálculo de dias reais vs prometidos (Sintaxe SQLite/Standard)
        JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp) AS dias_entrega_real,
        JULIANDAY(o.order_estimated_delivery_date) - JULIANDAY(o.order_purchase_timestamp) AS dias_prazo_prometido
    FROM olist_orders_dataset o
    INNER JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)

SELECT 
    customer_state AS estado,
    COUNT(order_id) AS total_pedidos,
    ROUND(AVG(dias_entrega_real), 2) AS media_dias_entrega,
    -- Calculando a porcentagem de pedidos atrasados usando CASE WHEN
    ROUND(
        SUM(CASE WHEN dias_entrega_real > dias_prazo_prometido THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 
        2
    ) AS percentual_atraso_sla
FROM EficienciaEntrega
GROUP BY customer_state
ORDER BY percentual_atraso_sla DESC;
