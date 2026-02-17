# Parsing Kaiten API Documentation

## Problem
The Kaiten documentation (https://developers.kaiten.ru) is a JavaScript SPA. `web_fetch` does not work (returns an empty page). A real browser is needed.

## How to Parse

### 1. Use Playwright (Python)
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True, args=['--no-sandbox'])
    page = browser.new_page()
    page.goto(url, wait_until='networkidle', timeout=30000)
    page.wait_for_timeout(3000)  # SPA needs time to render
    content = page.text_content('body')
    browser.close()
```

### 2. URL Structure
```
https://developers.kaiten.ru/{section}/{action}
```
Examples:
- `https://developers.kaiten.ru/columns/get-list-of-columns`
- `https://developers.kaiten.ru/lanes/get-list-of-lanes`
- `https://developers.kaiten.ru/space-boards/get-list-of-boards`
- `https://developers.kaiten.ru/custom-properties/get-list-of-properties`
- `https://developers.kaiten.ru/cards/retrieve-card-list`
- `https://developers.kaiten.ru/cards/retrieve-card`
- `https://developers.kaiten.ru/spaces/retrieve-list-of-spaces`

### 3. Page Content Structure (text_content)
The page returns **continuous text** without delimiters. Structure:
```
[Navigation (sidebar)]...[Endpoint name]GET|POST|...[URL template]
Path parameters → Name | Type | Reference | Description
Query → Name | Type | Constraints | Description
Responses → 200 | 401 | 403 | 404
Response Attributes → Name | Type | Description
[Examples curl/node/php]
[Footer]
```

### 4. How to Find the Needed Section
```python
# Find the start of endpoint description
idx = content.find('Path parameters')
# or
idx = content.find('Query')  # for query params
# or
idx = content.find('Response Attributes')  # for response fields

# Extract a chunk around it
section = content[max(0, idx-100) : idx+2000]
```

### 5. How to Determine Pagination Support
Look in the Query parameters section:
- `offset` + `limit` — classic Kaiten pagination
- If absent — the endpoint returns everything in a single request

### 6. How to Determine Field Requiredness
In Response Attributes, the field type indicates nullability:
- `string`, `integer`, `boolean` — **required** (non-null)
- `null | string`, `null | integer`, `null | array`, `null | object` — **optional** (nullable)
- `enum` — required, values are described in Description (e.g. `1-queued, 2-inProgress, 3-done`)

Examples from GET /cards:
- `id` → `integer` → required
- `title` → `string` → required
- `description` → `null | string` → optional
- `due_date` → `null | string` → optional
- `archived` → `boolean` → required
- `properties` → `null | object` → optional
- `parents_ids` → `null | array` → optional

In Path parameters, a field is marked `required` explicitly (e.g. `board_id required integer`).
In Query parameters, `required` is indicated as a constraint; if not indicated — the parameter is optional.

### 7. Expanding Nested Schemas (Schema Buttons)

Fields with type `object Schema` or `array Schema` have a **Schema** button (MUI Button) that opens a **modal dialog** (MUI Dialog) with nested field descriptions. `text_content('body')` does **NOT** show the contents of these schemas — you need to click the button and read the dialog.

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True, args=['--no-sandbox'])
    page = browser.new_page()
    page.goto(url, wait_until='networkidle', timeout=30000)
    page.wait_for_timeout(3000)

    # Find all Schema buttons
    buttons = page.query_selector_all('button.MuiButton-root')
    schema_buttons = [b for b in buttons if b.text_content().strip() == 'Schema']

    for btn in schema_buttons:
        # Field name from the table row
        field_info = btn.evaluate(
            'el => el.closest("tr")?.textContent || "unknown"'
        )

        btn.click(timeout=3000)
        page.wait_for_timeout(1000)

        # Read the dialog contents
        dialog = page.query_selector('.MuiDialog-root')
        if dialog:
            schema_text = dialog.text_content()
            print(f"{field_info}: {schema_text}")

            # Close the dialog before the next click
            page.keyboard.press('Escape')
            page.wait_for_timeout(500)

    browser.close()
```

**Important:**
- The dialog blocks clicks on other elements — **must close** via `Escape` before moving to the next button
- Nested schemas may contain their own Schema buttons (recursive types, e.g. `children` → Card)
- Text format in the dialog: `FieldNameType: typeNameTypeDescriptionfield1type1desc1field2type2desc2...`

#### Nested Schemas Inside the Dialog (MuiLink)

Inside an opened dialog, fields with type `array` or `object` may be **clickable links** (not Schema buttons, but the type text itself). These are `button` elements with class `MuiLink-root` — clicking them replaces the dialog content with the nested schema.

Example: `checklists` → Schema → inside, field `items` with type `array` → click `array` → the ChecklistItem schema is revealed.

```python
# After opening the main Schema dialog:
dialog = page.query_selector('.MuiDialog-root')
if dialog:
    # Find clickable types inside the dialog
    link_buttons = dialog.query_selector_all('button.MuiLink-root')
    for lb in link_buttons:
        text = lb.text_content().strip()
        # text will be "array", "object", etc.
        lb.click(timeout=3000)
        page.wait_for_timeout(1000)

        # Dialog updated — read new content
        dialog = page.query_selector('.MuiDialog-root')
        nested_text = dialog.text_content()
        print(nested_text)

        # The dialog has a "Back" button to return to the parent schema
        page.keyboard.press('Escape')
        page.wait_for_timeout(500)
```

**How to distinguish:**
- **Schema** buttons on the page (outside the dialog): `button.MuiButton-root` with text `Schema`
- Links to nested schemas **inside the dialog**: `button.MuiLink-root` with type text (`array`, `object`)

### 8. Batch Parsing Multiple Endpoints
```python
urls = {
    'columns': 'https://developers.kaiten.ru/columns/get-list-of-columns',
    'lanes': 'https://developers.kaiten.ru/lanes/get-list-of-lanes',
    # ...
}

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True, args=['--no-sandbox'])
    page = browser.new_page()
    for name, url in urls.items():
        page.goto(url, wait_until='networkidle', timeout=30000)
        content = page.text_content('body')
        # parse the needed sections
    browser.close()
```

### 9. Important Notes
- **One browser, many page.goto()** — don't create a new browser for each URL
- **wait_for_timeout(3000)** — sometimes needed after networkidle for full rendering
- **text_content('body')** — returns all text without HTML tags
- Chromium is installed via `playwright install chromium`
- Must run with `args=['--no-sandbox']` (we're running as root)
- Playwright is installed: `pip install --break-system-packages playwright && playwright install chromium`
