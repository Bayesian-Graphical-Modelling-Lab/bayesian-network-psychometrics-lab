-- Renders publications.bib as a publication list in the style of nikolasekulovski.com:
-- title, authors (lab members in bold), venue with a status chip, link chips, and a
-- copyable BibTeX box.
--
--   {{< publications >}}                    every entry: forthcoming first, then by year
--   {{< publications limit=6 >}}            the newest published or in-press entries, ungrouped
--   {{< publications keyword=tutorial >}}   entries whose `keywords` field contains the keyword
--
-- See the comment at the top of publications.bib for the fields used here.

local LONG = 12 -- author lists longer than this are shortened, with a button for the rest

-- Extra fields that become link chips, in this order (after "Paper").
local LINK_FIELDS = {
  { "preprint", "Preprint" }, { "pdf", "PDF" }, { "code", "Code" }, { "data", "Data" },
  { "osf", "OSF" }, { "tutorial", "Tutorial" }, { "blog", "Blog post" }, { "slides", "Slides" },
}
-- Fields that are only for the website and are left out of the copyable BibTeX.
local SITE_ONLY = { note = true, keywords = true }
for _, f in ipairs(LINK_FIELDS) do SITE_ONLY[f[1]] = true end

local STATUS = {
  submitted = "Submitted", accepted = "Accepted", forthcoming = "Accepted",
  inpress = "In press", prepublished = "Preprint",
}
local STATUS_ORDER = { Submitted = 1, Preprint = 2, Accepted = 3, ["In press"] = 4 }

local function project_path(p)
  return pandoc.path.join({ quarto.project.directory or ".", p })
end

local function read_file(p)
  local f = assert(io.open(p, "r"), "cannot open " .. p)
  local s = f:read("a")
  f:close()
  return s
end

local function str(x)
  return x and pandoc.utils.stringify(x) or ""
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function first_char(s)
  return s:match("^[%z\1-\127\194-\244][\128-\191]*") or ""
end

-- "Eric-Jan" -> "E.-J.", "Jonas M. B." -> "J. M. B."
local function initials(given)
  local parts = {}
  for word in given:gmatch("%S+") do
    local pieces = {}
    for piece in word:gmatch("[^%-]+") do
      table.insert(pieces, first_char(piece) .. ".")
    end
    table.insert(parts, table.concat(pieces, "-"))
  end
  return table.concat(parts, " ")
end

local function surname(person)
  local particle = str(person["non-dropping-particle"] or person["dropping-particle"])
  local family = str(person.family)
  return particle ~= "" and (particle .. " " .. family) or family
end

-- Lab members from data/team.yml, keyed as "surname|first initial".
local function lab_members()
  local members = {}
  for name in read_file(project_path("data/team.yml")):gmatch("\n%-%s*name:%s*([^\n]-)%s*\n") do
    local given, rest = name:match("^(%S+)%s+(.+)$")
    if given then members[rest:lower() .. "|" .. first_char(given):lower()] = true end
  end
  return members
end

-- Raw text and extra fields of each entry, which pandoc's BibTeX reader does not keep.
local function raw_entries(raw)
  local out = {}
  for entry, key in raw:gmatch("(@%w+%s*{%s*([^,%s]+)%s*,.-\n})") do
    local fields, kept = {}, {}
    for line in entry:gmatch("[^\n]+") do
      local name, value = line:match("^%s*(%w+)%s*=%s*[{\"](.-)[}\"]%s*,?%s*$")
      if name then fields[name:lower()] = value end
      if not (name and SITE_ONLY[name:lower()]) then table.insert(kept, line) end
    end
    -- the last kept field must not end with a comma
    kept[#kept - 1] = kept[#kept - 1]:gsub(",%s*$", "")
    out[key] = { fields = fields, bibtex = table.concat(kept, "\n") }
  end
  return out
end

local function has_keyword(ref, kw)
  for k in str(ref.keyword):gmatch("[^,;]+") do
    if k:match("^%s*(.-)%s*$"):lower() == kw then return true end
  end
  return false
end

local function as_url(v)
  v = v:match("^%s*(.-)%s*$")
  if v:match("^10%.%d%d%d%d+/") then return "https://doi.org/" .. v end
  return v
end

local function prepare(ref, raw, members)
  local extra = raw[ref.id] or { fields = {}, bibtex = "" }
  local f = extra.fields

  local pubstate = (f.pubstate or ""):lower():gsub("[%s%-]", "")
  local doi = str(ref.doi or ref.DOI):gsub("^https?://dx%.doi%.org/", ""):gsub("^https?://doi%.org/", "")
  local url = str(ref.url or ref.URL)
  local paper = doi ~= "" and ("https://doi.org/" .. doi) or (url ~= "" and url or nil)

  local links = {}
  if paper then table.insert(links, { "Paper", paper }) end
  for _, lf in ipairs(LINK_FIELDS) do
    if f[lf[1]] and f[lf[1]] ~= "" then table.insert(links, { lf[2], as_url(f[lf[1]]) }) end
  end

  local authors = {}
  for _, person in ipairs(ref.author or {}) do
    local last, given = surname(person), str(person.given)
    table.insert(authors, {
      name = given ~= "" and (last .. ", " .. initials(given)) or last,
      lab = members[last:lower() .. "|" .. first_char(given):lower()] or false,
    })
  end

  local issued = str(ref.issued)
  return {
    id = ref.id,
    title = str(ref.title),
    authors = authors,
    year = issued:match("^(%d%d%d%d)") or "",
    month = tonumber(issued:match("^%d%d%d%d%-(%d%d)")) or 0,
    venue = str(ref["container-title"]) ~= "" and str(ref["container-title"]) or str(ref.publisher),
    volume = str(ref.volume),
    issue = str(ref.issue),
    pages = str(ref.page),
    status = STATUS[pubstate] or (pubstate ~= "" and f.pubstate or nil),
    note = f.note,
    href = links[1] and links[1][2],
    links = links,
    bibtex = extra.bibtex,
  }
end

-- APA-style "A, B, & C", with "…" wherever authors are skipped.
local function author_html(authors, indices)
  local out = {}
  for k, i in ipairs(indices) do
    local sep = ""
    if k > 1 then
      sep = ", "
      if i - indices[k - 1] > 1 then sep = sep .. "…, " end
      if k == #indices then sep = sep .. "&amp; " end
    end
    local a = authors[i]
    table.insert(out, sep .. (a.lab and ("<strong>" .. esc(a.name) .. "</strong>") or esc(a.name)))
  end
  return table.concat(out)
end

local function pub_html(p, show_year)
  local n = #p.authors
  local all = {}
  for i = 1, n do all[i] = i end
  local short = all
  if n > LONG then
    local keep = { [1] = true, [2] = true, [3] = true, [n] = true }
    for i, a in ipairs(p.authors) do if a.lab then keep[i] = true end end
    short = {}
    for i = 1, n do if keep[i] then table.insert(short, i) end end
  end

  local h = {}
  local title = esc(p.title)
  if p.href then title = '<a href="' .. esc(p.href) .. '">' .. title .. "</a>" end
  table.insert(h, '<li class="pub">')
  table.insert(h, '<p class="pub-title">' .. title .. "</p>")

  local authors = '<span class="short">' .. author_html(p.authors, short) .. "</span>"
  if n > LONG then
    authors = authors .. '<span class="full" hidden>' .. author_html(p.authors, all) .. "</span>"
      .. '<button class="more" type="button" aria-expanded="false" data-n="' .. n .. '">all ' .. n .. " authors</button>"
  end
  table.insert(h, '<p class="pub-authors">' .. authors .. "</p>")

  local venue = {}
  if p.venue ~= "" then table.insert(venue, "<em>" .. esc(p.venue) .. "</em>") end
  if p.volume ~= "" then table.insert(venue, ", <em>" .. esc(p.volume) .. "</em>") end
  if p.issue ~= "" then table.insert(venue, "(" .. esc(p.issue) .. ")") end
  if p.pages ~= "" then table.insert(venue, ", " .. esc(p.pages)) end
  if show_year and p.year ~= "" and not p.status then table.insert(venue, " · " .. p.year) end
  if p.status then table.insert(venue, ' <span class="status">' .. esc(p.status) .. "</span>") end
  if #venue > 0 then table.insert(h, '<p class="pub-venue">' .. table.concat(venue) .. "</p>") end

  if p.note then table.insert(h, '<p class="pub-note">' .. esc(p.note) .. "</p>") end

  local chips = {}
  for _, l in ipairs(p.links) do
    local arrow = l[2]:match("^https?:") and ' <span class="arrow">↗</span>' or ""
    table.insert(chips, '<a class="chip" href="' .. esc(l[2]) .. '">' .. esc(l[1]) .. arrow .. "</a>")
  end
  table.insert(chips, '<button class="chip cite" type="button" aria-expanded="false">BibTeX</button>')
  table.insert(h, '<div class="pub-links">' .. table.concat(chips) .. "</div>")
  table.insert(h, '<div class="bib" hidden><pre>' .. esc(p.bibtex) .. '</pre><button class="copy" type="button">Copy</button></div>')
  table.insert(h, "</li>")
  return table.concat(h, "\n")
end

local function list_block(pubs, show_year)
  local items = {}
  for _, p in ipairs(pubs) do table.insert(items, pub_html(p, show_year)) end
  return pandoc.RawBlock("html", '<ol class="pub-list">\n' .. table.concat(items, "\n") .. "\n</ol>")
end

local SCRIPT = [[
<script>
// BibTeX toggle, copy button, and "all N authors" for the publication lists.
document.addEventListener("click", async (ev) => {
  const btn = ev.target.closest("button");
  const pub = btn && btn.closest(".pub");
  if (!pub) return;
  if (btn.classList.contains("cite")) {
    const open = btn.getAttribute("aria-expanded") !== "true";
    btn.setAttribute("aria-expanded", String(open));
    pub.querySelector(".bib").hidden = !open;
  } else if (btn.classList.contains("copy")) {
    try {
      await navigator.clipboard.writeText(pub.querySelector("pre").textContent);
      btn.textContent = "Copied";
    } catch {
      btn.textContent = "Select and copy";
    }
    setTimeout(() => (btn.textContent = "Copy"), 1600);
  } else if (btn.classList.contains("more")) {
    const open = btn.getAttribute("aria-expanded") !== "true";
    btn.setAttribute("aria-expanded", String(open));
    pub.querySelector(".short").hidden = open;
    pub.querySelector(".full").hidden = !open;
    btn.textContent = open ? "fewer authors" : `all ${btn.dataset.n} authors`;
  }
});
</script>
]]
local script_added = false

return {
  ["publications"] = function(args, kwargs)
    if not script_added then
      quarto.doc.include_text("after-body", SCRIPT)
      script_added = true
    end

    local file = str(kwargs["file"])
    if file == "" then file = "publications.bib" end
    local raw = read_file(project_path(file))
    local refs = pandoc.read(raw, "biblatex").meta.references or {}
    local extra = raw_entries(raw)
    local members = lab_members()

    local keyword = str(kwargs["keyword"]):lower()
    local limit = tonumber(str(kwargs["limit"]))

    local pubs = {}
    for i, ref in ipairs(refs) do
      if keyword == "" or has_keyword(ref, keyword) then
        local p = prepare(ref, extra, members)
        p.order = i
        if not (limit and (p.status == "Submitted" or p.status == "Preprint")) then
          table.insert(pubs, p)
        end
      end
    end

    -- Ungrouped lists, newest first (in press counts as newest)
    if limit or keyword ~= "" then
      local function recency(p)
        if p.status then return math.huge end
        return (tonumber(p.year) or 0) * 100 + p.month
      end
      table.sort(pubs, function(a, b)
        local ra, rb = recency(a), recency(b)
        if ra ~= rb then return ra > rb end
        return a.order < b.order
      end)
      local shown = pubs
      if limit then
        shown = {}
        for i = 1, math.min(limit, #pubs) do shown[i] = pubs[i] end
      end
      return list_block(shown, true)
    end

    -- Full list: forthcoming (by status), then by year; file order within a group
    local forthcoming, years, by_year = {}, {}, {}
    for _, p in ipairs(pubs) do
      if p.status then
        table.insert(forthcoming, p)
      else
        local y = p.year ~= "" and p.year or "Other"
        if not by_year[y] then
          by_year[y] = {}
          table.insert(years, y)
        end
        table.insert(by_year[y], p)
      end
    end
    table.sort(forthcoming, function(a, b)
      local sa, sb = STATUS_ORDER[a.status] or 9, STATUS_ORDER[b.status] or 9
      if sa ~= sb then return sa < sb end
      return a.order < b.order
    end)
    table.sort(years, function(a, b) return (tonumber(a) or 0) > (tonumber(b) or 0) end)

    local blocks = pandoc.Blocks({})
    if #forthcoming > 0 then
      blocks:insert(pandoc.Header(2, "Forthcoming", { id = "forthcoming", class = "group-label" }))
      blocks:insert(list_block(forthcoming, false))
    end
    for _, y in ipairs(years) do
      blocks:insert(pandoc.Header(2, y, { id = "year-" .. y, class = "group-label" }))
      blocks:insert(list_block(by_year[y], false))
    end
    return blocks
  end,
}
