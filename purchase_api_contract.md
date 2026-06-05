# Purchase API Contract

## Endpoint

```
POST /api/orders
```

---

## Request

### Headers

| Header         | Value              | Required |
|----------------|--------------------|----------|
| Content-Type   | application/json   | Yes      |

### Body

```json
{
  "items": [
    {
      "item_uuid": "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01",
      "quantity": 2
    },
    {
      "item_uuid": "d3c9e2f1-7a5b-4d3e-9c1f-2b4e8a7d6c34",
      "quantity": 1
    }
  ]
}
```

### Field Definitions

| Field              | Type    | Required | Description                              |
|--------------------|---------|----------|------------------------------------------|
| `items`            | array   | Yes      | One or more items to purchase. Min length: 1. |
| `items[].item_uuid`| string (UUID) | Yes | UUID of the food item.             |
| `items[].quantity` | integer | Yes      | Number of units. Must be ≥ 1.            |

---

## Response

### 201 Created — Success

```json
{
  "order_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "status": "confirmed",
  "items": [
    {
      "item_uuid": "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01",
      "name": "Bananas",
      "quantity": 2,
      "unit_price": 1.49,
      "subtotal": 2.98
    },
    {
      "item_uuid": "d3c9e2f1-7a5b-4d3e-9c1f-2b4e8a7d6c34",
      "name": "Cheddar Cheese",
      "quantity": 1,
      "unit_price": 5.49,
      "subtotal": 5.49
    }
  ],
  "subtotal": 8.47,
  "tax": 0.85,
  "total": 9.32,
  "created_at": "2026-06-04T14:32:00Z",
  "estimated_ready_at": "2026-06-04T14:47:00Z"
}
```

| Field                | Type    | Description                                           |
|----------------------|---------|-------------------------------------------------------|
| `order_id`           | string (UUID) | Unique identifier for the created order.        |
| `status`             | string  | Initial order status. See status values below.        |
| `items`              | array   | Echo of ordered items with resolved names and prices. |
| `items[].unit_price` | number  | Price at time of purchase (not the live catalogue price). |
| `items[].subtotal`   | number  | `unit_price × quantity`.                              |
| `subtotal`           | number  | Sum of all item subtotals before tax.                 |
| `tax`                | number  | Calculated tax amount.                                |
| `total`              | number  | `subtotal + tax`.                                     |
| `created_at`         | string (ISO 8601) | UTC timestamp when the order was placed.    |
| `estimated_ready_at` | string (ISO 8601) | UTC timestamp for estimated fulfilment. Omitted if not applicable. |

### Order Status Values

| Status       | Meaning                                  |
|--------------|------------------------------------------|
| `confirmed`  | Order accepted and queued.               |
| `processing` | Order is being prepared.                 |
| `completed`  | Order fulfilled.                         |
| `cancelled`  | Order was cancelled.                     |

---

## Error Responses

### 400 Bad Request — Malformed payload

```json
{
  "error": "bad_request",
  "message": "Request body is missing or not valid JSON."
}
```

### 422 Unprocessable Entity — Validation failure

```json
{
  "error": "validation_error",
  "message": "One or more fields are invalid.",
  "details": [
    {
      "field": "items[0].quantity",
      "issue": "Must be at least 1."
    },
    {
      "field": "items[1].item_uuid",
      "issue": "Item not found."
    }
  ]
}
```

### 409 Conflict — Item unavailable

```json
{
  "error": "item_unavailable",
  "message": "One or more items are currently out of stock.",
  "unavailable_item_uuids": [
    "a1f7b3e5-4c1d-42e9-8f2a-8cbb8b1f6f01"
  ]
}
```

### 500 Internal Server Error

```json
{
  "error": "internal_error",
  "message": "An unexpected error occurred. Please try again."
}
```

---

## Notes

- All monetary values are in **USD**, represented as decimal numbers rounded to 2 decimal places.
- `unit_price` in the response is the price locked at order time and may differ from the current catalogue price if prices change.
- The `estimated_ready_at` field is optional and may be omitted until the backend has fulfilment time estimation in place.
