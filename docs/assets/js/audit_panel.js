const AuditPanel = {
  proposalsPath: "/data/donation_proposals.json",
  auditLogPath: "/data/audit_log.json",
  async loadProposals() {
    try {
      const r = await fetch(this.proposalsPath + "?_=" + Date.now());
      if (!r.ok) return null;
      return r.json();
    } catch (e) { return null; }
  },
  async loadAudit() {
    try {
      const r = await fetch(this.auditLogPath + "?_=" + Date.now());
      if (!r.ok) return {entries:[]};
      return r.json();
    } catch (e) { return {entries:[]}; }
  },
  async render(containerId) {
    const el = document.getElementById(containerId);
    if (!el) return;
    const proposals = await this.loadProposals();
    const audit = await this.loadAudit();
    let html = '<h3>Proposte</h3>';
    if (!proposals || !proposals.proposals || proposals.proposals.length===0) {
      html += "<p>Nessuna proposta.</p>";
    } else {
      html += proposals.proposals.map(p=>`<div><strong>${p.from}</strong> — ${p.suggested_impulsi} impulsi <button data-from="${p.from}" data-amount="${p.suggested_impulsi}" class="approve-btn">Approva</button></div>`).join("");
    }
    html += "<h3>Audit</h3>";
    html += (audit.entries && audit.entries.length>0) ? audit.entries.map(e=>`<div>${e.ts} — ${e.actor} — ${e.action} — ${e.amount}</div>`).join("") : "<p>Vuoto</p>";
    el.innerHTML = html;
    el.querySelectorAll(".approve-btn").forEach(btn=>{
      btn.addEventListener("click", async e=>{
        const from = e.target.dataset.from;
        const amount = parseInt(e.target.dataset.amount,10);
        await fetch(`/wallets/${from}/transact`, {
          method:"POST",
          headers:{"Content-Type":"application/json"},
          body: JSON.stringify({amount:-amount,type:"donate",meta:{to:"pool-community"}})
        });
        await fetch(`/wallets/pool-community/transact`, {
          method:"POST",
          headers:{"Content-Type":"application/json"},
          body: JSON.stringify({amount:amount,type:"receive",meta:{from}})
        });
        // append audit locally by POST to a simple file-updater endpoint (not available here),
        // fallback: trigger re-render and rely on server-side audit if implemented.
        this.render(containerId);
      });
    });
  }
};
