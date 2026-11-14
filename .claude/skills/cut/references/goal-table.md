# Goal table

Used by `/cut` to guess `project.goal` from the brief's In your words when it is unset.
Show the result as *guessed*. (Moved here from the removed `/start` skill.)

| The user's words mention | Goal |
|---|---|
| a game jam, or a theme with a deadline | `jam` |
| learning, a first game, practice, a course or class | `learn` |
| a portfolio, a job, showing their work | `portfolio` |
| selling it, Steam, a price, commercial, wishlists | `sell` |
| early access | `early_access` |
| a publisher, a pitch, funding | `publisher` |
| mobile, a phone, iOS, Android, an app store | `mobile` |
| a purpose none of the rows above fits | `other` |
| fun, themselves or friends, or nothing above | `hobby` (the default) |

When two fit, a selling goal wins over the others, and `early_access` or `publisher` over `sell`.
