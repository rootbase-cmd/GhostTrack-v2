const ApprovalPanel = {
  base: "http://127.0.0.1:5001",
  proposalsPath: "/data/donation_proposals.json",
  async loadProposals() {
    try {
      const r = await fetch(this.proposalsPath + "?_=" + Date.now());
      if (!r.ok) return null;
      return r.json();
    } catch (e) { return null; }
  },
  async render(containerId) {
    const el = document.getElementById(containerId);
    if (!el) return;
    const data = await this.loadProposals();
    if (!data || !data.proposals || data.proposals.length === 0) {
      el.innerHTML = "<p>Nessuna proposta di donazione al momento.</p>";
      return;
    }
    el.innerHTML = data.proposals.map(p => `
      <div class="proposal">
        <strong>${p.from}</strong> — impulsi: ${p.available_impulsi} — suggeriti: ${p.suggested_impulsi}
        <button data-from="${p.from}" data-amount="${p.suggested_impulsi}" class="approve-btn">Approva</button>
      </div>
    `).join("");
    el.querySelectorAll(".approve-btn").forEach(btn => {
      btn.addEventListener("click", async e => {
        const from = e.target.dataset.from;
        const amount = parseInt(e.target.dataset.amount,10);
        await fetch(`${this.base}/wallets/${from}/transact`, {
          method: "POST",
          headers: {"Content-Type":"application/json"},
          body: JSON.stringify({ amount: -amount, type: "donate", meta: { to: "pool-community" } })
        });
        await fetch(`${this.base}/wallets/pool-community/transact`, {
          method: "POST",
          headers: {"Content-Type":"application/json"},
          body: JSON.stringify({ amount: amount, type: "receive", meta: { from } })
        });
        this.render(containerId);
      });
    });
  }
};
