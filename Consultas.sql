--1. INSERTAR USUARIO PROPIETARIO
INSERT INTO tourism.owners (
  first_name, last_name, company_name,
  email, phone, tax_id,
  address_line1, city, state,
  country, postal_code
) VALUES (
  'Roberto', 'Vasquez', 'Hoteles CM S.A.',
  'roberto@hotelesmc.com', '+503-7729-7594', 'TAX-00123',
  'Calle Los Pinos #45', 'San Salvador', 'San Salvador',
  'El Salvador', '01101'
);

--2. Insertar alojamiento vinculado
INSERT INTO tourism.accommodations (
  owner_id, accommodation_type_id, location_id,
  name, description, max_guests,
  bedroom_count, bathroom_count, base_price_per_night,
  currency_code, is_active
) VALUES (
  1, 2, 3,
  'Villa Palmera', 'Hermosa villa con piscina y vista al mar',
  6, 3, 2, 150.00,
  'USD', true
);

--3. Huésped y reserva
INSERT INTO tourism.guests (
  first_name, last_name, email, phone,
  date_of_birth, nationality, passport_number
) VALUES (
  'Ana', 'López', 'ana.lopez@email.com', '+503-7999-1234',
  '1990-06-15', 'Salvadoreña', 'A12345678'
);

INSERT INTO tourism.bookings (
  guest_id, accommodation_id, room_id,
  booking_status_id, check_in_date, check_out_date,
  adult_count, child_count,
  subtotal_amount, tax_amount, discount_amount,
  total_amount, booking_reference
) VALUES (
  currval('tourism.guests_guest_id_seq'),
  1, 1, 1,
  '2025-07-01', '2025-07-05',
  2, 0,
  600.00, 78.00, 0.00,
  678.00, 'REF-2025-001'
);

-- 4. Registrar pago
INSERT INTO tourism.payments (
  booking_id, payment_date, amount,
  payment_method, payment_status,
  transaction_reference
) VALUES (
  1,
  NOW(),
  678.00,
  'Tarjeta de crédito',
  'Completado',
  'TXN-20250701-001'
);

-- 5. Alojamientos activos
SELECT
  a.accommodation_id,
  a.name,
  a.base_price_per_night,
  a.currency_code,
  a.max_guests,
  a.bedroom_count,
  a.bathroom_count
FROM tourism.accommodations a
WHERE a.is_active = true
ORDER BY a.base_price_per_night;

--6. Huéspedes por país
SELECT
  guest_id,
  first_name,
  last_name,
  email,
  nationality,
  phone
FROM tourism.guests
WHERE nationality = 'Salvadoreña'
ORDER BY last_name, first_name;

--7. Reservas por fechas
SELECT
  booking_id,
  booking_reference,
  guest_id,
  accommodation_id,
  check_in_date,
  check_out_date,
  total_nights,
  total_amount
FROM tourism.bookings
WHERE check_in_date BETWEEN '2025-07-01' AND '2025-07-31'
ORDER BY check_in_date;

--8. Actualizar precio del alojamiento
UPDATE tourism.accommodations
SET
  base_price_per_night = 175.00,
  updated_at = NOW()
WHERE accommodation_id = 1;

--9. Actualizar estado de reserva
UPDATE tourism.bookings
SET
  booking_status_id = 2,
  updated_at = NOW()
WHERE booking_id = 1;

--10. Eliminar reseña
DELETE FROM tourism.reviews
WHERE review_id = 1
  AND guest_id = 60;

--11. Reservas + huésped (INNER JOIN)
SELECT
  b.booking_id,
  b.booking_reference,
  g.first_name || ' ' || g.last_name AS huesped,
  g.email,
  b.check_in_date,
  b.check_out_date,
  b.total_amount
FROM tourism.bookings b
INNER JOIN tourism.guests g ON b.guest_id = g.guest_id
ORDER BY b.check_in_date DESC;

--12. Alojamiento completo (INNER JOIN múltiple)
SELECT
  a.accommodation_id,
  a.name AS alojamiento,
  at2.type_name AS tipo,
  o.first_name || ' ' || o.last_name AS propietario,
  l.city AS ciudad,
  l.country AS pais,
  a.base_price_per_night,
  a.max_guests
FROM tourism.accommodations a
INNER JOIN tourism.accommodation_types at2
  ON a.accommodation_type_id = at2.accommodation_type_id
INNER JOIN tourism.owners o
  ON a.owner_id = o.owner_id
INNER JOIN tourism.locations l
  ON a.location_id = l.location_id
WHERE a.is_active = true;


--13. Pagos + reservas (JOIN combinado)
SELECT
  p.payment_id,
  b.booking_reference,
  g.first_name || ' ' || g.last_name AS huesped,
  p.payment_date,
  p.amount,
  p.payment_method,
  p.payment_status,
  p.transaction_reference
FROM tourism.payments p
INNER JOIN tourism.bookings b ON p.booking_id = b.booking_id
INNER JOIN tourism.guests g ON b.guest_id = g.guest_id
ORDER BY p.payment_date DESC;

--14. Alojamientos sin reseñas
SELECT
  a.accommodation_id,
  a.name AS alojamiento,
  r.review_id,
  r.rating,
  r.review_title
FROM tourism.accommodations a
LEFT JOIN tourism.reviews r ON a.accommodation_id = r.accommodation_id
WHERE r.review_id IS NULL
ORDER BY a.name;

--15. Huéspedes sin reservas
SELECT
  g.guest_id,
  g.first_name || ' ' || g.last_name AS huesped,
  g.email,
  g.nationality
FROM tourism.guests g
LEFT JOIN tourism.bookings b ON g.guest_id = b.guest_id
WHERE b.booking_id IS NULL
ORDER BY g.last_name;

--16. Total de ingresos (SUM)
SELECT
  SUM(p.amount) AS total_ingresos,
  COUNT(p.payment_id) AS cantidad_pagos,
  AVG(p.amount) AS promedio_pago
FROM tourism.payments p
WHERE p.payment_status = 'Completado';

--17. Promedio de rating por alojamiento (AVG)
SELECT
  a.accommodation_id,
  a.name AS alojamiento,
  ROUND(AVG(r.rating)::numeric, 2) AS rating_promedio,
  COUNT(r.review_id) AS total_resenas
FROM tourism.accommodations a
INNER JOIN tourism.reviews r ON a.accommodation_id = r.accommodation_id
GROUP BY a.accommodation_id, a.name
ORDER BY rating_promedio DESC;


--18. Top alojamientos más reservados (COUNT + LIMIT)
SELECT
  a.accommodation_id,
  a.name AS alojamiento,
  COUNT(b.booking_id) AS total_reservas
FROM tourism.accommodations a
INNER JOIN tourism.bookings b ON a.accommodation_id = b.accommodation_id
GROUP BY a.accommodation_id, a.name
ORDER BY total_reservas DESC
LIMIT 5;


--19. Alojamientos con más de 3 reservas
SELECT
  a.accommodation_id,
  a.name AS alojamiento,
  COUNT(b.booking_id) AS total_reservas,
  SUM(b.total_amount) AS ingresos_totales
FROM tourism.accommodations a
INNER JOIN tourism.bookings b ON a.accommodation_id = b.accommodation_id
GROUP BY a.accommodation_id, a.name
HAVING COUNT(b.booking_id) > 3
ORDER BY total_reservas DESC;

--20. Alojamiento más caro
SELECT
  accommodation_id,
  name AS alojamiento,
  base_price_per_night,
  currency_code
FROM tourism.accommodations
WHERE base_price_per_night = (
  SELECT MAX(base_price_per_night)
  FROM tourism.accommodations
  WHERE is_active = true
);










