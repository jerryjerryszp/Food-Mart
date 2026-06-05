# Issue Breakdown

## Issue 1 — MVVM Architecture

**Summary**
Replace the template project with a clean MVVM structure

**Acceptance Criteria**
- Source files are organized into `Models/`, `Network/`, `ViewModels/`, and `Views/` subdirectories
- App entry point (`Food_MartApp`) compiles and launches without errors
- `ContentView` is a thin root wrapper with no business logic

---

## Issue 2 — Data Models

**Summary**
Define `Codable` value types for the two API resources

**Acceptance Criteria**
- `FoodItem` decodes `uuid`, `name`, `price`, `category_uuid`, and `image_url` from the API's snake_case JSON via `CodingKeys`
- `FoodCategory` decodes `uuid` and `name`
- Both conform to `Identifiable` using their `uuid` field as `id`
- Neither model imports or depends on any UI framework

---

## Issue 3 — Network Layer

**Summary**
Create a protocol-backed network service that fetches food items and categories concurrently from the remote API.

**Acceptance Criteria**
- `FoodNetworkServiceProtocol` declares `fetchFoodItems()` and `fetchCategories()` as `async throws` methods
- `NetworkService` is the concrete implementation using `URLSession`
- Both endpoints are fetched concurrently via `async let` in `FoodListViewModel.loadData()`
- A network error surfaces as a non-nil `errorMessage` on the view model; `isLoading` resets to `false` in both success and failure paths

---

## Issue 4 — Food List View

**Summary**
Build a list that shows every food item with its image, name, category, and price.

**Acceptance Criteria**
- A full-screen `ProgressView` is shown while the initial load is in flight
- A `ContentUnavailableView` is shown when the load fails
- Each row displays a 64×64 rounded thumbnail via `AsyncImage`, the item name, its category name, and a formatted USD price
- `AsyncImage` shows a placeholder while loading and a system icon on failure
- The list uses `.plain` style with no separators between items

---

## Issue 5 — Sort & Category Filter

**Summary**
Add two toolbar controls — a sort menu and a category dropdown — that narrow and reorder the visible list without leaving the screen.

**Acceptance Criteria**
- A sort button in the top-right toolbar opens a menu with three options: Default, Price: Low to High, Price: High to Low
- The sort button icon changes to `↑` (ascending), `↓` (descending), or `↑↓` (default) to reflect the active state
- A second toolbar button opens a category menu where each of the API-sourced categories can be independently toggled
- Selected categories show a checkmark; the button icon switches to the filled variant when any category is active
- Both filters are applied together: category filtering runs first, then price sorting
- When the combined filter produces no results, a `ContentUnavailableView` is shown in place of the list
- Removing all active filters restores the full item list

---

## Issue 6 — Cart

**Summary**
Allow users to add items to a cart, adjust quantities inline on the list, and review the full cart in a bottom sheet.

**Acceptance Criteria**
- Each food item row shows an **Add** button (plain text, accent color, no background) when the item is not in the cart
- Once added, the Add button is replaced by a `−  n  +` stepper; the `−` button is a gray 16×16 circle and `+` is an accent-colored 16×16 circle
- Decrementing to zero removes the item from the cart and restores the Add button
- A floating circular cart button is pinned to the bottom-right of the list; it shows a red badge with the total item count when the cart is non-empty
- Tapping the cart button opens a bottom sheet at `.medium` or `.large` detent with an opaque (non-translucent) background at both sizes
- The cart sheet lists all cart items sorted alphabetically, each showing a thumbnail, name, unit price, and the same `−  n  +` stepper
- A pinned footer in the cart sheet shows the running total in USD
- The cart sheet shows a `ContentUnavailableView` when empty

---

## Issue 7 — Purchase Button

**Summary**
Add a Purchase CTA to the cart sheet as a placeholder while the backend endpoint is under development.

**Acceptance Criteria**
- A full-width `borderedProminent` Purchase button appears in the cart footer below the total
- Tapping the button has no effect
- The button is only visible when the cart has at least one item

---

## Issue 8 — Unit Tests

**Summary**
Cover all view model logic with fast, deterministic unit tests using Swift Testing and a mock network service.

**Acceptance Criteria**
- A `MockNetworkService` conforming to `FoodNetworkServiceProtocol` supports configuring items, categories, and an optional error to throw
- **Cart suite**: increment, accumulate, decrement, decrement-to-zero removes item, no-op below zero, default quantity is zero, total count, total price calculation, cart items sorted by name, per-item quantities
- **Filter & Sort suite**: no filter returns all items, single-category filter, multi-category filter, unmatched filter returns empty, ascending sort, descending sort, none preserves original order, filter and sort applied together
- **Toggle Category suite**: selects, deselects, multiple categories are independent
- **loadData suite**: success populates items and categories with no error, failure sets `errorMessage` and leaves `foodItems` empty, `isLoading` is `false` after both paths
- **categoryName suite**: returns the correct name for a known category UUID, returns `""` for an unknown UUID
- No test hits the real network
