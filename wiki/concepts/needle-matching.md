---
title: "Needle Matching"
tags: [openqa, testing, image-matching, gui-testing]
sources:
  [openqa-getting-started.md, openqa-writing-tests.md, openqa-python-tests.md]
updated: 2026-06-23
---

# Needle Matching

How [openQA](../entities/openqa.md)/[os-autoinst](../entities/os-autoinst.md) knows the state of the system under test: **fuzzy image matching** between the VM screen and reference images called **needles**. A needle specifies both the elements to look for and a list of **tags** used to decide which needles apply at a given moment.

## Anatomy of a needle

A needle is a pair of files with the same basename:

- `foo.png` — a full-screen screenshot in PNG.
- `foo.json` — associated metadata: relevant `area`s and `tags`.

```json
{
  "area": [
    {
      "xpos": 0,
      "ypos": 0,
      "width": 0,
      "height": 0,
      "type": "match|ocr|exclude",
      "match": 95,
      "click_point": {}
    }
  ],
  "tags": ["sometag"]
}
```

## Area types

- **Regular** (`match`) — must match at least the given similarity percentage (`match`). Green box in the needle editor.
- **OCR** (`ocr`) — matched via an OCR algorithm rather than pixels; orange box. Rarely used.
- **Exclude** (`exclude`) — parts of the reference to ignore (e.g. a clock); red box in editor, gray in needle view.

## Click points

A regular match area may carry a **click point** (`xpos`, `ypos`, optional `id`), used by `assert_and_click` to match a GUI element (button, etc.) and click inside the matched area. If a needle has multiple click points, the `id` selects which one.

## Use in tests

Test modules reference needles by **tag** through the [test API](openqa-test-api.md):

- `assert_screen 'tag'` — fail unless a needle with that tag matches.
- `assert_and_click 'tag'` — match, then click its click point.

Needles live alongside tests in a `NEEDLES_DIR` (often a git repo); openQA ships a needle editor in the web UI for creating/adjusting them. For openSUSE, `fetchneedles` downloads tests and needles into place.

## Related Pages

- [Test API](openqa-test-api.md) · [openQA](../entities/openqa.md) · [os-autoinst](../entities/os-autoinst.md) · [Jobs](openqa-jobs.md)
- [Getting Started (source)](../sources/openqa-getting-started.md) · [Writing Tests (source)](../sources/openqa-writing-tests.md)
