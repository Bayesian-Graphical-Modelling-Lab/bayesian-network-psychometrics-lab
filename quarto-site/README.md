# BGM Lab website (Quarto)

Styled after the [bgms documentation site](https://bayesian-graphical-modelling-lab.github.io/bgms/).

## Preview and build

```sh
quarto preview      # live preview at http://localhost:4321
quarto render       # builds the site into _site/
```

## Where the content lives

| What | File |
|------|------|
| Homepage (intro, news, latest publications, funding) | `index.qmd` |
| News items (homepage shows the first five; `news.qmd` shows all) | `data/news.yml` |
| Publications (Publications page, homepage, tutorial list on Workshops) | `publications.bib` |
| Team members and their pop-ups | `data/team.yml`, photos in `images/team/` |
| Grants at the bottom of the homepage | `data/funding.yml` |
| Software, Workshops, Projects | `software.qmd`, `workshops.qmd`, `projects.qmd` |

### Adding a news item
Add an entry at the **top** of `data/news.yml`. The comment at the top of that file says what belongs in the feed.

### Adding a publication
Paste the BibTeX entry into `publications.bib`, with the title in sentence case. The fields follow
the same conventions as nikolasekulovski.com: `pubstate = {submitted|accepted|inpress}` lists it
under "Forthcoming", `preprint`, `code`, `data`, `osf`, `tutorial`, `slides` add link buttons, and
`keywords = {tutorial}` also lists it on the Workshops page. Lab members from `data/team.yml` are
shown in bold. The header of the `.bib` file has the details.

### Adding a team member
Add an entry to `data/team.yml` (order in the file = order on the page) and a photo to `images/team/`.
Set `group: affiliated` to move someone to "Affiliated researchers & past members".

## How it works
- `filters/publications.lua` is a shortcode (`{{< publications >}}`) that reads `publications.bib`
  and builds the publication list (same layout as nikolasekulovski.com, with a copyable BibTeX box).
- News, team, and funding are Quarto listings rendered with the templates in `templates/`.
- Colours and fonts are in `theme-light.scss`, `theme-dark.scss`, and `styles.css`.
