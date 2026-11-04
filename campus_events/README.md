# Campus Events

Lab 1 for Mobile Development. Domain: **campus events** - each event has a
title, a category, a start time, a place (or a link when it is online), a
capacity and a list of people who registered. "Register" adds your name.
All data lives in memory.

## Screenshots

| Phone, light | Phone, dark | Tablet grid |
| --- | --- | --- |
| _add `docs/phone_light.png`_ | _add `docs/phone_dark.png`_ | _add `docs/tablet_grid.png`_ |

## Decisions

The list of events and the profile live in the shell's State, because three
tabs and two pushed screens all read or change them, and the shell is the
lowest widget that is above all of them. The detail screen takes the item and
callbacks through its route arguments because it only shows and edits one
event and must not know where the list is stored, while the form receives an
`Item?` and returns an `Item` through `pop`, so the caller decides what to do
with the result and backing out changes nothing. The list is a `LayoutBuilder`
rather than `MediaQuery` because the grid has to react to the width the list
is given, not the width of the screen. The `PopScope` compares a record of the
current field values with the record taken when the form opened, so undoing an
edit makes the form clean again. With week 9's tools I would move the items
and profile out of the shell into a shared state object, so that tabs and
pushed screens read them directly instead of through constructor parameters
and callbacks.
