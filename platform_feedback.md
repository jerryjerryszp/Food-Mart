# Platform Feedback

---

## 1. Remote Image View

`AsyncImage` was written twice with identical loading/failure/empty handling — once in `FoodItemRow` and again in `CartItemRow`. Any screen that shows product images will need the same thing.

**Proposal:** Ship a `RemoteImage(url:size:cornerRadius:)` component that encapsulates the three phases internally. Callers just pass a URL and a frame size.

---

## 2. Generic Network Fetcher

Every endpoint follows the same pattern: `URLSession.data(from:)` → `JSONDecoder.decode`. Right now that logic lives directly inside `NetworkService` and would be copy-pasted for each new endpoint.

**Proposal:** Extract a single `fetch<T: Decodable>(_ url: URL) async throws -> T` helper (free function or thin wrapper type). All service methods become one-liners and error handling is consistent across the app.

---

## 3. Stepper Button Style

The `−  n  +` stepper with 16×16 accent/gray circles appeared in both `FoodItemRow` and `CartItemRow`. Any quantity-selection UI will want the same control.

**Proposal:** Extract a `QuantityStepper(quantity:onIncrement:onDecrement:)` view. Centralizing it means visual tweaks (size, color, animation) propagate everywhere automatically.
