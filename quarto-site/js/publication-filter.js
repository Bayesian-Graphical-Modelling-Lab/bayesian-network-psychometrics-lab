// Filters the publication list as you type; empty year groups are hidden.
(function () {
  const input = document.getElementById("pub-search");
  const count = document.getElementById("pub-count");
  if (!input) return;
  const pubs = Array.from(document.querySelectorAll(".pub"));
  const groups = Array.from(document.querySelectorAll(".pub-list"));
  const total = pubs.length;
  // Search title, authors (including the hidden full list) and venue, not the BibTeX box.
  const fields = (p) => [".pub-title", ".pub-authors", ".pub-venue"].map((sel) => p.querySelector(sel)?.textContent ?? "").join(" ");
  const text = new Map(pubs.map((p) => [p, fields(p).toLowerCase()]));

  function update() {
    const terms = input.value.toLowerCase().split(/\s+/).filter(Boolean);
    let shown = 0;
    for (const pub of pubs) {
      const match = terms.every((t) => text.get(pub).includes(t));
      pub.hidden = !match;
      if (match) shown++;
    }
    for (const list of groups) {
      const section = list.closest("section");
      const visible = list.querySelector(".pub:not([hidden])") !== null;
      (section || list).hidden = !visible;
    }
    count.textContent = terms.length ? `${shown} of ${total} publications` : `${total} publications`;
  }

  input.addEventListener("input", update);
  update();
})();
