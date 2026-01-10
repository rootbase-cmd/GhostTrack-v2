const EnergyClient = {
  base: "http://127.0.0.1:5001",
  async listWallets() {
    const r = await fetch(`${this.base}/wallets`);
    return r.json();
  },
  async getWallet(id) {
    const r = await fetch(`${this.base}/wallets/${id}`);
    return r.json();
  },
  async transact(id, amount, type, meta={}) {
    const r = await fetch(`${this.base}/wallets/${id}/transact`, {
      method: "POST",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify({ amount, type, meta })
    });
    return r.json();
  },
  renderWalletSummary(containerId) {
    this.listWallets().then(data => {
      const el = document.getElementById(containerId);
      if (!el) return;
      el.innerHTML = data.wallets.map(w => `
        <div class="wallet">
          <strong>${w.display_name}</strong> — <span class="impulsi">${w.impulsi} impulsi</span>
          <button data-id="${w.id}" class="donate-btn">Dona 5</button>
        </div>
      `).join("");
      el.querySelectorAll(".donate-btn").forEach(btn => {
        btn.addEventListener("click", async e => {
          const id = e.target.dataset.id;
          await this.transact(id, -5, "donate", { to: "pool-community" });
          this.renderWalletSummary(containerId);
        });
      });
    });
  }
};
