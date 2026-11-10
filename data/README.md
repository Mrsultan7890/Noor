# GitHub-hosted content

The app reads public JSON from this repository's `main` branch. Edit the
relevant file on GitHub and commit it; the app fetches the latest content when
its screen opens, has a manual refresh button, and caches downloaded content
for offline use. Existing bundled content remains available as a fallback.

## Stories

Add or update stories in `data/stories.json`. The app merges remote stories by
`id` with its bundled stories, so a remote item with an existing ID updates
that item and a new ID adds another story. The current file is fetched from:

`https://raw.githubusercontent.com/Mrsultan7890/noor/main/data/stories.json`

Keep the top-level structure as an object containing `categories` and
`stories`. Each category has `id`, `name`, `nameUrdu`, `icon`, `color`, and
`description`. Each story uses this format:

```json
{
  "id": "s6",
  "title": "Story Title",
  "titleUrdu": "کہانی کا عنوان",
  "category": "seerat",
  "content": "English content...",
  "contentUrdu": "اردو مواد...",
  "lesson": "Lesson learned",
  "lessonUrdu": "سبق",
  "tags": ["tag1", "tag2"]
}
```

Use an existing category ID (`seerat`, `sahaba`, or `prophets`) unless adding
the corresponding category object too. Keep IDs unique and verify religious
and historical details before publishing edits.

## Duas

The app also reads dua additions from `data/duas.json`. The app fetches the
catalog when either Dua or Daily Adhkar opens. Built-in duas remain available
when GitHub cannot be reached.

Each item uses this shape:

```json
{
  "id": "dua-id-in-english",
  "title": "Title in English",
  "title_ur": "اردو عنوان",
  "arabic": "النص العربي الكامل",
  "transliteration": "Complete transliteration",
  "translation": "English meaning",
  "translation_ur": "اردو ترجمہ",
  "category": "Morning",
  "source": "Hadith/Quran source and reference",
  "repeat": "1 time"
}
```

Use a unique lowercase, hyphenated `id`. Supported categories are `Morning`,
`Evening`, `Meals`, `Home`, `Sleep`, `Travel`, and `Daily`. Verify the Arabic
text, translation, and exact source reference before committing. Keep the
top-level format as `{ "version": 1, "items": [...] }`.

Hadith content already comes from a hadith API, while prayer times, schedules,
accounts, and progress are user-specific or calculated; those should not be
moved to a public GitHub JSON file.

## Quran text

The app bundles the Tanzil Project Uthmani 1.1 Arabic Quran text in
`assets/data/quran-uthmani.json` for the Mushaf reader's offline pages. Surah
readers continue to load Arabic text, translations, and transliteration online.
The ayah text is included verbatim; do not edit it. Tanzil requires attribution
and a link to <https://tanzil.net/>. The text is licensed under CC BY 3.0; see
<https://tanzil.net/docs/Text_License>.
