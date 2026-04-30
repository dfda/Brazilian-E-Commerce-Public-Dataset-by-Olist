/* 
   ANÁLISE DE PERFORMANCE: RANKING DE ATRASO POR ESTADO E IMPACTO FINANCEIRO
   Este script utiliza CTEs para calcular a eficiência logística e o valor em risco.
*/

WITH BasePedidos AS (
    SELECT 
        c.customer_state,
        o.order_id,
        i.price,
        i.freight_value,
        -- Verificando se o pedido foi entregue após a data estimada
        CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
            ELSE 0 
        END AS foi_atrasado
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset i ON o.order_id = i.order_id
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
)

SELECT 
    customer_state AS estado,
    COUNT(order_id) AS total_pedidos,
    SUM(foi_atrasado) AS qtd_atrasos,
    ROUND(AVG(price), 2) AS ticket_medio,
    ROUND(SUM(freight_value), 2) AS custo_frete_total,
    -- KPI de Performance
    ROUND(CAST(SUM(foi_atrasado) AS FLOAT) / COUNT(order_id) * 100, 2) AS taxa_atraso_percent
FROM BasePedidos
GROUP BY customer_state
HAVING total_pedidos > 100 -- Filtra estados com amostra relevante
ORDER BY taxa_atraso_percent DESC;
