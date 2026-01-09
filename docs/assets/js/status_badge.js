const StatusBadge = {
  statusPath: "/status",
  async fetchStatus() {
    try {
      const r = await fetch(this.statusPath + "?_=" + Date.now());
      if (!r.ok) return null;
      return r.json();
    } catch (e) { return null; }
  },
  async render(containerId) {
    const el = document.getElementById(containerId);
    if (!el) return;
    const s = await this.fetchStatus();
    if (!s) {
      el.innerHTML = '<span class="badge badge-error">offline</span>';
      return;
    }
    const ok = s.ok ? 'online' : 'degraded';
    el.innerHTML = `<span class="badge badge-${ok}">API ${ok}</span>
      <small>proposals: ${s.proposals_ts || "n/a"}</small>`;
  }
};
