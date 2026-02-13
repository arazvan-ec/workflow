/* Git timeline page */
const GitTimelinePage = {
    async render(container) {
        container.innerHTML = '<div class="loading">Loading git history...</div>';

        try {
            const [commits, branches] = await Promise.all([
                fetch('/api/git/commits?limit=50').then(r => r.json()),
                fetch('/api/git/branches').then(r => r.json()),
            ]);
            container.innerHTML = this._build(commits, branches);
        } catch (e) {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">!</div>Error loading git data</div>';
        }
    },

    _build(commits, branches) {
        return `
            <div class="page-header">
                <h2>Git Timeline</h2>
                <p>${commits.length} recent commits across ${branches.length} branches</p>
            </div>

            <div class="metrics-grid" style="margin-bottom: 24px;">
                <div class="metric-card">
                    <div class="metric-label">Commits</div>
                    <div class="metric-value blue">${commits.length}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Branches</div>
                    <div class="metric-value green">${branches.length}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Files Changed</div>
                    <div class="metric-value yellow">${commits.reduce((s, c) => s + (c.files_changed || 0), 0)}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Net Lines</div>
                    <div class="metric-value purple">${this._formatNet(commits)}</div>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <div class="timeline">
                        ${commits.map(c => this._commitItem(c)).join('')}
                    </div>
                </div>
            </div>
        `;
    },

    _commitItem(c) {
        const type = this._commitType(c.message);
        return `
            <div class="timeline-item">
                <div class="timeline-dot ${type}"></div>
                <div class="timeline-message">${this._escapeHtml(c.message)}</div>
                <div class="timeline-meta">
                    <span><code>${c.short_hash}</code></span>
                    <span>${c.author}</span>
                    <span>${this._formatDate(c.date)}</span>
                </div>
                ${c.files_changed ? `
                    <div class="timeline-stat">
                        <span class="files">${c.files_changed} file${c.files_changed !== 1 ? 's' : ''}</span>
                        ${c.insertions ? `<span class="added">+${c.insertions}</span>` : ''}
                        ${c.deletions ? `<span class="removed">-${c.deletions}</span>` : ''}
                    </div>
                ` : ''}
            </div>
        `;
    },

    _commitType(message) {
        if (!message) return '';
        const lower = message.toLowerCase();
        if (lower.startsWith('feat') || lower.startsWith('add')) return 'feat';
        if (lower.startsWith('fix')) return 'fix';
        if (lower.startsWith('refactor') || lower.startsWith('restructur')) return 'refactor';
        if (lower.startsWith('doc')) return 'docs';
        if (lower.startsWith('chore') || lower.startsWith('clean')) return 'chore';
        return '';
    },

    _formatDate(dateStr) {
        if (!dateStr) return '';
        try {
            const d = new Date(dateStr);
            return d.toLocaleDateString('es-ES', {
                day: '2-digit', month: 'short', year: 'numeric',
                hour: '2-digit', minute: '2-digit'
            });
        } catch { return dateStr; }
    },

    _formatNet(commits) {
        const ins = commits.reduce((s, c) => s + (c.insertions || 0), 0);
        const del = commits.reduce((s, c) => s + (c.deletions || 0), 0);
        const net = ins - del;
        return (net >= 0 ? '+' : '') + net.toLocaleString();
    },

    _escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
};
